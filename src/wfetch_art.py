#!/usr/bin/env python3
"""wfetch_art.py - render a PNG as ANSI truecolor half-block art (stdlib only).

Usage:
    wfetch_art.py <logo.png> [--width N] [--bg R,G,B] [--key N]

Emits one line per half-block row (U+2580 = upper half block; foreground is the
top pixel, background the bottom pixel, giving 2x vertical resolution).

Transparency handling:
  * Pixels with alpha < --key (default 40) are treated as fully transparent and
    rendered with the terminal default background (ESC[49m), so the real
    terminal background shows through - the logo never sits on a painted block.
  * When stdout+stdin are ttys the terminal background is queried via OSC 11
    and used only to blend the few semi-transparent pixels.
  * --bg R,G,B overrides that blend colour (fallback when not a tty).
Each line ends with an ANSI reset.
"""
import os
import re
import select
import struct
import sys
import termios
import time
import zlib
import base64
import hashlib


def out_write(text):
    """Write text as UTF-8 bytes whatever the locale (LANG=C, py3.4+)."""
    buf = getattr(sys.stdout, "buffer", None)
    if buf is not None:
        sys.stdout.flush()
        buf.write(text.encode("utf-8"))
        buf.flush()
    else:
        sys.stdout.write(text)


def decode_png(path):
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    pos = 8
    width = height = bitdepth = colortype = interlace = None
    idat = bytearray()
    palette = None
    while pos < len(data):
        ln = struct.unpack(">I", data[pos:pos + 4])[0]
        typ = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + ln]
        if typ == b"IHDR":
            (width, height, bitdepth, colortype, _c, _f, interlace) = struct.unpack(
                ">IIBBBBB", chunk
            )
        elif typ == b"PLTE":
            palette = chunk
        elif typ == b"IDAT":
            idat += chunk
        elif typ == b"IEND":
            break
        pos += 12 + ln
    if interlace != 0:
        raise ValueError("interlaced PNG unsupported")
    return width, height, bitdepth, colortype, palette, zlib.decompress(bytes(idat))


def unfilter(width, height, bitdepth, colortype, raw):
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[colortype]
    bpp = max(1, bitdepth // 8 * channels)
    stride = (bitdepth // 8) * channels * width
    out = bytearray()
    pos = 0
    prev = bytearray(stride)
    for _y in range(height):
        f = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        if f == 1:
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 0xFF
        elif f == 2:
            line = bytearray((a + b) & 0xFF for a, b in zip(line, prev))
        elif f == 3:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif f == 4:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                c = prev[i - bpp] if i >= bpp else 0
                b = prev[i]
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                if pa <= pb and pa <= pc:
                    pr = a
                elif pb <= pc:
                    pr = b
                else:
                    pr = c
                line[i] = (line[i] + pr) & 0xFF
        out += line
        prev = line
    return out


def to_rgba(width, height, bitdepth, colortype, palette, raw):
    """Convert unfiltered 8-bit scanlines to RGBA8 (fast path for RGBA)."""
    if bitdepth != 8:
        raise ValueError("only 8-bit PNGs supported (got depth %d)" % bitdepth)
    n = width * height
    if colortype == 6:
        return bytearray(raw[:n * 4])
    px = bytearray(n * 4)
    if colortype == 2:
        px[0::4] = raw[0::3][:n]
        px[1::4] = raw[1::3][:n]
        px[2::4] = raw[2::3][:n]
        px[3::4] = b"\xff" * n
    elif colortype == 0:
        g = raw[:n]
        px[0::4] = g
        px[1::4] = g
        px[2::4] = g
        px[3::4] = b"\xff" * n
    elif colortype == 4:
        g = raw[0::2][:n]
        px[0::4] = g
        px[1::4] = g
        px[2::4] = g
        px[3::4] = raw[1::2][:n]
    elif colortype == 3 and palette:
        pal = bytearray(palette)
        for i in range(n):
            j = raw[i] * 3
            px[i * 4:i * 4 + 3] = pal[j:j + 3]
            px[i * 4 + 3] = 255
    else:
        raise ValueError("unsupported PNG colour type %d" % colortype)
    return px


def sample(img, w, h, x, y):
    i = (y * w + x) * 4
    return img[i], img[i + 1], img[i + 2], img[i + 3]


def query_term_bg():
    """Query the terminal background colour via OSC 11. Returns (r,g,b) or None."""
    if not sys.stdout.isatty() or not sys.stdin.isatty():
        return None
    if os.environ.get("TERM") == "dumb":
        return None
    fd = sys.stdin.fileno()
    try:
        attrs = termios.tcgetattr(fd)
    except Exception:
        return None
    new = termios.tcgetattr(fd)
    new[3] &= ~(termios.ICANON | termios.ECHO | termios.ISIG)
    new[6][termios.VMIN] = 0
    new[6][termios.VTIME] = 1
    data = b""
    try:
        termios.tcsetattr(fd, termios.TCSANOW, new)
        sys.stdout.write("\x1b]11;?\x1b\\")
        sys.stdout.flush()
        deadline = time.time() + 0.2
        while time.time() < deadline:
            r, _, _ = select.select([fd], [], [], 0.05)
            if not r:
                continue
            chunk = os.read(fd, 64)
            if not chunk:
                break
            data += chunk
            if b"\x1b\\" in data or b"\x07" in data:
                break
    finally:
        try:
            termios.tcsetattr(fd, termios.TCSANOW, attrs)
        except Exception:
            pass
    m = re.search(
        rb"\x1b\]11;(?:rgba?)?:?([0-9a-fA-F]{1,8})/([0-9a-fA-F]{1,8})/([0-9a-fA-F]{1,8})(?:/([0-9a-fA-F]{1,8}))?",
        data,
    )
    if not m:
        return None

    def chan(s):
        s = s.decode()
        if len(s) == 1:
            return int(s, 16) * 17
        return int(s[:2], 16)

    if m.group(4) is not None and chan(m.group(4)) == 0:
        return None  # terminal background is fully transparent
    return (chan(m.group(1)), chan(m.group(2)), chan(m.group(3)))


def encode_png_rgba(w, h, px):
    """Minimal RGBA8 PNG encoder (stdlib only) - used for kitty/iTerm2 output."""
    def chunk(typ, data):
        c = struct.pack(">I", len(data)) + typ + data
        crc = zlib.crc32(typ + data) & 0xFFFFFFFF
        return c + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    rows = bytearray()
    stride = w * 4
    for y in range(h):
        rows.append(0)
        rows += px[y * stride:(y + 1) * stride]
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", ihdr)
            + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
            + chunk(b"IEND", b""))


def resize_rgba(px, w, h, new_w, new_h):
    """Nearest-neighbour RGBA downsample (fast, good enough for scaled art)."""
    out = bytearray(new_w * new_h * 4)
    for oy in range(new_h):
        sy = (oy * h) // new_h
        for ox in range(new_w):
            sx = (ox * w) // new_w
            src = (sy * w + sx) * 4
            dst = (oy * new_w + ox) * 4
            out[dst:dst + 4] = px[src:src + 4]
    return out


KITTY_CHUNK = 4096  # protocol limit for one base64 payload chunk


def kitty_image_id():
    """Stable non-zero 24-bit image id so re-runs replace, not pile up."""
    return (zlib.crc32(b"wellfetch-logo") & 0xFFFFFF) or 1


def emit_kitty(png, px_w, px_h, cols, rows):
    """Transmit + display an image via the kitty graphics protocol.

    One a=T (transmit & place) command with a fixed image id, quiet mode q=2
    (the terminal sends no reply, so nothing has to be read back), scaled to
    `cols` x `rows` cells at the cursor. The base64 payload is split into
    <=4096-byte chunks: m=1 on every chunk but the last (m=0); control keys
    are only allowed on the first chunk. Supported by kitty, wezterm,
    konsole 23.04+ and ghostty.
    """
    b64 = base64.b64encode(png).decode("ascii")
    parts = [b64[k:k + KITTY_CHUNK] for k in range(0, len(b64), KITTY_CHUNK)] or [""]
    out = []
    for n, part in enumerate(parts):
        more = 1 if n < len(parts) - 1 else 0
        if n == 0:
            ctl = "a=T,f=100,i=%d,q=2,c=%d,r=%d,m=%d" % (kitty_image_id(), cols, rows, more)
        else:
            ctl = "m=%d" % more
        out.append("\x1b_G%s;%s\x1b\\" % (ctl, part))
    sys.stdout.write("".join(out))
    sys.stdout.write("\n")
    sys.stdout.flush()


def emit_iterm(png, px_w):
    """iTerm2 inline image (OSC 1337). width in px; height keeps aspect."""
    b64 = base64.b64encode(png).decode("ascii")
    sys.stdout.write("\x1b]1337;File=name=logo.png;inline=1;width=%dpx;preserveAspectRatio=1;height=auto:%s\x07" % (px_w, b64))
    sys.stdout.write("\n")


def detect_gfx():
    """Pick the best image protocol for this terminal: kitty | iterm | none."""
    term = os.environ.get("TERM", "")
    prog = os.environ.get("TERM_PROGRAM", "")
    if term == "xterm-kitty" or prog == "WezTerm" \
            or prog == "ghostty" or prog == "konsole":
        return "kitty"
    if prog == "iTerm.app" or os.environ.get("ITERM_PROFILE") or prog == "mintty":
        return "iterm"
    return "none"


GFX_W = 640  # cached transmission resolution; the terminal smooth-scales it
_GFX_VER = "v1"


def _gfx_cache_dir():
    d = os.environ.get("WF_CACHE_DIR")
    if d:
        return d
    return os.path.join(
        os.environ.get("XDG_CACHE_HOME") or os.path.join(os.path.expanduser("~"), ".cache"),
        "wellutils",
    )


def _logo_key(path):
    """Content key for cache file names. md5 is not a security use here, but
    FIPS-mode OpenSSL makes hashlib.md5 raise ValueError: fall back to crc32
    (plus length) which is always available."""
    try:
        data = open(path, "rb").read()
    except OSError:
        return "0000000000000000"
    try:
        return hashlib.md5(data).hexdigest()[:16]
    except (ValueError, AttributeError, TypeError):
        return "%08x%08x" % (zlib.crc32(data) & 0xFFFFFFFF, len(data) & 0xFFFFFFFF)


def gfx_png_cached(path):
    """Return cached (px_w, px_h, png) for the logo, or None on miss.

    The PNG is keyed only by the logo's hash at a fixed generous resolution,
    so one render serves every terminal width. Decoding/unfiltering the source
    (the slow part) is skipped entirely on a hit.
    """
    key = _logo_key(path)
    try:
        d = _gfx_cache_dir()
        if not os.path.isdir(d):
            return None
        prefix = "gfx-%s-%s-" % (_GFX_VER, key)
        for fn in os.listdir(d):
            if not fn.startswith(prefix) or not fn.endswith(".png"):
                continue
            m = re.match(r"gfx-[0-9a-z]+-[0-9a-f]+-(\d+)x(\d+)\.png", fn)
            if not m:
                continue
            with open(os.path.join(d, fn), "rb") as f:
                return int(m.group(1)), int(m.group(2)), f.read()
    except OSError:
        pass
    return None


def gfx_render_and_cache(path, w, h, bd, ct, pal, raw):
    """Decode at full quality, downscale to GFX_W, cache the PNG, return it."""
    img = to_rgba(w, h, bd, ct, pal, unfilter(w, h, bd, ct, raw))
    px_w = GFX_W
    px_h = max(4, int(px_w * h / w))
    small = resize_rgba(img, w, h, px_w, px_h)
    png = encode_png_rgba(px_w, px_h, small)
    key = _logo_key(path)
    try:
        d = _gfx_cache_dir()
        if not os.path.isdir(d):
            os.makedirs(d)
        tmp = os.path.join(d, ".gfx-%s-%s.tmp" % (_GFX_VER, os.getpid()))
        with open(tmp, "wb") as f:
            f.write(png)
        os.replace(tmp, os.path.join(d, "gfx-%s-%s-%dx%d.png" % (_GFX_VER, key, px_w, px_h)))
    except OSError:
        pass
    return px_w, px_h, png


DEC_W = 320  # cached decode size: enough for the 160-column max width
_DEC_VER = "v1"


def load_rgba_cached(path):
    """Return (w, h, rgba) of the logo, downscaled to DEC_W and cached.

    Decoding + unfiltering a 1024 px PNG in pure Python takes ~1.5 s on a
    desktop (much more on SBCs); every terminal width re-used to pay that.
    The small raw RGBA copy is keyed by the logo hash and serves them all.
    """
    key = _logo_key(path)
    d = _gfx_cache_dir()
    prefix = "dec-%s-%s-" % (_DEC_VER, key)
    try:
        if os.path.isdir(d):
            for fn in os.listdir(d):
                m = re.match(r"dec-[0-9a-z]+-[0-9a-f]+-(\d+)x(\d+)\.rgba$", fn)
                if not fn.startswith(prefix) or not m:
                    continue
                cw, ch = int(m.group(1)), int(m.group(2))
                with open(os.path.join(d, fn), "rb") as f:
                    data = bytearray(f.read())
                if len(data) == cw * ch * 4:
                    return cw, ch, data
    except OSError:
        pass
    w, h, bd, ct, pal, raw = decode_png(path)
    img = to_rgba(w, h, bd, ct, pal, unfilter(w, h, bd, ct, raw))
    if w > DEC_W:
        nw = DEC_W
        nh = max(2, int(round(float(h) * nw / w)))
        img = resize_rgba(img, w, h, nw, nh)
        w, h = nw, nh
    try:
        if not os.path.isdir(d):
            os.makedirs(d)
        tmp = os.path.join(d, ".dec-%s-%s.tmp" % (_DEC_VER, os.getpid()))
        with open(tmp, "wb") as f:
            f.write(bytes(img))
        os.replace(tmp, os.path.join(d, "%s%dx%d.rgba" % (prefix, w, h)))
    except OSError:
        pass
    return w, h, img


def main():
    args = sys.argv[1:]
    if not args:
        sys.stderr.write("usage: wfetch_art.py <logo.png> [--width N] [--bg R,G,B] [--key N] [--gfx auto|kitty|iterm|none]\n")
        sys.exit(2)
    path = args[0]
    width = 48
    bg = None
    key = 40
    gfx = None
    i = 1
    while i < len(args):
        if args[i] == "--width" and i + 1 < len(args):
            width = max(8, min(160, int(args[i + 1])))
            i += 2
        elif args[i] == "--bg" and i + 1 < len(args):
            bg = tuple(int(x) for x in args[i + 1].split(","))
            i += 2
        elif args[i] == "--key" and i + 1 < len(args):
            key = max(0, min(255, int(args[i + 1])))
            i += 2
        elif args[i] == "--gfx" and i + 1 < len(args):
            gfx = args[i + 1]
            i += 2
        else:
            i += 1
    if gfx == "auto":
        gfx = detect_gfx()
    if gfx == "none":
        gfx = None
    if gfx in ("kitty", "iterm"):
        hit = gfx_png_cached(path)
        if hit is not None:
            px_w, px_h, png = hit
        else:
            w, h, bd, ct, pal, raw = decode_png(path)
            px_w, px_h, png = gfx_render_and_cache(path, w, h, bd, ct, pal, raw)
        rows = max(2, int(round(0.5 * px_h / px_w * width)))
        if gfx == "kitty":
            emit_kitty(png, px_w, px_h, width, rows)
        else:
            emit_iterm(png, px_w)
        sys.exit(0)
    w, h, img = load_rgba_cached(path)
    rows = max(2, int(round(0.5 * h / w * width)))
    out_h = rows * 2  # output pixel height
    if bg is None:
        bg = query_term_bg()
    if bg is None:
        bg = (22, 20, 32)
    lines = []
    for oy in range(rows):
        y0 = int((oy * 2 + 0.5) * h / out_h)
        y1 = int(((oy * 2 + 1) + 0.5) * h / out_h)
        y0 = min(y0, h - 1)
        y1 = min(y1, h - 1)
        cells = []
        for ox in range(width):
            x0 = int((ox + 0.5) * w / width)
            x0 = min(x0, w - 1)
            top = classify(sample(img, w, h, x0, y0), bg, key)
            bot = classify(sample(img, w, h, x0, y1), bg, key)
            cells.append(cell(top, bot))
        lines.append("".join(cells) + "\x1b[0m")
    out_write("\n".join(lines) + "\n")


def classify(c, bg, key):
    """Return ('solid',(r,g,b)) or ('bg',) for a pixel sample."""
    r, g, b, a = c
    if a < key:
        return ("bg",)
    if a >= 255:
        return ("solid", (r, g, b))
    inv = 1.0 - a / 255.0
    if bg is None:
        return ("solid", (r, g, b))
    return (
        "solid",
        (
            int(r * a / 255.0 + bg[0] * inv),
            int(g * a / 255.0 + bg[1] * inv),
            int(b * a / 255.0 + bg[2] * inv),
        ),
    )


def cell(top, bot):
    """Build the escape sequence for one half-block cell.

    top/bot are the upper/lower pixel: ('solid',(r,g,b)) or ('bg',).
    Transparent pixels use the default background (ESC[49m) so the terminal's
    own background shows through; the block glyph (upper or lower half) is
    chosen so the transparent half is always the background.
    """
    if top[0] == "bg" and bot[0] == "bg":
        return "\x1b[49m "
    if top[0] == "bg":
        r, g, b = bot[1]
        return "\x1b[38;2;%d;%d;%dm\x1b[49m\u2584" % (r, g, b)
    if bot[0] == "bg":
        r, g, b = top[1]
        return "\x1b[38;2;%d;%d;%dm\x1b[49m\u2580" % (r, g, b)
    r1, g1, b1 = top[1]
    r2, g2, b2 = bot[1]
    return "\x1b[38;2;%d;%d;%dm\x1b[48;2;%d;%d;%dm\u2580" % (r1, g1, b1, r2, g2, b2)


if __name__ == "__main__":
    main()

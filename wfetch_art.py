#!/usr/bin/env python3
"""wfetch_art.py — render a PNG as ANSI truecolor half-block art (stdlib only).

Usage:
    wfetch_art.py <logo.png> [--width N] [--bg R,G,B] [--key N]

Emits one line per half-block row (U+2580 = upper half block; foreground is the
top pixel, background the bottom pixel, giving 2x vertical resolution).

Transparency handling:
  * Pixels with alpha < --key (default 40) are treated as fully transparent and
    rendered with the terminal default background (ESC[49m), so the real
    terminal background shows through — the logo never sits on a painted block.
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
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
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
    if colortype != 6 or bitdepth != 8:
        raise ValueError("only 8-bit RGBA supported (got type %d depth %d)" % (colortype, bitdepth))
    px = bytearray(width * height * 4)
    for i in range(width * height):
        px[i * 4:i * 4 + 4] = raw[i * 4:i * 4 + 4]
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


def main():
    args = sys.argv[1:]
    if not args:
        sys.stderr.write("usage: wfetch_art.py <logo.png> [--width N] [--bg R,G,B] [--key N]\n")
        sys.exit(2)
    path = args[0]
    width = 48
    bg = None
    key = 40
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
        else:
            i += 1
    if bg is None:
        bg = query_term_bg()
    if bg is None:
        bg = (22, 20, 32)
    w, h, bd, ct, pal, raw = decode_png(path)
    img = to_rgba(w, h, bd, ct, pal, unfilter(w, h, bd, ct, raw))
    # A terminal cell is roughly twice as tall as wide, and each half-block
    # already carries 2 vertical samples, so a square image needs width/2 rows.
    rows = max(2, int(round(0.5 * h / w * width)))
    out_h = rows * 2  # output pixel height
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
    sys.stdout.write("\n".join(lines))
    sys.stdout.write("\n")


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

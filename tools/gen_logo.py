#!/usr/bin/env python3
"""Regenerate logo.png: an equilateral triangle with a Lambda notch.

Matches the historical wellfetch logo (sharp apex, flat base sitting exactly
on the art's bottom edge) while keeping the original purple palette.

Usage: gen_logo.py [SIZE]   # canvas edge in px (default 256)

The default canvas is small on purpose: the renderer samples it nearest-
neighbour at ~40-80 columns, and a 1024px source costs ~1.2s of pure-Python
PNG unfiltering per render (wfetch_art.py is stdlib-only).
"""
import sys

import numpy as np
from PIL import Image, ImageDraw

S = int(sys.argv[1]) if len(sys.argv) > 1 else 256
SS = 2  # supersampling factor
k = S / 1024.0  # scale factor from the original 1024px coordinate space

# Outer equilateral triangle: apex at top, base on the art's bottom edge.
# half_base = tan(30deg) * height  =>  60deg corners (equilateral)
apex = (512 * k, 168 * k)
base_y = 752 * k
half_base = (base_y - apex[1]) * 0.57735
tri = [(apex[0], apex[1]), (apex[0] + half_base, base_y), (apex[0] - half_base, base_y)]

# Lambda notch: an inverted V cutout, tip at ~83% of the height.
notch = [
    (512 - 14, 400),
    (512 - 75, 500),
    (512, 650),
    (512 + 75, 500),
    (512 + 14, 400),
]
notch = [(x * k, y * k) for x, y in notch]

RIM = max(1, round(3 * k))  # dark rim thickness (px at final scale)
FILL = (193, 108, 255)
EDGE = (64, 0, 141)

big = S * SS
mask = Image.new("L", (big, big), 0)
d = ImageDraw.Draw(mask)
d.polygon([(x * SS, y * SS) for x, y in tri], fill=255)
d.polygon([(x * SS, y * SS) for x, y in notch], fill=0)
m = np.array(mask) / 255.0


def erode(a, r):
    out = a
    for _ in range(r):
        out = np.minimum(
            np.minimum(out, np.roll(out, 1, 0)),
            np.minimum(np.roll(out, -1, 0), np.roll(np.roll(out, 1, 1), -1, 1)),
        )
        out = np.minimum(out, np.roll(out, 1, 1))
        out = np.minimum(out, np.roll(out, -1, 1))
    return out


core = erode(m, RIM * SS)

out = np.zeros((big, big, 4), np.uint8)
out[:, :, 3] = (m * 255).astype(np.uint8)
for i in range(3):
    out[:, :, i] = (core * FILL[i] + (m - core) * EDGE[i]).astype(np.uint8)

img = Image.fromarray(out).resize((S, S), Image.BILINEAR)
img.save("logo.png")
print("saved logo.png", img.size, "base width:", 2 * half_base, "height:", base_y - apex[1])
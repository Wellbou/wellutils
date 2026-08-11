#!/usr/bin/env python3
"""Regenerate logo.png: an equilateral triangle with a Lambda notch.

Matches the historical wellfetch logo (sharp apex, flat base sitting exactly
on the art's bottom edge) while keeping the original purple palette.
"""
import numpy as np
from PIL import Image, ImageDraw

S = 1024
SS = 2  # supersampling factor

# Outer equilateral triangle: apex at top, base on the art's bottom edge.
# half_base = tan(30deg) * height  =>  60deg corners (equilateral)
apex = (512, 168)
base_y = 752
half_base = int(round((base_y - apex[1]) * 0.57735))
tri = [(apex[0], apex[1]), (apex[0] + half_base, base_y), (apex[0] - half_base, base_y)]

# Lambda notch: an inverted V cutout, tip at ~83% of the height.
notch = [
    (512 - 14, 400),
    (512 - 75, 500),
    (512, 650),
    (512 + 75, 500),
    (512 + 14, 400),
]

RIM = 3  # dark rim thickness (px at final scale)
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
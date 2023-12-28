from ast import literal_eval
from dataclasses import dataclass
from itertools import combinations


@dataclass
class Hailstone:
    x: int
    y: int
    z: int
    xv: int
    yv: int
    zv: int

hailstones = [Hailstone(*[num for half in line.split(" @ ") for num in literal_eval(half)]) for line in open("input")]

start = 200000000000000
end = 400000000000000

part1 = 0
for (a, b) in combinations(hailstones, 2):
    # https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection#Given_two_points_on_each_line
    x1, y1 = a.x, a.y
    x2, y2 = x1 + a.xv, y1 + a.yv
    x3, y3 = b.x, b.y
    x4, y4 = x3 + b.xv, y3 + b.yv
    denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if denom:
        px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / denom
        py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / denom
        # in bounds
        if start <= px <= end and start <= py <= end:
            # not in past
            if (px - a.x) / a.xv >= 0 and (px - b.x) / b.xv >= 0:
                part1 += 1
print(part1)

# now time for some integer programming
# 3 * 3 = 9 equations, 9 unknowns... so only 3 hailstones are needed
import z3
a, b, c = hailstones[:3]
s = z3.Solver()
x, y, z = z3.Int('x'), z3.Int('y'), z3.Int('z')
xv, yv, zv = z3.Int('xv'), z3.Int('yv'), z3.Int('zv')
t1, t2, t3 = z3.Int('t1'), z3.Int('t2'), z3.Int('t3')
s.add(t1 >= 0, t2 >= 0, t3 >= 0)
s.add(x + t1 * xv == a.x + t1 * a.xv) # type: ignore
s.add(y + t1 * yv == a.y + t1 * a.yv) # type: ignore
s.add(z + t1 * zv == a.z + t1 * a.zv) # type: ignore
s.add(x + t2 * xv == b.x + t2 * b.xv) # type: ignore
s.add(y + t2 * yv == b.y + t2 * b.yv) # type: ignore
s.add(z + t2 * zv == b.z + t2 * b.zv) # type: ignore
s.add(x + t3 * xv == c.x + t3 * c.xv) # type: ignore
s.add(y + t3 * yv == c.y + t3 * c.yv) # type: ignore
s.add(z + t3 * zv == c.z + t3 * c.zv) # type: ignore
s.check()
m = s.model()
print(m[x].as_long() + m[y].as_long() + m[z].as_long()) # type: ignore

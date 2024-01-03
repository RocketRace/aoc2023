import Cocoa

struct Point {
    let x: Int
    let y: Int
    let z: Int

    func above() -> Point {
        Point(x: x, y: y, z: z + 1)
    }
    func below() -> Point {
        Point(x: x, y: y, z: z - 1)
    }
}

extension Point: Hashable {
    static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
}

// reference type; for mutating start and end points
class Brick {
    var start: Point
    var end: Point
    init(start: Point, end: Point) {
        self.start = start
        self.end = end
    }

    func points() -> [Point] {
        if start.x != end.x {
            (start.x...end.x).map {
                x in Point(x: x, y: start.y, z: start.z)
            }
        }
        else if start.y != end.y {   
            (start.y...end.y).map {
                y in Point(x:start.x, y: y, z: start.z)
            }
        }
        else if start.z != end.z {
            (start.z...end.z).map {
                z in Point(x: start.x, y: start.y, z: z)
            }
        }
        else {
            [start]
        }
    }
}

var bricks = try String(contentsOfFile: "input", encoding: .utf8)
    .split(separator: "\n")
    .map { line in 
        line
        .split(separator: "~")
        .map {
            let raw: [Int] = $0.split(separator: ",").map {Int($0) ?? 0} 
            return Point(x: raw[0], y: raw[1], z: raw[2])
        }
    }
    .map {
        return Brick(start: $0[0], end: $0[1])
    }

var grid: [Point: Int] = [:]
for (i, brick) in bricks.enumerated() {
    for point in brick.points() {
        grid[point] = i
    }
}

func falling(i: Int) -> Bool {
    let brick = bricks[i]
    return brick.points().allSatisfy { point in
        if let j = grid[point.below()] {
            j == i // part of the same rigidbody?
        }
        else {
            point.z >= 1 // no ground below?
        }
    }
}

func tick() -> Bool {
    var fell = false
    for (i, brick) in bricks.enumerated() {
        if falling(i: i) {
            fell = true
            for point in brick.points() {
                grid.removeValue(forKey: point)
            }
            brick.start = brick.start.below()
            brick.end = brick.end.below()
            for point in brick.points() {
                grid[point] = i
            }

        }
    }
    return fell
}

while tick() {}

func supportedOnlyBy(i: Int, by: Int) -> Bool {
    let brick = bricks[i]
    return brick.points().allSatisfy { point in
        if let j = grid[point.below()] {
            j == i || j == by // part of the same rigidbody, or the target?
        }
        else {
            point.z >= 1 // no ground below?
        }
    }
}

func safe(i: Int) -> Bool {
    let brick = bricks[i]
    return brick.points().allSatisfy { point in
        if let j = grid[point.above()] {
            if j == i {
                true // self doesn't need support
            }
            else {
                !supportedOnlyBy(i: j, by: i) // uh oh, responsibility?
            }
        }
        else {
            true // air doesn't need support
        }
    }
}

let part1 = (0..<bricks.count).filter {safe(i: $0)}.count
print(part1)

func supportedOnlyByThese(i: Int, bys: Set<Int>) -> Bool {
    let brick = bricks[i]
    return brick.points().allSatisfy { point in
        if let j = grid[point.below()] {
            j == i || bys.contains(j) // part of the same rigidbody, or any target?
        }
        else {
            point.z >= 1 // no ground below?
        }
    }
}

func reachesHeight(height: Int, chained: Set<Int>) -> [Int] {
    chained.filter { bricks[$0].end.z == height }
}

func chaining(start: Int) -> Int {
    var newbies: Set<Int> = []
    var chained: Set<Int> = [start]
    var height = bricks[start].end.z
    while chained.count > 0 {
        for i in reachesHeight(height: height, chained: chained) {
            for point in bricks[i].points() {
                if let abover = grid[point.above()] {
                    if supportedOnlyByThese(i: abover, bys: chained) {
                        chained.insert(abover)
                        newbies.insert(abover)
                    }
                }
            }
            chained.remove(i)
        }
        height += 1
    }

    return newbies.count
}

let part2 = (0..<bricks.count).map { chaining(start: $0) }.reduce(0) { $0 + $1 }
print(part2)
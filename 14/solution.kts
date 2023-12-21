import java.io.File

val content = File("input").readLines()
val height = content.size
val width = content[0].length

// really oughta be a class at this rate
var grid = mutableMapOf<Pair<Int, Int>, Char>()
content.forEachIndexed {
    y, row -> row.forEachIndexed {
        x, char -> grid.put(Pair(x, y), char)
    }
}

fun dbg(): Unit {
    for (y in 0..<height) {
        for (x in 0..<width) {
            print(grid.get(Pair(x, y)))
        }
        println()
    }
    println()
}

fun key(): String {
    val chars = mutableListOf<Char>()
    for (y in 0..<height) {
        for (x in 0..<width) {
            chars.add(grid[Pair(x, y)]!!)
        }
    }
    return chars.joinToString("")
}

enum class Direction {
    NORTH, WEST, SOUTH, EAST
}

fun index(dir: Direction, slice: Int, step: Int): Pair<Int, Int> = when (dir) {
    Direction.NORTH -> Pair(slice, step)
    Direction.SOUTH -> Pair(slice, step)
    Direction.EAST -> Pair(step, slice)
    Direction.WEST -> Pair(step, slice)
}

fun slide(dir: Direction): Unit {
    val major = when (dir) {
        Direction.NORTH -> width
        Direction.SOUTH -> width
        Direction.EAST -> height
        Direction.WEST -> height
    }
    val minor = when (dir) {
        Direction.NORTH -> height
        Direction.SOUTH -> height
        Direction.EAST -> width
        Direction.WEST -> width
    }
    val reversed = when (dir) {
        Direction.NORTH -> false
        Direction.WEST -> false
        Direction.SOUTH -> true
        Direction.EAST -> true
    }
    for (slice in 0..<major) {
        // for each major slice, determine the wall positions and derive non-wall ranges from that
        // (this turns .##..# into [-1, 1, 2, 5, 6] and hence [0..<1, 2..<2, 3..<5, 6..<6])
        // finally, we can simply align the rocks in the blocks
        var walls = mutableListOf(-1)
        for (step in 0..<minor) {
            if (grid.get(index(dir, slice, step)) == '#') {
                walls.add(step)
            }
        }
        walls.add(minor)
        for (block in walls.windowed(2)) {
            val (start, end) = block
            // first collect each rock, then place them
            var count = 0
            for (step in start+1..<end) {
                if (grid.get(index(dir, slice, step)) == 'O') {
                    count += 1
                }
            }
            val leaning = if (reversed) {(start+1..<end).reversed()} else {start+1..<end}
            for (step in leaning) {
                if (count > 0) {
                    grid.put(index(dir, slice, step), 'O')
                    count -= 1
                } else {
                    grid.put(index(dir, slice, step), '.')
                }
            }
        }
    }
}

fun load(): Int {
    var loaded = 0
    for (y in 0..<height) {
        for (x in 0..<width) {
            if (grid.get(Pair(x, y)) == 'O') {
                loaded += height - y
            }
        }
    }
    return loaded
}

val limit = 1000000000
var history = mutableMapOf<String, Int>()
var loads = mutableListOf<Int>()
for (tick in 0..limit) {
    slide(Direction.NORTH)
    slide(Direction.WEST)
    slide(Direction.SOUTH)
    slide(Direction.EAST)
    val keyed = key()
    // I should learn a better alternative to this (which DOES work...)
    if (history.containsKey(keyed)) {
        val before = history[keyed]!!
        val delta = tick - before
        val offset = (limit - tick - 1) % delta
        println(loads[before + offset])
        break
    }
    history.put(keyed, tick)
    loads.add(load())
}
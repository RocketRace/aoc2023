import std/os/file
import std/os/path

fun transpose(grid : list<string>) : exn list<string>
    grid.replicate(grid.head.unjust.slice.count).map-indexed fn(i, nested)
        nested.map(fn(s) s.list[i].unjust).string

fun almost-equal(a : string, b : string) : bool
    a.list.zip(b.list).filter(fn((x, y)) {x != y}).length == 1

fun almost-or-equal(a : string, b : string) : bool
    a == b || almost-equal(a, b)

fun row-occurrences(grid : list<string>, target-row : string, starting : int) : list<int>
    grid.map-indexed(fn(y, row)
            (y, row)
        )
        .filter-map(fn((y, row))
            if row == target-row && y > starting then Just(y) else Nothing
        )

fun smudge-occurrences(grid : list<string>, target-row : string, starting : int) : list<int>
    grid.map-indexed(fn(y, row)
            (y, row)
        )
        .filter-map(fn((y, row))
            if almost-or-equal(row, target-row) && y > starting then Just(y) else Nothing
        )

fun try-squeeze(grid : list<string>, from : int, to : int) : bool
    val midpoint = (to - from) / 2
    (to - from) % 2 == 1 &&
        list(0, midpoint).all fn(y)
            match((grid[y], grid[to - y]))
                (Just(a), Just(b)) -> a == b
                _ -> False

fun try-smudge(grid : list<string>, from : int, to : int) : bool
    val midpoint = (to - from) / 2
    val (smudges, valid) = list(0, midpoint).foldl((0, True), fn((smudges, valid), y)
        match((grid[y], grid[to - y]))
            (Just(a), Just(b)) ->
                if a == b then
                    (smudges, valid)
                else if almost-equal(a, b) then
                    (smudges + 1, valid)
                else
                    (smudges, False)
            _ -> (smudges, False)
    )
    (to - from) % 2 == 1 && valid && smudges == 1

fun find-mirror(grid : list<string>) : exn maybe<int>
    val test-y = 0
    val test-row = grid.head.unjust
    row-occurrences(grid, test-row, test-y).find(fn(y)
        y != test-y && try-squeeze(grid, test-y, y)
    ).map(fn(y)
        (y + 1) / 2
    )

fun find-smudge(grid : list<string>) : exn maybe<int>
    val test-y = 0
    val test-row = grid.head.unjust
    smudge-occurrences(grid, test-row, test-y).find(fn(y)
        y != test-y && try-smudge(grid, test-y, y)
    ).map(fn(y)
        (y + 1) / 2
    )

pub fun main()
    val input = read-text-file(cwd() / "input")
    val grids = input.split("\n\n").map(lines)

    var part1 := 0
    grids.foreach fn(grid : list<string>)
        val height = grid.length
        val width = grid.head.unjust.slice.count
        match(grid.find-mirror())
            Just(row) -> part1 := part1 + 100 * row
            Nothing -> match(grid.transpose.find-mirror())
                Just(col) -> part1 := part1 + col
                Nothing -> match(grid.reverse.find-mirror())
                    Just(row) -> part1 := part1 + 100 * (height - row)
                    Nothing -> match(grid.transpose.reverse.find-mirror())
                        Just(col) ->  part1 := part1 + (width - col)
                        Nothing -> println("not found")
    
    var part2 := 0
    grids.foreach fn(grid : list<string>)
        val height = grid.length
        val width = grid.head.unjust.slice.count
        match(grid.find-smudge())
            Just(row) -> part2 := part2 + 100 * row
            Nothing -> match(grid.transpose.find-smudge())
                Just(col) -> part2 := part2 + col
                Nothing -> match(grid.reverse.find-smudge())
                    Just(row) -> part2 := part2 + 100 * (height - row)
                    Nothing -> match(grid.transpose.reverse.find-smudge())
                        Just(col) -> part2 := part2 + (width - col)
                        Nothing -> println("not found")
    println(show(part1))
    println(show(part2))

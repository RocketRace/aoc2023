open System.IO

let input = File.ReadAllText("input")
let grid = input.Split("\n")
let startIndex = input.IndexOf('S')
let height = grid.Length - 1
let byteWidth = input.Length / height
let width = byteWidth - 1
let startX = startIndex % byteWidth
let startY = startIndex / byteWidth

type Direction =
    | Right = 0
    | Up = 1
    | Left = 2
    | Down = 3

let opposite dir =
    match dir with
    | Direction.Left -> Direction.Right
    | Direction.Right -> Direction.Left
    | Direction.Down -> Direction.Up
    | Direction.Up -> Direction.Down
    | _ -> failwith "how"

let index (x, y) =
    if x >= 0 && y >= 0 && x < width && y < height then
        Some(grid[y][x])
    else
        None

let apply dir x y =
    match dir with
    | Direction.Right -> (dir, x + 1, y)
    | Direction.Up -> (dir, x, y - 1)
    | Direction.Left -> (dir, x - 1, y)
    | Direction.Down -> (dir, x, y + 1)
    | _ -> (dir, x, y)

let proceed dir c =
    match (c, dir) with
    | ('-', Direction.Left) -> Direction.Right
    | ('-', Direction.Right) -> Direction.Left
    | ('|', Direction.Up) -> Direction.Down
    | ('|', Direction.Down) -> Direction.Up
    | ('F', Direction.Right) -> Direction.Down
    | ('F', Direction.Down) -> Direction.Right
    | ('J', Direction.Up) -> Direction.Left
    | ('J', Direction.Left) -> Direction.Up
    | ('L', Direction.Up) -> Direction.Right
    | ('L', Direction.Right) -> Direction.Up
    | ('7', Direction.Down) -> Direction.Left
    | ('7', Direction.Left) -> Direction.Down
    | _ -> failwith $"whah {c} {dir} invalid"

let options =
    [ apply Direction.Right startX startY
      apply Direction.Up startX startY
      apply Direction.Left startX startY
      apply Direction.Down startX startY ]

let tick dir x y =
    index (x, y)
    |> Option.get
    |> proceed (opposite dir)
    |> (fun dir -> apply dir x y)

let rec loopLength dir x y =
    if (x, y) = (startX, startY) then
        0
    else
        let (dir', x', y') = tick dir x y
        1 + loopLength dir' x' y'

let inits =
    options |> List.filter (fun (dir, x, y) -> Option.isSome <| index (x, y))

let mysteryS =
    if inits.Length = 1 then
        match inits[0] with
        | Direction.Right, _, _ -> '-'
        | _ -> '|'
    else
        match (inits[0], inits[1]) with
        | (Direction.Right, _, _), (Direction.Up, _, _) -> '7'
        | (Direction.Right, _, _), (Direction.Down, _, _) -> 'J'
        | (Direction.Up, _, _), (Direction.Left, _, _) -> 'F'
        | (Direction.Down, _, _), (Direction.Left, _, _) -> 'L'
        | _ -> failwith "meow"

let (direction, x, y) = inits[0]

let part1 = (loopLength direction x y + 1) / 2

let rec mainPipe dir x y =
    if (x, y) = (startX, startY) then
        [ x, y ]
    else
        let (dir', x', y') = tick dir x y
        (x, y) :: mainPipe dir' x' y'

let mainPipeIndices = mainPipe direction x y |> Set.ofList

// slice from top 25% subpixel
let rec pipSlice x y inside =
    match index (x, y) with
    | None -> (0, 0)
    | Some c ->
        let c' = if c = 'S' then mysteryS else c

        if Set.contains (x, y) mainPipeIndices then
            let inside' =
                if (c' = '|' || c' = 'J' || c' = 'L') then
                    not inside
                else
                    inside

            pipSlice (x + 1) y inside'
        else
            let (outs, ins) = pipSlice (x + 1) y inside
            if inside then (outs, ins + 1) else (outs + 1, ins)

let part2 =
    [ 0..height ]
    |> List.map (fun y -> pipSlice 0 y false)
    |> List.sumBy (fun (outs, ins) -> ins)


printfn $"{part1} {part2}"

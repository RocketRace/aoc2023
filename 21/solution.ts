import { assert } from 'console'
import fs from 'fs'

const grid = fs.readFileSync("input", "utf-8").split("\n")

const sy = grid.findIndex(row => row.indexOf("S") >= 0)
const sx = grid[sy].indexOf("S")


const height = grid.length - 1 // ignore trailing empty line
const width = grid[0].length
assert(width == height)

type Index = readonly [number, number]

const inBounds = ([x, y]: Index) => x >= 0 && y >= 0 && x < width && y < height && grid[y][x] != "#"

const toI = ([x, y]: Index) => `${x},${y}`
const fromI = (i: string): Index => [+i.split(",")[0], +i.split(",")[1]]

function search(indices: Set<string>, step: number): Set<string> {
    if (step == 0) {
        return indices
    }
    let newIndices: string[] = []
    indices.forEach(i => {
        const [x, y] = fromI(i);
        ([
            [x + 1, y],
            [x - 1, y],
            [x, y + 1],
            [x, y - 1],
        ] as const).forEach(i => {
            if (inBounds(i)) {
                newIndices.push(toI(i))
            }
        });
    });
    return search(new Set(newIndices), step - 1)
}
console.log(search(new Set([toI([sx, sy])]), 64).size)

const maxSteps = 26501365
const rem = (x: number, y: number) => (x % y + y) % y
const inParallelUniverse = ([x, y]: Index) => grid[rem(y, height)][rem(x, width)] != "#"
function multisearch(limit: number) {
    let indices = new Set([toI([sx, sy])])
    for (let step = 0; step < limit; step++) {
        let newIndices = new Set<string>()
        indices.forEach(i => {
            const [x, y] = fromI(i);
            ([
                [x + 1, y],
                [x - 1, y],
                [x, y + 1],
                [x, y - 1],
            ] as const).forEach(i => {
                if (inParallelUniverse(i)) {
                    newIndices.add(toI(i))
                }
            });
        });
        indices = newIndices
    }
    return indices
}

const across = width
const toEdge = Math.floor(across / 2)

const y0 = multisearch(toEdge).size
const y1 = multisearch(toEdge + across).size
const y2 = multisearch(toEdge + across * 2).size

const c = y0 
const a = ((y2 - c) - 2 * (y1 - c)) / 2
const b = y1 - c - a

const f = (x: number) => a * x * x + b * x + c

const strides = (maxSteps - toEdge) / across
console.log(f(strides))

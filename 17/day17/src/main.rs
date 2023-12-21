use std::cell::RefCell;
use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap};
use std::fs;

struct Cell {
    pos: (usize, usize),
    loss: usize,
}

enum Part {
    One,
    Two,
}

#[derive(PartialEq, Eq, Clone, Copy, PartialOrd, Ord, Hash, Debug)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    loss: usize,
    id: Id,
}

#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash, Debug)]
struct Id {
    pos: (usize, usize),
    previous_move: Direction,
    straight_moves: usize,
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .loss
            .cmp(&self.loss)
            .then_with(|| self.id.cmp(&other.id))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

fn pathfind(
    grid: &[Vec<Cell>],
    start: (usize, usize),
    end: (usize, usize),
    part: Part,
) -> Option<usize> {
    // dist[node] = current shortest distance from `start` to `node`
    let mut distances: HashMap<Id, usize> = grid
        .iter()
        .flat_map(|row| {
            row.iter().flat_map(|cell| {
                (1..=match part {
                    Part::One => 3,
                    Part::Two => 10,
                })
                    .flat_map(|moves| {
                        [
                            Direction::Up,
                            Direction::Down,
                            Direction::Left,
                            Direction::Right,
                        ]
                        .map(|dir| {
                            (
                                Id {
                                    pos: cell.pos,
                                    previous_move: dir,
                                    straight_moves: moves,
                                },
                                usize::MAX,
                            )
                        })
                    })
            })
        })
        .collect();
    let mut heap = BinaryHeap::new();

    // required since part 2 doesn't otherwise allow more than one initial direction
    let dirs = match part {
        Part::One => vec![Direction::Right],
        Part::Two => vec![
            Direction::Right,
            Direction::Left,
            Direction::Up,
            Direction::Down,
        ],
    };
    for dir in dirs {
        distances.insert(
            Id {
                pos: start,
                previous_move: dir,
                straight_moves: 0,
            },
            0,
        );
        heap.push(State {
            loss: 0,
            id: Id {
                pos: start,
                straight_moves: 0,
                previous_move: dir,
            },
        });
    }

    while let Some(State {
        loss,
        id:
            id @ Id {
                pos,
                straight_moves,
                previous_move,
            },
    }) = heap.pop()
    {
        if pos == end {
            match part {
                Part::One => return Some(loss),
                Part::Two => {
                    if straight_moves >= 4 {
                        return Some(loss);
                    }
                }
            }
        }
        if loss > distances[&id] {
            continue;
        }

        let adjacents = RefCell::new(vec![]);

        let allow_up = |moves: usize| {
            if pos.1 > 0 {
                adjacents.borrow_mut().push(Id {
                    pos: (pos.0, pos.1 - 1),
                    previous_move: Direction::Up,
                    straight_moves: moves + 1,
                })
            }
        };
        let allow_down = |moves: usize| {
            if pos.1 < end.1 {
                adjacents.borrow_mut().push(Id {
                    pos: (pos.0, pos.1 + 1),
                    previous_move: Direction::Down,
                    straight_moves: moves + 1,
                })
            }
        };
        let allow_left = |moves: usize| {
            if pos.0 > 0 {
                adjacents.borrow_mut().push(Id {
                    pos: (pos.0 - 1, pos.1),
                    previous_move: Direction::Left,
                    straight_moves: moves + 1,
                })
            }
        };
        let allow_right = |moves: usize| {
            if pos.0 < end.0 {
                adjacents.borrow_mut().push(Id {
                    pos: (pos.0 + 1, pos.1),
                    previous_move: Direction::Right,
                    straight_moves: moves + 1,
                })
            }
        };

        match part {
            Part::One => match previous_move {
                Direction::Up => {
                    if straight_moves < 3 {
                        allow_up(straight_moves);
                    }
                    allow_left(0);
                    allow_right(0);
                }
                Direction::Down => {
                    if straight_moves < 3 {
                        allow_down(straight_moves);
                    }
                    allow_left(0);
                    allow_right(0);
                }
                Direction::Left => {
                    if straight_moves < 3 {
                        allow_left(straight_moves);
                    }
                    allow_up(0);
                    allow_down(0);
                }
                Direction::Right => {
                    if straight_moves < 3 {
                        allow_right(straight_moves);
                    }
                    allow_up(0);
                    allow_down(0);
                }
            },
            Part::Two => match previous_move {
                Direction::Up => {
                    if straight_moves < 4 {
                        allow_up(straight_moves);
                    } else {
                        if straight_moves < 10 {
                            allow_up(straight_moves);
                        }
                        allow_left(0);
                        allow_right(0);
                    }
                }
                Direction::Down => {
                    if straight_moves < 4 {
                        allow_down(straight_moves);
                    } else {
                        if straight_moves < 10 {
                            allow_down(straight_moves);
                        }
                        allow_left(0);
                        allow_right(0);
                    }
                }
                Direction::Left => {
                    if straight_moves < 4 {
                        allow_left(straight_moves);
                    } else {
                        if straight_moves < 10 {
                            allow_left(straight_moves);
                        }
                        allow_up(0);
                        allow_down(0);
                    }
                }
                Direction::Right => {
                    if straight_moves < 4 {
                        allow_right(straight_moves);
                    } else {
                        if straight_moves < 10 {
                            allow_right(straight_moves);
                        }
                        allow_up(0);
                        allow_down(0);
                    }
                }
            },
        }
        for &id @ Id { pos: (x, y), .. } in adjacents.borrow().iter() {
            let next = State {
                loss: loss + grid[y][x].loss,
                id,
            };

            if next.loss < distances[&id] {
                heap.push(next);
                distances.insert(id, next.loss);
            }
        }
    }
    None
}

fn main() {
    let grid = fs::read_to_string("../input")
        .expect("couldn't open ../input")
        .lines()
        .enumerate()
        .map(|(y, line)| {
            line.bytes()
                .enumerate()
                .map(|(x, b)| Cell {
                    pos: (x, y),
                    loss: (b - b'0') as usize,
                })
                .collect::<Vec<_>>()
        })
        .collect::<Vec<_>>();
    let start = (0, 0);
    let end = (grid[0].len() - 1, grid.len() - 1);
    match pathfind(&grid, start, end, Part::One) {
        Some(normal) => println!("normal loss: {normal}"),
        None => println!("no normal solution found"),
    }
    match pathfind(&grid, start, end, Part::Two) {
        Some(ultra) => println!("ultra loss: {ultra}"),
        None => println!("no ultra solution found"),
    }
}

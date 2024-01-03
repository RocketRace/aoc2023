#let grid = read("input").split("\n")
#let height = grid.len()
#let width = grid.at(0).len()
#let index(x, y) = str(y * width + x)
#let get(x, y) = if y >= 0 and grid.at(y, default: none) != none {
  if x >= 0 and grid.at(y).at(x, default: none) != none {
    grid.at(y).at(x)
  }
  else {none}
} else {none}

#let tick(energized, beams, repeats) = {
  let new = ()
  for (x, y, dir) in beams {
    let (newX, newY, straight, backward, forward, splitter, nonsplitter) = if dir == "R" {
      //  point, ".", "\", "/"
      (x + 1, y, "R", "D", "U", "|", "-")
    } else if dir == "L" {
      (x - 1, y, "L", "U", "D", "|", "-")
    } else if dir == "U" {
      (x, y - 1, "U", "L", "R", "-", "|")
    } else if dir == "D" {
      (x, y + 1, "D", "R", "L", "-", "|")
    }
    let c = get(newX, newY)
    if c != none {
      let repeated = repeats.at(index(newX, newY) + dir, default: none)
      if repeated == none {
        energized.insert(index(newX, newY), true)
        repeats.insert(index(newX, newY) + dir, true)
        if c == "." or c == nonsplitter {
          new.push((newX, newY, straight))
        }
        else if c == "\\" {
          new.push((newX, newY, backward))
        }
        else if c == "/" {
          new.push((newX, newY, forward))
        }
        else if c == splitter {
          new.push((newX, newY, backward))
          new.push((newX, newY, forward))
        }
      }
    }
  }
  (energized, new, repeats)
}

#let stabilize(x, y, dir) = {
  let energized = (index(x, y): true)
  let repeats = (index(x, y) + dir: true)
  let beams = ((x, y, dir),)
  while beams.len() > 0 {
    (energized, beams, repeats) = tick(energized, beams, repeats)
  }
  let size = energized.len()
  energized = (:)
  repeats = (:)
  beams = ()
  size
}

Part 1: #stabilize(0, 0, "R")

#let maximum = 0
  
#for y in range(height) {
  // maximum = calc.max(maximum, stabilize(0, y, "R"))
  // yields 8078
  // maximum = calc.max(maximum, stabilize(width - 1, y, "L"))
  // yields 8183
}
#for x in range(width) {
  // maximum = calc.max(maximum, stabilize(x, 0, "D"))
  // yields 8181
  // maximum = calc.max(maximum, stabilize(x, height - 1, "U"))
  // yields 7649
}
Part 2: 8183

import scala.language.strictEquality

import scala.collection.mutable
// import java.time.Instant
// import java.time.Duration

case class Point(x: Int, y: Int) derives CanEqual:
  override def toString(): String = s"Point($x, $y)"
  override def equals(p: Any): Boolean =
    if p.isInstanceOf[Point] then
      val q = p.asInstanceOf[Point]
      q.x == x && q.y == y
    else false

  def +(p: Point): Point = Point(x + p.x, y + p.y)

class Grid(private val data: Seq[String]):
  def get(p: Point): Option[Char] =
    data.lift(p.y).flatMap(_.lift(p.x))

  def apply(p: Point): Char = get(p).get
  def exists(p: Point): Boolean = get(p).isDefined

  val height = data.length
  val width = data(0).length()

  def adjacents(p: Point): Seq[Point] =
    Seq(
      p + Point(1, 0),
      p + Point(-1, 0),
      p + Point(0, 1),
      p + Point(0, -1)
    ).filter(q => exists(q) && this(q) != '#')

  def freeAdjacents(p: Point): Seq[Point] =
    Seq(
      (p + Point(1, 0), '>'),
      (p + Point(-1, 0), '<'),
      (p + Point(0, 1), 'v'),
      (p + Point(0, -1), '^')
    )
      .filter { case (q, c) => exists(q) && (this(q) == '.' || this(q) == c) }
      .map(_._1)

  val points: Iterable[Point] =
    (0 until height).flatMap(y => (0 until width).map(x => Point(x, y)))

  val nodes: Set[Point] =
    Set.from(
      points
        .filter(p =>
          val adj = adjacents(p)
          this(p) == '.' && adj.size != 2 || adj
            .map(this(_))
            .exists("<>^v" contains _)
        )
    )

  def pathsFrom(p: Point, sliding: Boolean): Seq[(Point, Int)] =
    if !nodes.contains(p) then throw new Exception
    val nexts = if sliding then freeAdjacents(p) else adjacents(p)
    for next <- nexts yield
      var previous = p
      var current = next
      var steps = 1
      while !nodes.contains(current) do
        val adj = adjacents(current).filterNot(_ == previous)
        previous = current
        current = adj(0)
        steps += 1
      (current, steps)

  def pathLengths(
      edges: Map[Point, Map[Point, Int]],
      start: Point,
      end: Point
  ): List[Int] =
    var stack = mutable.Stack((start, 0, Set(start)))
    var paths = List[Int]()
    // var ticker = 0
    // val timer = Instant.now()
    while stack.nonEmpty do
      val (node, steps, visited) = stack.pop()
      if node == end then paths ::= steps
      else
        for (connection, extraSteps) <- edges(node) do
          if !visited.contains(connection) then
            stack.push((connection, steps + extraSteps, visited + connection))
      // ticker += 1
      // if ticker % 1000000 == 0 then println(s"tick ${stack.size}")
    // val elapsed = Duration.between(timer, Instant.now()).toMillis()
    // println(
    //   s"$ticker states visited in $elapsed ms"
    // )
    paths

@main def main: Unit =
  val grid = Grid(os.read(os.pwd / "input").split("\n"))
  val start = Point(1, 0)
  val end = Point(grid.width - 2, grid.height - 1)
  val slidingEdges =
    Map.from(
      grid.nodes.toSeq.map(p => (p, Map.from(grid.pathsFrom(p, true))))
    )
  val part1 = grid.pathLengths(slidingEdges, start, end).max
  println(part1)
  val frictionEdges =
    Map.from(
      grid.nodes.toSeq.map(p => (p, Map.from(grid.pathsFrom(p, false))))
    )
  val part2 = grid.pathLengths(frictionEdges, start, end).max
  println(part2)

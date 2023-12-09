def peel(onion : Array(Int32), part1 : Bool) : Int32
  if onion.all? { |num| num == 0 }
    return 0
  else
    diffs = [] of Int32
    onion.each_cons_pair do |l, r|
      diffs.push(r - l)
    end
    if part1
      return onion.last + peel(diffs, part1)
    else
      return onion.first - peel(diffs, part1)
    end
  end
end

content = File.open("input") do |file|
  file.gets_to_end
end

onions = content.split("\n").map { |line| line.split.map { |chunk| chunk.to_i32 } }
puts onions.map { |onion| peel(onion, true) }.sum
puts onions.map { |onion| peel(onion, false) }.sum

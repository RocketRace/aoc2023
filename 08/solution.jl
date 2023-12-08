path_str, _, rules_str... = readlines(open("input"))

path = [c == 'R' for c in path_str]
@views rules = Dict(map(s -> (s[1:3], (s[8:10], s[13:15])), rules_str))

function part1()
    state = "AAA"
    i = 0
    while true
        new_state = rules[state][path[i%length(path)+1]+1]
        i += 1

        if new_state == "ZZZ"
            return i
        else
            state = new_state
        end
    end
end

println(part1())

zs = []
for (initial_state, _) in [(from, to) for (from, to) in rules if endswith(from, "A")]
    i = 0
    visited = Set([(initial_state, i)])
    journey = [(initial_state, i)]
    state = initial_state
    while true
        new_state = rules[state][path[i%length(path)+1]+1]
        i += 1

        if (new_state, i % length(path)) in visited
            z = first(findall(x -> endswith(x[1], "Z"), journey)) - 1
            push!(zs, z)
            break
        else
            push!(journey, (new_state, i % length(path)))
            push!(visited, (new_state, i % length(path)))
            state = new_state
        end
    end
end

# assume there's only 1 z index (there only is one z index (it's day 9 (the inputs are easy)))
# assume all the z indices are hit at a constant amount of time after the loop scale
# assume all the loops are entered at step 0
# really, this whole thing works off of mega amounts of assumptions
println(lcm([BigInt(z) for z in zs]))

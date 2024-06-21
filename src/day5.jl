include("utils.jl")

struct MappingRange
  dest::Int
  src::Int
  len::Int
end

struct Mapping
  to::String
  ranges::Vector{MappingRange}
end

struct Data
  seeds::Vector{Int}
  maps::Dict{String, Mapping}
end

function parse_input(input)
  seeds = []
  maps = Dict{String, Mapping}()
  current_mapping = nothing
  for l in Utils.lines(input)
    seeds_matched = match(r"seeds: (.+)$", l)
    if !isnothing(seeds_matched)
      seeds = map(eachsplit(seeds_matched.captures[1])) do x parse(Int, x) end
      continue
    end
    map_start_matched = match(r"(.+)-to-(.+) map:", l)
    if !isnothing(map_start_matched)
      from, to = map_start_matched
      current_mapping = Mapping(to, [])
      maps[from] = current_mapping
      continue
    end
    range_matched = match(r"(\d+) (\d+) (\d+)", l)
    if !isnothing(range_matched)
      dest, src, len = map(range_matched) do x parse(Int, x) end
      push!(current_mapping.ranges, MappingRange(dest, src, len))
    end
  end
  Data(seeds, maps)
end

function part1((; seeds, maps)::Data)
  numbers = copy(seeds)
  mapping = maps["seed"]
  while true
    map!(numbers, numbers) do n
      for (; dest, src, len) in mapping.ranges
        if src <= n < src + len
          return n + (dest - src)
        end
      end
      n
    end
    if mapping.to == "location" break end
    mapping = maps[mapping.to]
  end
  minimum(numbers)
end

function part2((; seeds, maps)::Data)
  ranges = []
  for i in 1:2:length(seeds)
    push!(ranges, (seeds[i], seeds[i+1]))
  end
  mapping = maps["seed"]
  while true
    mapped_ranges = []
    for r in ranges
      avail_ranges = [r]
      for m in mapping.ranges
        for (i, (a_start, a_len)) in enumerate(avail_ranges)
          a_end = a_start + a_len - 1
          m_start, m_end = m.src, m.src + m.len - 1
          if !(a_end >= m_start && a_start <= m_end) continue end
          b_start = max(m_start, a_start)
          b_end = min(m_end, a_end)
          deleteat!(avail_ranges, i)
          shift = m.dest - m.src
          push!(mapped_ranges, (shift + b_start, b_end - b_start + 1))
          if b_start > a_start
            push!(avail_ranges, (a_start, b_start - a_start))
          end
          if b_end < a_end
            push!(avail_ranges, (b_end + 1, a_end - b_end))
          end
        end
      end
      append!(mapped_ranges, avail_ranges)
    end
    ranges = mapped_ranges
    if mapping.to == "location" break end
    mapping = maps[mapping.to]
  end
  minimum(map(first, ranges))
end

example = parse_input("""
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """)
println("[Example p1] $(part1(example))") # 35
println("[Example p2] $(part2(example))") # 46

data = parse_input(Utils.readday(5))
println("[Part 1] $(part1(data))") # 331445006
println("[Part 2] $(part2(data))") # 6472060

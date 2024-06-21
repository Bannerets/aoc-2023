include("utils.jl")

parse_cube_amount(m) = isnothing(m) ? 0 : parse(Int, m.captures[1])

function parse_input(input)
  games = []
  for l in Utils.lines(input)
    id, descr = match(r"Game (\d+): (.*)$", l)
    sets = []
    for set in eachsplit(descr, r";", keepempty=false)
      red = parse_cube_amount(match(r"(\d+) red", set))
      green = parse_cube_amount(match(r"(\d+) green", set))
      blue = parse_cube_amount(match(r"(\d+) blue", set))
      push!(sets, (red, green, blue))
    end
    push!(games, (parse(Int, id), sets))
  end
  games
end

function part1(games)
  red_limit, green_limit, blue_limit = 12, 13, 14
  id_sum = 0
  for (id, sets) in games
    failed = false
    for (red, green, blue) in sets
      if red > red_limit || green > green_limit || blue > blue_limit
        failed = true
        break
      end
    end
    if !failed id_sum += id end
  end
  id_sum
end

function part2(games)
  power_sum = 0
  for (_, sets) in games
    red_max, green_max, blue_max = 0, 0, 0
    for (red, green, blue) in sets
      red_max = max(red_max, red)
      green_max = max(green_max, green)
      blue_max = max(blue_max, blue)
    end
    power = red_max * green_max * blue_max
    power_sum += power
  end
  power_sum
end


example = parse_input("""
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """)
println("[Example p1] $(part1(example))") # 8
println("[Example p2] $(part2(example))") # 2286

data = parse_input(Utils.readday(2))
println("[Part 1] $(part1(data))") # 2505
println("[Part 2] $(part2(data))") # 70265

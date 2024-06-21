include("utils.jl")

function neighbors((y, x_start), len)
  res = []
  push!(res, (y - 1, x_start - 1), (y, x_start - 1), (y + 1, x_start - 1))
  for x in x_start:(x_start + len - 1)
    push!(res, (y - 1, x), (y + 1, x))
  end
  push!(res, (y - 1, x_start + len), (y, x_start + len), (y + 1, x_start + len))
  res
end

function part1(schematic)
  m = collect(Utils.lines(schematic))
  max_c = length(m[1])
  is_symbol((y, x)) =
    (1 <= y <= length(m) && 1 <= x <= max_c) &&
      m[y][x] != '.' && m[y][x] != ' '
  sum = 0
  for y in eachindex(m)
    row = m[y]
    number = ""
    for x in 1:(length(row) + 1)
      if x <= length(row) && isdigit(row[x])
        number *= row[x]
      elseif length(number) > 0
        x_start = x - length(number)
        if any(is_symbol, neighbors((y, x_start), length(number)))
          sum += parse(Int, number)
        end
        number = ""
      end
    end
  end
  sum
end


function part2(schematic)
  m = collect(Utils.lines(schematic))
  max_c = length(m[1])
  function find_whole_number((y, start_x))
    number_string = ""
    x = start_x
    while 1 <= x <= max_c && isdigit(m[y][x])
      number_string = m[y][x] * number_string
      x -= 1
    end
    x = start_x + 1
    while x <= max_c && isdigit(m[y][x])
      number_string *= m[y][x]
      x += 1
    end
    parse(Int, number_string)
  end
  sum = 0
  for y in eachindex(m)
    for x in eachindex(m[y])
      if m[y][x] != '*' continue end
      f((y, x)) = 1 <= y <= length(m) && 1 <= x <= max_c && isdigit(m[y][x])
      numbers = unique(map(find_whole_number, filter(f, neighbors((y, x), 1))))
      if length(numbers) == 2
        sum += numbers[1] * numbers[2]
      end
    end
  end
  sum
end

example = """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...\$.*....
  .664.598..
  """
println("[Example p1] $(part1(example))") # 4361
println("[Example p2] $(part2(example))") # 467835

data = Utils.readday(3)
println("[Part 1] $(part1(data))") # 527364
println("[Part 2] $(part2(data))") # 79026871

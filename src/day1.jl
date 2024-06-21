include("utils.jl")

function part1(input)
  sum::Int64 = 0
  for l in Utils.lines(input)
    first, last, single = match(r"(\d).*(\d)|(\d)", l)
    if !isnothing(single) first, last = single, single end
    sum += parse(Int, "$(first)$(last)")
  end
  sum
end

function parse_digit(s)
  if s == "one" 1
  elseif s == "two" 2
  elseif s == "three" 3
  elseif s == "four" 4
  elseif s == "five" 5
  elseif s == "six" 6
  elseif s == "seven" 7
  elseif s == "eight" 8
  elseif s == "nine" 9
  else parse(Int, s)
  end
end

function part2(input)
  sum::Int64 = 0
  for l in Utils.lines(input)
    first, last, single = match(r"(\d|one|two|three|four|five|six|seven|eight|nine).*(\d|one|two|three|four|five|six|seven|eight|nine)|(\d|one|two|three|four|five|six|seven|eight|nine)", l)
    if !isnothing(single) first, last = single, single end
    sum += parse_digit(first) * 10 + parse_digit(last)
  end
  sum
end

p1_example = """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """
p2_example = """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """
println("[Example p1] $(part1(p1_example))") # 142
println("[Example p2] $(part2(p2_example))") # 281

data = Utils.readday(1)
println("[Part 1] $(part1(data))") # 54159
println("[Part 2] $(part2(data))") # 53866

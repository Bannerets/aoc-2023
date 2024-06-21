include("utils.jl")

struct Point3
  x::Int16
  y::Int16
  z::Int16
end

mutable struct Brick
  from::Point3
  to::Point3
  supported_by::Vector{Brick}
  supports::Vector{Brick}
end

# function print_brick(b::Brick)
#   println("$(b.from.x),$(b.from.y),$(b.from.z)~$(b.to.x),$(b.to.y),$(b.to.z)")
# end

function move_down!(b::Brick; by = 1)
  if by < 0 error("Cannot move upwards") end
  b.from = Point3(b.from.x, b.from.y, b.from.z - by)
  b.to = Point3(b.to.x, b.to.y, b.to.z - by)
end

function xy_overlap(a::Brick, b::Brick)::Bool
  x_overlaps = max(a.from.x, b.from.x) <= min(a.to.x, b.to.x)
  y_overlaps = max(a.from.y, b.from.y) <= min(a.to.y, b.to.y)
  x_overlaps && y_overlaps
end

function simulate_gravity!(bricks::Vector{Brick})
  for b in bricks
    z = 1
    for b2 in bricks
      if b2.from.z >= b.from.z break end
      if b2.from.z >= b.to.z || b == b2 continue end
      if xy_overlap(b, b2)
        z = max(z, b2.to.z + 1)
      end
    end
    move_down!(b; by = b.from.z - z)
  end
end

function parse_input(input)
  bricks = Brick[]
  for l in Utils.lines(input)
    x1, y1, z1, x2, y2, z2 = match(r"(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)", l)
    p1 = Point3(parse(Int16, x1), parse(Int16, y1), parse(Int16, z1))
    p2 = Point3(parse(Int16, x2), parse(Int16, y2), parse(Int16, z2))
    @assert x1 <= x2 && y1 <= y2 && z1 <= z2
    push!(bricks, Brick(p1, p2, [], []))
  end
  sort!(bricks; by=(b -> b.from.z))
  simulate_gravity!(bricks)
  for b in bricks
    for b2 in bricks
      if b2.from.z != b.to.z + 1 || !xy_overlap(b, b2) || b == b2 continue end
      # b supports b2
      push!(b.supports, b2)
      push!(b2.supported_by, b)
    end
  end
  bricks
end

function part1(bricks)
  possible_disintegrations = 0
  for b in bricks
    for b_above in b.supports
      if length(b_above.supported_by) < 2
        # not supported by any other brick
        @goto cannot_disintegrate
      end
    end
    possible_disintegrations += 1
    @label cannot_disintegrate
  end
  possible_disintegrations
end

function chain_reaction(starting_brick::Brick)
  falling_bricks = Set{Brick}()
  stack = Brick[]
  push!(stack, starting_brick)
  while !isempty(stack)
    b = pop!(stack)
    for b_above in b.supports
      for b2 in b_above.supported_by
        if b2 in falling_bricks || b == b2 continue end
        # b_above is also supported by bricks other than b and will not fall
        @goto supported_by_other
      end
      push!(falling_bricks, b_above)
      push!(stack, b_above)
      @label supported_by_other
    end
  end
  length(falling_bricks)
end

part2(bricks) = reduce(+, chain_reaction(b) for b in bricks)

example = parse_input("""
  1,0,1~1,2,1
  0,0,2~2,0,2
  0,2,3~2,2,3
  0,0,4~0,2,4
  2,0,5~2,2,5
  0,1,6~2,1,6
  1,1,8~1,1,9
  """)
println("[Example p1] $(part1(example))") # 5
println("[Example p2] $(part2(example))") # 7

data = parse_input(Utils.readday(22))
@time println("[Part 1] $(part1(data))") # 463
@time println("[Part 2] $(part2(data))") # 89727

include("utils.jl")

using LinearAlgebra
using Printf

struct Point3
  x::Int64
  y::Int64
  z::Int64
end

to_tuples((p, v)::Tuple{Point3,Point3}) =
  (BigInt.((p.x, p.y, p.z)), BigInt.((v.x, v.y, v.z)))

×(
  (a1, b1, c1)::Tuple{BigInt,BigInt,BigInt},
  (a2, b2, c2)::Tuple{BigInt,BigInt,BigInt}
) = Tuple(LinearAlgebra.cross([a1; b1; c1], [a2; b2; c2]))

function parse_input(input)
  result = []
  for l in Utils.lines(input)
    hs = Tuple(map(s -> parse(Int64, s), split(l, r", | @ ")))
    (px, py, pz, vx, vy, vz) = hs
    push!(result, (Point3(px, py, pz), Point3(vx, vy, vz)))
  end
  result
end

function part1(hailstones, areamin=200000000000000, areamax=400000000000000)
  intersections = 0
  for i in eachindex(hailstones)
    for j in (i + 1):length(hailstones)
      # (x, y) = (px + vx * t, py + vy * t)
      # y = f(x) = py + vy/vx * (x - px)
      (p1, v1) = hailstones[i]
      (p2, v2) = hailstones[j]
      # finding the function intersection
      x = (p2.y - p1.y + v1.y*p1.x/v1.x - v2.y*p2.x/v2.x) / (v1.y/v1.x - v2.y/v2.x)
      y = p1.y + v1.y/v1.x * (x - p1.x)
      # turns out we also need to check that the intersection is in the future
      not_in_past = sign(x - p1.x) == sign(v1.x) && sign(x - p2.x) == sign(v2.x)
      if areamin <= x <= areamax && areamin <= y <= areamax && not_in_past
        intersections += 1
      end
    end
  end
  intersections
end

function part2(hailstones)
  # this is based on a reddit comment...
  (hs0_p, hs0_v) = to_tuples(hailstones[1])
  (hs1_p, hs1_v) = to_tuples(hailstones[2])
  (hs2_p, hs2_v) = to_tuples(hailstones[3])
  p1 = hs1_p .- hs0_p
  v1 = hs1_v .- hs0_v
  p2 = hs2_p .- hs0_p
  v2 = hs2_v .- hs0_v
  t1 = BigFloat.(0 .- ((p1 × p2) ⋅ v2)) ./ ((v1 × p2) ⋅ v2)
  t2 = BigFloat.(0 .- ((p1 × p2) ⋅ v1)) ./ ((p1 × v2) ⋅ v1)
  c1 = hs1_p .+ t1 .* hs1_v
  c2 = hs2_p .+ t2 .* hs2_v
  v = (c2 .- c1) ./ (t2 .- t1)
  p = c1 .- t1 .* v
  @sprintf("%.15f", reduce(+, p))
end

example = parse_input("""
  19, 13, 30 @ -2, 1, -2
  18, 19, 22 @ -1, -1, -2
  20, 25, 34 @ -2, -2, -4
  12, 31, 28 @ -1, -2, -1
  20, 19, 15 @ 1, -5, -3
  """)
println("[Example p1] $(part1(example, 7, 27))") # 2
println("[Example p2] $(part2(example))") # 47

data = parse_input(Utils.readday(24))
@time println("[Part 1] $(part1(data))") # 27328
@time println("[Part 2] $(part2(data))") # 722976491652740

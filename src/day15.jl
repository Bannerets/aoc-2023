include("utils.jl")

function calc_hash(string)
  result = 0
  for ch in string
    (ch == '\n' || ch == '\r') && continue
    result += Int(ch)
    result *= 17
    result %= 256
  end
  result
end

part1(input) =
  reduce(+, calc_hash(s) for s in eachsplit(input, ','; keepempty=false))

function part2(input)
  boxes = [Tuple{String,Int}[] for _ in 0:255]
  for step in eachsplit(input, ','; keepempty=false)
    label, focal_length = match(r"(.+?)(?:=|-)(\d+)?", step)
    box = boxes[calc_hash(label) + 1]
    lens_i = findfirst(((lbl, _),) -> lbl == label, box)
    if isnothing(focal_length)
      if !isnothing(lens_i) deleteat!(box, lens_i) end
    elseif isnothing(lens_i)
      push!(box, (label, parse(Int, focal_length)))
    else
      box[lens_i] = (label, parse(Int, focal_length))
    end
  end
  reduce(+,
    box_i * lens_i * focal_length
      for (box_i, box) in enumerate(boxes)
       for (lens_i, (_, focal_length)) in enumerate(box);
    init=0)
end

example = """
  rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
  """
println("[Example p1] $(part1(example))") # 1320
println("[Example p2] $(part2(example))") # 145

data = Utils.readday(15)
println("[Part 1] $(part1(data))") # 505427
println("[Part 2] $(part2(data))") # 243747

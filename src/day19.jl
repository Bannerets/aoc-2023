include("utils.jl")

struct Condition
  cat::Char
  op::Char
  value::Int
end

struct Rule
  condition::Union{Nothing,Condition}
  action::String # can be workflow name or "A" or "R"
end

struct Workflow
  rules::Vector{Rule}
end

struct Part
  ratings::Dict{Char,Int}
end

const Data = Tuple{Dict{String,Workflow}, Vector{Part}}

function parse_input(input)::Data
  workflows = Dict{String,Workflow}()
  parts = Part[]
  for l in Utils.lines(input)
    workflow_match = match(r"(\w+){(.*)}", l)
    if !isnothing(workflow_match)
      name, rules_str = workflow_match
      rules = Rule[]
      for rulestr in eachsplit(rules_str, ','; keepempty=false)
        res = split(rulestr, ':'; keepempty=false)
        if length(res) >= 2
          cat, op, value = match(r"(\w)([<>])(\d+)", res[begin])
          cond = Condition(cat[begin], op[begin], parse(Int, value))
          push!(rules, Rule(cond, res[begin + 1]))
        else
          push!(rules, Rule(nothing, res[end]))
        end
      end
      workflows[name] = Workflow(rules)
    else
      partstr, = match(r"{(.+=.+)}", l)
      ratings = Dict{Char,Int}()
      for ratingstr in eachsplit(partstr, ','; keepempty=false)
        category, rating = match(r"(.+)=(\d+)", ratingstr)
        ratings[category[begin]] = parse(Int, rating)
      end
      push!(parts, Part(ratings))
    end
  end
  workflows, parts
end

function part1((workflows, parts)::Data)
  result = 0
  for (; ratings) in parts
    next_workflow = "in"
    accept = false
    while !isempty(next_workflow)
      for (; condition, action) in workflows[next_workflow].rules
        if !isnothing(condition)
          (; cat, op, value) = condition
          cur_value = ratings[cat]
          success = op == '>' ? cur_value > value : cur_value < value
          if !success continue end
          # If success, execute the action (otherwise, try next rule)
        end
        if action == "A" || action == "R"
          accept = action == "A"
          next_workflow = ""
        else
          next_workflow = action
        end
        break
      end
    end
    if accept
      result += reduce(+, values(ratings))
    end
  end
  result
end

struct RatingRanges
  x::Tuple{Int,Int}
  m::Tuple{Int,Int}
  a::Tuple{Int,Int}
  s::Tuple{Int,Int}
end

combinations(p::RatingRanges) =
  max(0, p.x[2] - p.x[1] + 1) *
  max(0, p.m[2] - p.m[1] + 1) *
  max(0, p.a[2] - p.a[1] + 1) *
  max(0, p.s[2] - p.s[1] + 1)

function apply(r::RatingRanges, (; cat, op, value)::Condition)
  function spl((a, b)::Tuple{Int,Int})
    if op == '>'
      # > and <=
      ((value + 1, b), (a, value))
    else
      # < and >=
      ((a, value - 1), (value, b))
    end
  end
  if cat == 'x'
    map(spl(r.x)) do v RatingRanges(v, r.m, r.a, r.s) end
  elseif cat == 'm'
    map(spl(r.m)) do v RatingRanges(r.x, v, r.a, r.s) end
  elseif cat == 'a'
    map(spl(r.a)) do v RatingRanges(r.x, r.m, v, r.s) end
  elseif cat == 's'
    map(spl(r.s)) do v RatingRanges(r.x, r.m, r.a, v) end
  else error("Invalid category $cat") end
end

function part2((workflows, _)::Data)
  result = 0
  function execute(r_init::RatingRanges, workflow::String)
    r = r_init
    next_workflow = workflow
    while !isempty(next_workflow)
      for (; condition, action) in workflows[next_workflow].rules
        if !isnothing(condition)
          res = apply(r, condition)
          # Succeed range
          if action == "A"
            result += combinations(res[1])
          elseif action != "R"
            # Fork execution
            execute(res[1], action)
          end
          # Failed range
          r = res[2]
          continue
        end
        if action == "A"
          result += combinations(r)
          return
        elseif action == "R"
          return
        else
          next_workflow = action
        end
        break
      end
    end
  end
  default_ranges = RatingRanges((1, 4000), (1, 4000), (1, 4000), (1, 4000))
  execute(default_ranges, "in")
  result
end

example = parse_input("""
  px{a<2006:qkq,m>2090:A,rfg}
  pv{a>1716:R,A}
  lnx{m>1548:A,A}
  rfg{s<537:gd,x>2440:R,A}
  qs{s>3448:A,lnx}
  qkq{x<1416:A,crn}
  crn{x>2662:A,R}
  in{s<1351:px,qqz}
  qqz{s>2770:qs,m<1801:hdj,R}
  gd{a>3333:R,R}
  hdj{m>838:A,pv}

  {x=787,m=2655,a=1222,s=2876}
  {x=1679,m=44,a=2067,s=496}
  {x=2036,m=264,a=79,s=2244}
  {x=2461,m=1339,a=466,s=291}
  {x=2127,m=1623,a=2188,s=1013}
  """)
println("[Example p1] $(part1(example))") # 19114
println("[Example p2] $(part2(example))") # 167409079868000

data = parse_input(Utils.readday(19))
@time println("[Part 1] $(part1(data))") # 409898
@time println("[Part 2] $(part2(data))") # 113057405770956

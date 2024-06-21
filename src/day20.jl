include("utils.jl")

@enum Pulse::Int8 low high

mutable struct FlipFlop
  name::String
  state::Bool
end
FlipFlop(name) = FlipFlop(name, false)

struct Conjuction
  name::String
  state::Dict{String,Pulse}
end
Conjuction(name) = Conjuction(name, Dict{String,Pulse}())

struct Broadcast
  name::String
end

const Mod = Union{FlipFlop,Conjuction,Broadcast}

reset(m::FlipFlop) = (m.state = false; m)
reset(m::Conjuction) = (empty!(m.state); m)
reset(m::Broadcast) = m

struct Data
  modules::Dict{String,Mod}
  outputs::Dict{String,Vector{String}}
  inputs::Dict{String,Vector{String}}
end

function receive(m::Mod, p::Pulse, from::String; inputs::Vector{String})::Union{Nothing,Pulse}
  if typeof(m) == FlipFlop
    if p == high return nothing end
    m.state = !m.state
    m.state ? high : low
  elseif typeof(m) == Conjuction
    m.state[from] = p
    for inp in inputs
      if !haskey(m.state, inp) return high end
      if m.state[inp] == low return high end
    end
    low
  elseif typeof(m) == Broadcast
    p
  else error("Invalid module") end
end

function parse_input(input)
  modules = Dict{String,Mod}()
  outputs = Dict{String,Vector{String}}()
  inputs = Dict{String,Vector{String}}()
  for l in Utils.lines(input)
    part1, part2 = eachsplit(l, " -> ")
    m =
      if part1 == "broadcaster" Broadcast(part1)
      elseif part1[begin] == '%' FlipFlop(part1[begin+1:end])
      elseif part1[begin] == '&' Conjuction(part1[begin+1:end])
      else error("Invalid input") end
    modules[m.name] = m
    outputs[m.name] = split(part2, ", "; keepempty=false)
    for out in outputs[m.name]
      if haskey(inputs, out)
        push!(inputs[out], m.name)
      else
        inputs[out] = String[m.name]
      end
    end
  end
  Data(modules, outputs, inputs)
end

function simulate((; modules, outputs, inputs)::Data; until=nothing)
  for m in values(modules) reset(m) end
  low_pulses = 0
  high_pulses = 0
  for b in 1:(isnothing(until) ? 1000 : typemax(Int))
    low_pulses += 1 # button -low-> broadcaster
    actions = Tuple{String,Pulse}[("broadcaster", low)]
    while !isempty(actions)
      inname, pulse = popfirst!(actions)
      for outname in outputs[inname]
        if pulse == low; low_pulses += 1 else high_pulses += 1 end
        if !isnothing(until) && pulse == low && outname == until return b end
        if !haskey(modules, outname) continue end
        out = modules[outname]
        nextpulse = receive(out, pulse, inname; inputs=inputs[outname])
        if !isnothing(nextpulse)
          push!(actions, (outname, nextpulse))
        end
      end
    end
  end
  low_pulses * high_pulses
end

part1(data) = simulate(data)

function output_graphviz((; modules, outputs, inputs)::Data)
  println("digraph G {")
  visited = Set{String}()
  function print_line(name, depth)
    if name in visited return end
    push!(visited, name)
    if !haskey(inputs, name) return end
    for input in inputs[name]
      symbol = typeof(modules[input]) == Conjuction ? "&" : "+"
      println("  $input -> $name [label=\"$symbol $depth\"]")
      print_line(input, depth + 1)
    end
  end
  print_line("rx", 0)
  println("}")
end

function part2(data::Data)
  (; inputs) = data
  # printing the graph is nice. there are 4 binary counters.
  # output_graphviz(data)
  cycle_ends = inputs[inputs["rx"][begin]]
  if length(cycle_ends) != 4
    error("Expected 4 cycles, got $(length(cycle_ends)) ($cycle_ends)")
  end
  results = map(x -> simulate(data; until=x), cycle_ends)
  @show results
  lcm(results...)
end

example1 = parse_input("""
  broadcaster -> a, b, c
  %a -> b
  %b -> c
  %c -> inv
  &inv -> a
  """)
example2 = parse_input("""
  broadcaster -> a
  %a -> inv, con
  &inv -> b
  %b -> con
  &con -> output
  """)
println("[Example p1 (1)] $(part1(example1))") # 32000000
println("[Example p1 (2)] $(part1(example2))") # 11687500

data = parse_input(Utils.readday(20))
@time println("[Part 1] $(part1(data))") # 834323022
@time println("[Part 2] $(part2(data))") # 225386464601017

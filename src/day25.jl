include("utils.jl")

mutable struct Node
  name::String
  conns::Vector{Node}
end

function disconnect!(a::Node, b::Node)
  for (i, n) in enumerate(a.conns)
    if n == b
      deleteat!(a.conns, i)
      break
    end
  end
  for (i, n) in enumerate(b.conns)
    if n == a
      deleteat!(b.conns, i)
      break
    end
  end
end

function parse_input(input)
  nodes = Dict{String,Node}()
  for l in Utils.lines(input)
    (k, vs_raw) = eachsplit(l, ": ")
    vs = split(vs_raw)
    local k_node
    if haskey(nodes, k)
      k_node = nodes[k]
    else
      k_node = Node(k, Node[])
      nodes[k] = k_node
    end
    for v in vs
      local v_node
      if haskey(nodes, v)
        v_node = nodes[v]
        push!(v_node.conns, k_node)
      else
        v_node = Node(v, [k_node])
        nodes[v] = v_node
      end
      push!(k_node.conns, v_node)
    end
  end
  nodes
end

function print_graphviz(nodes)
  println("graph G {")
  printed = Set{Tuple{Node,Node}}()
  for n1 in values(nodes)
    for n2 in n1.conns
      if (n1, n2) in printed || (n2, n1) in printed; continue end
      push!(printed, (n1, n2))
      a, b = n1.name, n2.name
      println("  $a -- $b [label=\"$a-$b\"];")
    end
  end
  println("}")
end

function count_graph_size(starting_node::Node)
  visited = Set{Node}()
  stack = Node[starting_node]
  while !isempty(stack)
    node = pop!(stack)
    push!(visited, node)
    for neighbor in node.conns
      if neighbor in visited continue end
      push!(stack, neighbor)
    end
  end
  length(visited)
end

function part1(nodes)
  # print_graphviz(nodes)
  # well, the connections are manually entered based on
  # the graphviz (sfdp seems to work) visualization...
  to_delete = [
    ["fvm", "ccp"],
    ["llm", "lhg"],
    ["thx", "frl"]
  ]
  for (a, b) in to_delete
    n1 = nodes[a]
    for n2 in n1.conns
      if n2.name == b
        disconnect!(n1, n2)
        break
      end
    end
  end
  n1, n2 = nodes[to_delete[1][1]], nodes[to_delete[1][2]]
  count_graph_size(n1) * count_graph_size(n2)
end

example = parse_input("""
  jqt: rhn xhk nvd
  rsh: frs pzl lsr
  xhk: hfx
  cmg: qnr nvd lhk bvb
  rhn: xhk bvb hfx
  bvb: xhk hfx
  pzl: lsr hfx nvd
  qnr: nvd
  ntq: jqt hfx bvb xhk
  nvd: lhk
  lsr: lhk
  rzs: qnr cmg lsr rsh
  frs: qnr lhk lsr
  """)
# println("[Example p1] $(part1(example))") # 54

data = parse_input(Utils.readday(25))
println("[Part 1] $(part1(data))") # 613870

include("utils.jl")

mutable struct Card
  id::Int
  winning::Vector{Int}
  got::Vector{Int}
  copies::Int
end

function parse_input(input)
  cards = []
  for l in Utils.lines(input)
    id_raw, win_raw, got_raw = match(r"Card *(\d+): (.+) \| (.+)$", l)
    winning = map(x -> parse(Int, x), eachsplit(win_raw, r"\s+", keepempty=false))
    got = map(x -> parse(Int, x), eachsplit(got_raw, r"\s+", keepempty=false))
    push!(cards, Card(parse(Int, id_raw), winning, got, 1))
  end
  cards
end

function part1(cards)
  total_score = 0
  for card in cards
    score = 0
    for number in card.got
      if number in card.winning
        score = max(score * 2, 1)
      end
    end
    total_score += score
  end
  total_score
end

function part2(cards)
  for card in cards
    matches = length(filter(n -> n in card.winning, card.got))
    for c in cards
      if card.id < c.id <= card.id + matches
        c.copies += card.copies
      end
    end
  end
  reduce(+, map(x -> x.copies, cards), init=0)
end

example = parse_input("""
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """)
println("[Example p1] $(part1(example))") # 13
println("[Example p2] $(part2(example))") # 30

data = parse_input(Utils.readday(4))
println("[Part 1] $(part1(data))") # 23673
println("[Part 2] $(part2(data))") # 12263631

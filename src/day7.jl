include("utils.jl")

parse_input(input) =
  collect(
    let (hand, bid) = split(l); (hand, parse(Int, bid)) end
    for l in Utils.lines(input))

@enum HandType five=7 four=6 fullhouse=5 three=4 twopairs=3 onepair=2 high=1

function find_hand_type(str)
  @assert length(str) == 5
  cards = collect(count(ch, str) for ch in unique(str))
  if length(cards) == 1; five
  elseif length(cards) == 2; (4 in cards ? four : fullhouse)
  elseif length(cards) == 3; (3 in cards ? three : twopairs)
  elseif length(cards) == 4; onepair
  else high end
end

function find_hand_type_with_joker(str)
  @assert length(str) == 5
  jokers = count('J', str)
  cards = collect(count(ch, str) for ch in filter(x -> x != 'J', unique(str)))
  if length(cards) <= 1; five # 5 or n + jokers = 5
  elseif length(cards) == 2
    maximum(cards) + jokers >= 4 ? four : fullhouse
  elseif length(cards) == 3
    maximum(cards) + jokers >= 3 ? three : twopairs
  elseif length(cards) == 4; onepair
  else high end
end

score_card(ch) =
  if ch == 'A' 14
  elseif ch == 'K' 13
  elseif ch == 'Q' 12
  elseif ch == 'J' 11
  elseif ch == 'T' 10
  else parse(Int, ch) end

score_card_part2(ch) = ch == 'J' ? 1 : score_card(ch)

function is_weaker_hand_part1((h1, _), (h2, _))
  t1, t2 = find_hand_type(h1), find_hand_type(h2)
  if t1 == t2
    for (a, b) in zip(h1, h2)
      if a != b return score_card(a) < score_card(b) end
    end
    false
  else t1 < t2 end
end

function is_weaker_hand_part2((h1, _), (h2, _))
  t1, t2 = find_hand_type_with_joker(h1), find_hand_type_with_joker(h2)
  if t1 == t2
    for (a, b) in zip(h1, h2)
      if a != b return score_card_part2(a) < score_card_part2(b) end
    end
    false
  else t1 < t2 end
end

function calc_ranks(hands, lt)
  result = 0
  for (rank, (_, bid)) in enumerate(sort(hands; lt))
    result += rank * bid
  end
  result
end

part1(hands) = calc_ranks(hands, is_weaker_hand_part1)
part2(hands) = calc_ranks(hands, is_weaker_hand_part2)

example = parse_input("""
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """)
println("[Example p1] $(part1(example))") # 6440
println("[Example p2] $(part2(example))") # 5905

data = parse_input(Utils.readday(7))
println("[Part 1] $(part1(data))") # 248179786
println("[Part 2] $(part2(data))") # 247885995

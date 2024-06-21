module Utils

export daydata
function daydata(n)
  joinpath(@__DIR__, "..", "data", "day$(n).txt")
end

export readday
function readday(n)
  read(daydata(n), String)
end

export lines
function lines(input)
  eachsplit(input, r"\r?\n", keepempty=false)
end

end

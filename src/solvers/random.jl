struct RandomChoice <: AbstractSolver end

function choice(::RandomChoice, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    choice_cand = findall(==('1'), bitstring(legals))
    ind = StatsBase.sample(choice_cand)
    return TOP_BIT >> (ind - 1) 
end

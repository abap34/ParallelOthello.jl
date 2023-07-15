struct MinMax <: AbstractSolver
    max_depth::Int
end

function choice(solver::MinMax, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    max_depth = solver.max_depth
    cand = LegalCand(legals)
    scores = zeros(Int, length(cand))
    hands = collect(LegalCand(legals))
    for (i, legal) in enumerate(cand)
        scores[i] = minmax(1, put(board1, board2, legal, "black")..., max_depth)
    end
    res = choice_maximum(scores, hands)
    if res == 0x0
        throw(DomainError("zero choice. \n hands:$hands, \n scores:$scores"))
    else
        return res
    end
end

function minmax(depth::Int, board1::UInt64, board2::UInt64, max_depth::Int)
    if depth == max_depth
        return count_ones(board1) - count_ones(board2)
    end


    if isfinish(board1, board2)[1]
        return count_ones(board1) - count_ones(board2)
    end

    if depth % 2 == 0
        _legals = legal(board1, board2)
    else
        _legals = legal(board2, board1)
    end

    if _legals == 0x0
        score = -minmax(depth + 1, board1, board2, max_depth)
    else
        cand = LegalCand(_legals)
        if depth % 2 == 1
            score = 100000000
            for legal in cand
                score = min(score, minmax(depth + 1, put(board1, board2, legal, "white")..., max_depth))
            end
        else
            score = -10000000000
            for legal in cand
                score = max(score, minmax(depth + 1, put(board1, board2, legal, "black")..., max_depth))
            end
        end
    end
    return score
end
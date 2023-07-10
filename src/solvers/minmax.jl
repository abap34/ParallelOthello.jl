struct MinMax <: AbstractSolver 
    max_depth :: Int
end

function choice(solver::MinMax, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    max_depth = solver.max_depth
    cand = LegalCand(legals)
    scores = Tuple{UInt64, Int}[]
    for legal in cand
        push!(scores, (legal, -minmax(1, put(board1, board2, legal)..., max_depth)))
    end
    sort!(scores, by=x->x[2], rev=true)
    return scores[1][1]
end

function minmax(depth::Int, board1::UInt64, board2::UInt64, max_depth::Int)
    turn = depth % 2

    if depth == max_depth
        if turn == 1
            return count_ones(board1) - count_ones(board2)
        else
            return count_ones(board2) - count_ones(board1)
        end 
    end

    score = 100000000000

    
    if turn == 1
        if isfinish(board1, board2)[1]
            return count_ones(board1) - count_ones(board2)
        end
        _legals = legal(board1, board2)
        # pass
        if _legals == 0x0
            score = -minmax(depth + 1, board1, board2, max_depth)
        else
            cand = LegalCand(_legals)
            for legal in cand
                score = min(score, -minmax(depth + 1, put(board1, board2, legal)..., max_depth))
            end
            return score
        end
    else
        if isfinish(board1, board2)[1]
            return count_ones(board2) - count_ones(board1)
        end
        _legals = legal(board2, board1)
        # pass
        if _legals == 0x0
            score = -minmax(depth + 1, board1, board2, max_depth)
        else
            cand = LegalCand(_legals)
            for legal in cand
                score = min(score, -minmax(depth + 1, put(board2, board1, legal)..., max_depth))
            end
            return score
        end
    end

    
end
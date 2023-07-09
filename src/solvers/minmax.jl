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
    # @show scores
    return scores[1][1]
end

function minmax(depth::Int, board1::UInt64, board2::UInt64, max_depth::Int)
    # @show depth
    turn = depth % 2
    # turn == 1 => my turn
    # turn == 0 => opponet turn
    if depth == max_depth
        return count_ones(board1)
    end

    

    score = 100000000000

    if turn == 1
        if legal(board1, board2) == 0b0
            return count_ones(board1)
        end
        cand = LegalCand(legal(board1, board2))
        for legal in cand
            score = min(score, -minmax(depth + 1, put(board1, board2, legal)..., max_depth))
        end
        return score
    else
        if legal(board2, board1) == 0b0
            return count_ones(board2)
        end
        cand = LegalCand(legal(board2, board1))
        for legal in cand
            score = min(score, -minmax(depth + 1, put(board2, board1, legal)..., max_depth))
        end
        return score
    end

    
end
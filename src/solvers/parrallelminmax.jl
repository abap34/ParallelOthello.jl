using Base.Threads

struct ParallelMinMax <: AbstractSolver
    max_depth::Int
    num_threads::Int
end



function choice(solver::ParallelMinMax, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    max_depth = solver.max_depth
    cand = LegalCand(legals)
    n = length(cand)
    scores = zeros(Int, n)
    hands = zeros(UInt64, n)
    tasks = map(1:n) do i
        @spawn -paralellminmax(1, put(board1, board2, cand[i])..., max_depth)
    end
    scores = (fetch(task)::Int for task in tasks)
    hands = collect(cand)
    res = choice_maximum(scores, hands)
    if res == 0x0
        throw(DomainError("zero choice. \n hands:$hands, \n scores:$scores"))
    else
        return res
    end
end


function build_score_function(depth, board1, board2, max_depth)
    return (legal) -> (paralellminmax(depth + 1, put(board1, board2, legal)..., max_depth))
end

function paralellminmax(depth::Int, board1::UInt64, board2::UInt64, max_depth::Int) :: Int
    if depth == max_depth
        return count_ones(board1) - count_ones(board2)
    end

    turn = depth % 2
    

    score = 100000000000

    if isfinish(board1, board2)[1]
        return count_ones(board2) - count_ones(board1)
    end
    if turn == 1
        _legals = legal(board1, board2)
        # pass
        if _legals == 0x0
            return -paralellminmax(depth + 1, board1, board2, max_depth)
        else
            cand = LegalCand(_legals)
            if depth == 1
                for legal in cand
                    score = min(score, -minmax(depth + 1, put(board1, board2, legal)..., max_depth))
                end
            end
            return score
        end
    else
        _legals = legal(board2, board1)
        # pass
        if _legals == 0x0
            return -paralellminmax(depth + 1, board1, board2, max_depth)
        else
            cand = LegalCand(_legals)
            for legal in cand
                score = min(score, -minmax(depth + 1, put(board2, board1, legal)..., max_depth))
            end
            return score
        end
    end
end
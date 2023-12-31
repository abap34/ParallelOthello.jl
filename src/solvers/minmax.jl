struct MinMax <: AbstractSolver
    max_depth::Int
end


node_count :: Int = 0


function choice(solver::MinMax, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    node_count = 0
    max_depth = solver.max_depth
    cand = LegalCand(legals)
    scores = zeros(Int, length(cand))
    hands = collect(LegalCand(legals))
    n = length(hands)
    tasks = @inbounds map(1:n) do i
        calc(solver, 1, put(board1, board2, cand[i], "black")..., max_depth, i)
    end
    score_and_idx = (fetch(task)::Tuple{Int, Int} for task in tasks)
    scores = (x -> x[1]).(score_and_idx)
    hands = (x -> hands[x[2]]).(score_and_idx)
    res = choice_maximum(scores, hands)
    if res == 0x0
        throw(DomainError("zero choice. \n hands:$hands, \n scores:$scores"))
    else
        return res
    end
end



function calc(::MinMax, depth::Int, board1::UInt64, board2::UInt64, max_depth::Int, i::Int) :: Tuple{Int, Int}
    score = minmax(depth, board1, board2, max_depth)
    return score, i
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
        if depth % 2 == 0
            tasks = map(cand) do legal
                minmax(depth + 1, put(board1, board2, legal, "black")..., max_depth)
            end
            score = maximum((fetch(task)::Int for task in tasks))
        else
            tasks = map(cand) do legal
                minmax(depth + 1, put(board1, board2, legal, "white")..., max_depth)
            end
            score = minimum((fetch(task)::Int for task in tasks))
        end
    end
    return score
end
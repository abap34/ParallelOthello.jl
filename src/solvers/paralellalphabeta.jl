struct ParallelAlphaBeta <: AbstractSolver
    max_depth::Int
end

function choice(solver::ParallelAlphaBeta, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    max_depth = solver.max_depth
    cand = LegalCand(legals)
    scores = zeros(Int, length(cand))
    hands = collect(LegalCand(legals))
    n = length(hands)
    tasks = @inbounds map(1:n) do i
        Threads.@spawn calc(solver, 1, put(board1, board2, cand[i], "black")..., max_depth, i)
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


function calc(::ParallelAlphaBeta, depth::Int, board1::UInt64, board2::UInt64, max_depth::Int, i::Int) :: Tuple{Int, Int}
    α = -100000
    β = 100000
    score = parallelalphabeta(depth, board1, board2, α, β, max_depth)
    return score, i
end


function parallelalphabeta(depth::Int, board1::UInt64, board2::UInt64, α::Int, β::Int, max_depth::Int)
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
        score = parallelalphabeta(depth + 1, board1, board2, α, β, max_depth)
    else
        cand = LegalCand(_legals)
        if depth % 2 == 1
            first_hand = first(cand)
            first_score = parallelalphabeta(depth + 1, put(board1, board2, first_hand, "white")..., α, β, max_depth)
           
            if first_score < α
                return α
            else
                β = min(β, first_score)
            end

            if length(cand) == 1
                return first_score
            end

            scores = fill(10000000, Threads.nthreads())
            Threads.@threads for legal in cand[2:end]
                score = parallelalphabeta(depth + 1, put(board1, board2, legal, "white")..., α, β, max_depth)
                if score < α
                    break
                else
                    scores[Threads.threadid()] = min(scores[Threads.threadid()], score)
                end
            end
            return min(first_score, minimum(scores))

        else
            first_hand = first(cand)
            first_score = parallelalphabeta(depth + 1, put(board1, board2, first_hand, "black")..., α, β, max_depth)
            
            if first_score > β
                return β
            else
                α = max(α, first_score)
            end

            if length(cand) == 1
                return first_score
            end

            scores = fill(-10000000, Threads.nthreads())
            Threads.@threads for legal in cand[2:end]
                score =  parallelalphabeta(depth + 1, put(board1, board2, legal, "black")...,  α, β, max_depth)
                if score > β
                    break
                else
                    scores[Threads.threadid()] = max(scores[Threads.threadid()], score)
                end
            end

            return max(first_score, maximum(scores))

            
        end
    end
end
struct ParallelAlphaBeta <: AbstractSolver 
    max_depth :: Int
end

function choice(solver::ParallelAlphaBeta, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    max_depth = solver.max_depth
    cand = LegalCand(legals)
    scores = zeros(Int, length(cand))
    hands = zeros(UInt64, length(cand))
    best_score = -100000
    alpha = -100000 
    for (i, legal) in enumerate(cand)
        score = -parallel_alpha_beta(1, put(board1, board2, legal)..., alpha, -alpha, max_depth)
        scores[i] = score
        if score > best_score
            best_score = score
            alpha = score
        end
        hands[i] = legal
    end
    res = choice_maximum(scores, hands)
    if res == 0x0
        throw(DomainError("zero choice. \n hands:$hands, \n scores:$scores"))
    else
        return res
    end
end


function parallel_alpha_beta(depth::Int, board1::UInt64, board2::UInt64, alpha::Int, beta::Int, max_depth::Int)
    turn = depth % 2
    if depth == max_depth
        if turn == 1
            return count_ones(board1) - count_ones(board2)
        else
            return count_ones(board2) - count_ones(board1)
        end 
    end

    if turn == 1
        if isfinish(board1, board2)[1]
            return count_ones(board1) - count_ones(board2)
        end
        _legals = legal(board1, board2)
        # pass
        if _legals == 0x0
            return -parallel_alpha_beta(depth + 1, board1, board2, -beta, -alpha, max_depth)
        else
            cand = LegalCand(_legals)
            Threads.@threads for legal in cand
                alpha = max(alpha, -parallel_alpha_beta(depth + 1, put(board1, board2, legal)..., -beta, -alpha, max_depth))
                if alpha >= beta
                    break  # beta cut-off
                end
            end
            return alpha
        end
    else
        if isfinish(board1, board2)[1]
            return count_ones(board2) - count_ones(board1)
        end
        _legals = legal(board2, board1)
        # pass
        if _legals == 0x0
            return -parallel_alpha_beta(depth + 1, board1, board2, -beta, -alpha, max_depth)
        else
            cand = LegalCand(_legals)
            Threads.@threads for legal in cand
                beta = min(beta, -parallel_alpha_beta(depth + 1, put(board2, board1, legal)..., -beta, -alpha, max_depth))
                if beta <= alpha
                    break  # alpha cut-off
                end
            end
            return beta
        end
    end
end



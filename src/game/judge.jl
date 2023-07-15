const NOT_TOP_ROW_MASK = 0x7f7f7f7f7f7f7f7f
const NOT_BOTTOM_ROW_MASK = 0xfefefefefefefefe
const NOT_LEFT_COL_MASK = 0x00fefefefefefefe
const NOT_RIGHT_COL_MASK = 0xffffffffffffff00



function legal(board1::UInt64, board2::UInt64)
    mask::UInt64 = 0x0
    for direction in ALL_DIRECTION
        mask |= legal_eachdirection(board1, board2, direction)
    end
    return mask & (~(board1 | board2))
end

function islegal(position::UInt64, board1::UInt64, board2::UInt64)
    legal_mask = legal(board1, board2)
    return !((position & legal_mask) == 0x0)
end

function isfinish(game::Game)::Bool
    res, state = isfinish(game.playerboard, game.opponetboard)
    game.state = state
    return res
end


function isfinish(board1::UInt64, board2::UInt64) :: Tuple{Bool, Int}
    if ~(board1 | board2) == 0x0
        player_count = count_ones(board1)
        opponet_count = count_ones(board2)
        if player_count > opponet_count
            state = 1
        elseif player_count < opponet_count
            state = -1
        else
            state = 0
        end
        return true, state
    end


    if board1 == 0x0
        state = -1
        return true, state
    elseif board2 == 0x0
        state = 1
        return true, state
    end

    if legal(board1, board2) == legal(board2, board1) == 0x0
        state = 0
        return true, state
    end

    state = 0
    return false, state
end


const ALL_DIRECTION = (
    "up",
    "down",
    "right",
    "left",
    "upright",
    "downright",
    "upleft",
    "downleft"
)

function direction_to_shift(direction)
    return Dict(
        "up" => -1,
        "down" => 1,
        "right" => 8,
        "left" => -8,
        "upright" => 7,
        "downright" => 9,
        "upleft" => -9,
        "downleft" => -7,
    )[direction]
end


function trim(board, direction)
    @assert direction in ALL_DIRECTION
    if direction == "up"
        board &= NOT_TOP_ROW_MASK
        board &= NOT_BOTTOM_ROW_MASK

    elseif direction == "down"
        board &= NOT_TOP_ROW_MASK
        board &= NOT_BOTTOM_ROW_MASK

    elseif direction == "right"
        board &= NOT_RIGHT_COL_MASK
        board &= NOT_LEFT_COL_MASK


    elseif direction == "left"
        board &= NOT_RIGHT_COL_MASK
        board &= NOT_LEFT_COL_MASK

    elseif direction == "upright"
        board &= NOT_TOP_ROW_MASK
        board &= NOT_BOTTOM_ROW_MASK
        board &= NOT_RIGHT_COL_MASK
        board &= NOT_LEFT_COL_MASK



    elseif direction == "downright"
        board &= NOT_TOP_ROW_MASK
        board &= NOT_BOTTOM_ROW_MASK
        board &= NOT_RIGHT_COL_MASK
        board &= NOT_LEFT_COL_MASK

    elseif direction == "upleft"
        board &= NOT_TOP_ROW_MASK
        board &= NOT_BOTTOM_ROW_MASK
        board &= NOT_RIGHT_COL_MASK
        board &= NOT_LEFT_COL_MASK

    elseif direction == "downleft"
        board &= NOT_TOP_ROW_MASK
        board &= NOT_BOTTOM_ROW_MASK
        board &= NOT_RIGHT_COL_MASK
        board &= NOT_LEFT_COL_MASK
    end
    return board
end


function legal_eachdirection(board1::UInt64, board2::UInt64, direction)::UInt64
    n_shift = direction_to_shift(direction)
    board2 = trim(board2, direction)
    mask = board2 & (board1 >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    
    return mask >> n_shift
end

function reverse_eachdirection(ind::UInt64, board1::UInt64, board2::UInt64, direction)::UInt64
    n_shift = direction_to_shift(direction)
    board2 = trim(board2, direction)
    mask = board2 & (ind >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    mask |= board2 & (mask >> n_shift)
    if ((mask >> n_shift) & board1 != 0x0)
        return mask & board2
    else
        return 0x0
    end
end



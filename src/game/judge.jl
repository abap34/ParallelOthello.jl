const NOT_TOP_ROW_MASK = 0x7f7f7f7f7f7f7f7f
const NOT_BOTTOM_ROW_MASK = 0xfefefefefefefefe
const NOT_LEFT_COL_MASK = 0x00fefefefefefefe
const NOT_RIGHT_COL_MASK = 0xffffffffffffff00

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
    for _ in 1:6
        mask |= board2 & (mask >> n_shift)
    end
    return mask >> n_shift
end

function reverse_eachdirection(ind::UInt64, board1::UInt64, board2::UInt64, direction)::UInt64
    n_shift = direction_to_shift(direction)
    board2 = trim(board2, direction)
    mask = board2 & (ind >> n_shift)
    for _ in 1:6
        mask |= board2 & (mask >> n_shift)
    end
    if ((mask >> n_shift) & board1 != 0b0)
        return mask & board2
    else
        return 0b0
    end 
end



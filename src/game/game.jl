using PrettyTables


const ZERO::UInt64 = 0x0
const TOP_BIT::UInt64 = 0b1000000000000000000000000000000000000000000000000000000000000000

mutable struct Game
    playerboard::UInt64
    opponetboard::UInt64
    state::Int8
    turn::Int8
    function Game(; size=(8, 8))
        playerboard = zeros(Int8, size)

        center_row = size[1] ÷ 2
        center_col = size[2] ÷ 2

        playerboard[center_row, center_col] = 1
        playerboard[center_row+1, center_col+1] = 1
        playerboard[center_row, center_col+1] = -1
        playerboard[center_row+1, center_col] = -1

        opponetboard = playerboard .* -1

        playerboard = encode(playerboard)
        opponetboard = encode(opponetboard)

        state = 0
        turn = 1

        return new(playerboard, opponetboard, state, turn)
    end
end


function display(game::Game)
    formatter = (v, i, j) -> (
        Dict(
        0 => "  ",
        1 => "⚫️",
        -1 => "⚪️",
        2 => "🔸"
    )[v]
    )


    player_decodedboard = decode(game.playerboard)
    opponet_decodedboard = decode(game.opponetboard)

    board = player_decodedboard .+ (opponet_decodedboard .* -1)

    if game.turn == 1
        legal_mask = decode(legal(game.playerboard, game.opponetboard))
    else
        legal_mask = decode(legal(game.opponetboard, game.playerboard))
    end
    board = board .+ legal_mask .* 2

    pretty_table(board, body_hlines=collect(1:8), header='a':'h', row_labels=collect(1:8), formatters=formatter)
end


function encode(board::AbstractArray)
    s::UInt64 = 0x0
    for (i, v) in enumerate(board)
        if v == 1
            s |= TOP_BIT >> (i - 1)
        end
    end
    return s

end

function decode(board::UInt64)
    board_bitstr = bitstring(board)
    decoded_board = zeros(Int8, (8, 8))
    for i in 1:64
        if (board_bitstr[i] == '1')
            decoded_board[i] = 1
        end
    end
    return decoded_board
end



function iswin(game::Game)::Bool
    return game.state == 1
end

function islose(game::Game)::Bool
    return game.state == -1
end

function iseven(game::Game)::Bool
    return game.state == 0
end

function winner(game::Game)::String
    if !(isfinish(game))
        throw(DomainError("Called `winner`, but game is not finished."))
    end
    if iswin(game)
        return "black"
    else
        return "white"
    end
end


function blackwin!(game::Game)
    game.state = 1
end

function whitewin!(game::Game)
    game.state = -1
end

function draw!(game::Game)
    game.state = 0
end



function put!(game::Game, row::Char, col::Char)::Bool
    @assert row in '1':'8'
    @assert col in 'a':'h'
    row = parse(Int, row)
    col = findfirst(==(col), collect('a':'h'))
    return put!(game, row, col)
end


function put!(game::Game, row::Int, col::Int)
    ind = TOP_BIT >> (8 * (col - 1) + row - 1)
    put!(game, ind)
end

function put!(game::Game, ind::UInt64)
    if game.turn == 1
        game.playerboard, game.opponetboard = put(game.playerboard, game.opponetboard, ind, "black")
    else
        game.playerboard, game.opponetboard  = put(game.playerboard, game.opponetboard, ind, "white")
    end
end

function put(board1::UInt64, board2::UInt64, ind::UInt64, mode::String)
    @assert mode in ("black", "white")
    if mode == "white"
        board1, board2 = board2, board1
    end
    if islegal(ind, board1, board2)
        board1 |= ind
    else
        throw(DomainError("Illegal cell $(bitstring(ind)) $(bit_to_position(ind))"))
    end
    board1, board2 = reverse(board1, board2, ind)
    if mode == "black"
        return board1, board2
    else
        return board2, board1
    end
end

function reverse(board1::UInt64, board2::UInt64, ind::UInt64) :: Tuple{UInt64, UInt64}
    mask::UInt64 = 0x0
    for direction in ALL_DIRECTION
        mask |= reverse_eachdirection(ind, board1, board2, direction)
    end
    board1 |= mask
    board2 = board2 ⊻ mask
    return board1, board2
end


function next!(game::Game)
    if game.turn == 1
        game.turn = -1
    else
        game.turn == -1
        game.turn = 1
    end
end

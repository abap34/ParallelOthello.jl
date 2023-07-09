
include("game/game.jl")
include("game/judge.jl")

include("solvers/solvers.jl")

function start()
    game = Game()
    display(game)
    while !(isfinish(game))
        try
            row, col = only.(split(readline()))
            put!(game, row, col)
        catch e
            println("invalid value: $e")
            continue
        else
            next!(game)
            display(game)
        end
    end
    println("winner is ", black)
end


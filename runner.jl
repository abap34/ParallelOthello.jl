include("src/ParallelOthello.jl")

game = Game()


function start(solver1, solver2)
    game = Game()
    println("Turn 1")
    display(game)
    while !(isfinish(game))
        readline()
        try
            if game.turn == 1
                legals = legal(game.playerboard, game.opponetboard)
                if legals == 0b0
                    println("pass")
                else
                    choice_encoded = choice(solver1, game.playerboard, game.opponetboard, legals)
                    put!(game, choice_encoded)
                end
            else
                legals = legal(game.opponetboard, game.playerboard)
                if legals == 0b0
                    println("pass")
                else
                    choice_encoded = choice(solver2, game.opponetboard, game.playerboard, legals)
                    put!(game, choice_encoded)
                end
            end
        catch e
            println("invalid value: $e")
            continue
        else
            next!(game)
            display(game)
        end
    end
    black_count = count_ones(game.playerboard)
    white_count = count_ones(game.opponetboard)
    if iswin(game)
        println("黒の勝利！")
        println("黒石:", black_count)
        println("白石:", white_count)
    elseif islose(game)
        println("白の勝利")
        println("黒石:", black_count)
        println("白石:", white_count)
    else
        println("引き分け")
        println("黒石:", black_count)
        println("白石:", white_count)
    end

end


solver1 = RandomSolver()
solver2 = RandomSolver()

start(solver1, solver2)
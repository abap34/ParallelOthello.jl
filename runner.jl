using ProgressBars
using UnicodePlots
using OhMyREPL
using Random

Random.seed!(34)

include("src/ParallelOthello.jl")


function start_game(solver1, solver2; verbose=true, auto=false)
    game = Game()
    if verbose
        println("Start")
        display(game)
    end
    turn = 0
    while !(isfinish(game))
        turn += 1
        if verbose 
            println("====== Turn $turn ======")
            if game.turn == 1 
                println("Black Turn")
            else
                println("White Turn")
            end
            println("Enter to start choice.")
        end
        (!(auto)) && (readline())
        try
            if game.turn == 1
                legals = legal(game.playerboard, game.opponetboard)
                if legals == 0x0
                    (verbose) && (println("pass"))
                else
                    choice_encoded = choice(solver1, game.playerboard, game.opponetboard, legals)
                    if verbose
                        println("Choice from $solver1 : $(bit_to_position(choice_encoded))")
                    end
                    put!(game, choice_encoded)
                    (verbose) && (println("put"))
                end
            else
                legals = legal(game.opponetboard, game.playerboard)
                if legals == 0x0
                    (verbose) && (println("pass"))
                else
                    choice_encoded = choice(solver2, game.opponetboard, game.playerboard, legals)
                    if verbose
                        println("Choice from $solver2 : $(bit_to_position(choice_encoded))")
                    end
                    put!(game, choice_encoded)
                    (verbose) && (println("put"))
                end
            end
        catch e
            println("invalid value: $e")
            throw(e)
            continue
        else
            next!(game)
            (verbose) && (display(game))
        end
    end
    black_count = count_ones(game.playerboard)
    white_count = count_ones(game.opponetboard)
    if verbose
        info = () -> (
            println("黒石:", black_count);
            println("白石:", white_count)
        )
        if iswin(game)
            println("黒の勝利！")
            info()
        elseif islose(game)
            println("白の勝利")
            info()
        else
            println("引き分け")
            info()
        end
    end
    return game.state, black_count, white_count
end


function battle(solver1, solver2; verbose=false, N=256)
    Random.seed!(0)
    black_win = 0
    white_win = 0
    even = 0
    if verbose
        r = ProgressBar(1:N)
    else
        r = 1:N
    end
    for _ in r
        res, _, _ = start_game(solver1, solver2, verbose=false, auto=true)
        if res == 1
            black_win += 1
        elseif res == -1
            white_win += 1
        else
            even += 1
        end
    end
    barplot(["$(solver1)", "$(solver2)", "Draw"], [black_win, white_win, even], title="Result")
end
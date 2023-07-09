using ProgressBars
using UnicodePlots
using Random

Random.seed!(34)

include("src/ParallelOthello.jl")


function start(solver1, solver2; verbose=true)
    game = Game()
    if verbose
        println("Start")
        display(game)
    end
    while !(isfinish(game))
        (verbose) && readline()
        try
            if game.turn == 1
                (verbose) && (println("My turn."))
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
                (verbose) && (println("opponet turn."))
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


function main()
    solver1 = RandomChoice()
    solver2 = MinMax(3)

    N = 10^2

    black_win = 0
    white_win = 0
    even = 0

    for _ in ProgressBar(1:N)
        res, _, _ = start(solver1, solver2, verbose=false)
        if res == 1
            black_win += 1
        elseif res == -1
            white_win += 1
        else
            even += 1
        end
    end
    barplot(["黒 $(solver1)", "白 $(solver2)", "引き分け"], [black_win, white_win, even], title="結果")
end



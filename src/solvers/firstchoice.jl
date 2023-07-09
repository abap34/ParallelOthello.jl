struct FirstChoice <: AbstractSolver end


function choice(::FirstChoice, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    n = 64 - leading_zeros(legals)
    println("legals:", bitstring(legals))
    random_choice = (legals >> (n - 1) << (n - 1))
    println("choice:", bitstring(random_choice))
    return random_choice
end
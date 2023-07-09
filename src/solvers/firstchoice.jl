struct FirstChoice <: AbstractSolver end

function choice(::FirstChoice, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    return trim_after(legals)
end
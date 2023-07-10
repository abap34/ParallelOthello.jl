import Base

struct Human <: AbstractSolver end

function choice(::Human, board1::UInt64, board2::UInt64, legals::UInt64)::UInt64
    row, col = split(Base.prompt("> "))
    row = parse(Int, row)
    col = findfirst(==(only(col)), 'a':'h')
    return TOP_BIT >> (8 * (col - 1) + row - 1)
end

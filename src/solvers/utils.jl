import Base

function trim_after(bits::UInt64)
    n = BIT_LEN - leading_zeros(bits)
    return (bits >> (n - 1) << (n - 1))
end


function bit_to_position(bits::UInt64)
    ind = leading_zeros(bits) + 1
    row = (ind - 1) % 8 + 1
    col = ('a':'h')[(ind - 1) ÷ 8 + 1]
    return row, col
end


mutable struct LegalCand
    legals::UInt64
end

function Base.iterate(cand::LegalCand)
    return trim_after(cand.legals), trim_after(cand.legals)
end

function Base.iterate(cand::LegalCand, prev::UInt64)
    cand.legals = cand.legals ⊻ prev
    new = trim_after(cand.legals)
    if new == 0x0
        return nothing
    else
        return new, new
    end
end


function Base.length(cand::LegalCand)
    return count_ones(cand.legals)
end



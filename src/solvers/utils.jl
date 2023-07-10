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


function choice_maximum(scores, hands)
    max_score = maximum(scores)
    max_idxs = findall(==(max_score), scores)
    return hands[StatsBase.sample(max_idxs)]
end


mutable struct LegalCand
    legals::UInt64
    bit_idxs::Vector{Int}
    function LegalCand(legals::UInt64)
        bit_idxs = findall(==('1'), bitstring(legals))
        new(legals, bit_idxs)
    end
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

function Base.iterate(cand::Base.Iterators.Enumerate{LegalCand})
    return (1, trim_after(cand.itr.legals)), (1, trim_after(cand.itr.legals))
end


function Base.iterate(cand::Base.Iterators.Enumerate{LegalCand}, prev::Tuple{Int, UInt64})
    cand.itr.legals = cand.itr.legals ⊻ prev[2]
    new = (prev[1] + 1, trim_after(cand.itr.legals))
    if new[2] == 0x0
        return nothing
    else
        return new, new
    end
end

function Base.firstindex(cand::LegalCand)
    return 1
end

function Base.getindex(cand::LegalCand, i::Int)
    return TOP_BIT >> (cand.bit_idxs[i] - 1)
end


import StatsBase


abstract type AbstractSolver end

include("utils.jl")
include("random.jl")
include("firstchoice.jl")
include("minmax.jl")
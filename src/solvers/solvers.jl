import StatsBase


abstract type AbstractSolver end

include("utils.jl")
include("random.jl")
include("firstchoice.jl")
include("minmax.jl")
include("parrallelminmax.jl")
include("alphabeta.jl")
include("paralellalphabeta.jl")
include("human.jl")
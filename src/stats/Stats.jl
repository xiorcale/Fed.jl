module Stats

using ..Fed: STATS, Statistics


# --------------------------------
# Include
# --------------------------------

include("metrics.jl")
include("base_stats.jl")

include("vanilla/vanilla_net.jl")
include("vanilla/vanilla_stats.jl")

include("gd/gd_net.jl")
include("gd/gd_stats.jl")


"""
    update_stats!(stat, round_num, loss, accuracy)

Updates all the statistics at once. This function is intended to be used at the
end of each communication round. It assumes that some values have been updated
while calling the `PayloadSerde` functions.
"""
function update_stats!(
    stats::T, 
    round_num::Int,
    loss::Float32,
    accuracy::Float32
) where T <: Statistics
    update_stats!(stats)
    update_stats!(stats.base, loss, accuracy)
    update_stats!(stats.network, round_num)
end


# --------------------------------
# Export
# --------------------------------

export BaseStats, VanillaStats, GDStats, update_stats!


end # module
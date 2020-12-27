module Stats

using ..Fed: STATS, Statistics, Configuration, VanillaConfig, QuantizedConfig, GDConfig

"""
    update_stats!(stat, round_num, loss, accuracy)

Update all the statistics at once. This function is intended to be used at the
end of each communication round. It assumes that some values have been updated
while calling the `PayloadSerde` functions.
"""
function update_stats!(
    stats::Statistics, 
    round_num::Int,
    loss::Float32,
    accuracy::Float32
)
    update_stats!(stats)
    update_stats!(stats.common, loss, accuracy)
    update_stats!(stats.network, round_num)
end


export update_stats!

include("metrics.jl")
export compute_changes_per_weights, compute_round_changes

include("common_stats.jl")
export CommonStats, update_stats!

include("vanilla/vanilla_net.jl")
include("vanilla/vanilla_stats.jl")
export VanillaStats, VanillaNetStats, update_stats!

include("gd/gd_net.jl")
include("gd/gd_stats.jl")
export GDStats, GDNetStats, update_stats!


end # module
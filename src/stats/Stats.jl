module Stats

abstract type Statistics end
function update_stats!(::Statistics, args...) end
export Statistics, update_stats!


include("metrics.jl")
export compute_changes_per_weights, compute_round_changes

include("base_stats.jl")
export BaseStats

include("vanilla_stats.jl")
export VanillaStats


STATS_TYPE = Dict(
    "vanilla" => VanillaStats
)

STATS = Statistics


function initialize_stats(
    stats_type::String, 
    dtype::Type{T},
    num_comm_round::Int,
    fraction_client::Float32,
    num_total_clients::Int,
    num_weights::Int
) where T <: Real
    global STATS = STATS_TYPE[stats_type]{dtype}(num_comm_round, fraction_client, num_total_clients, num_weights)
end

export STATS, initialize_stats

end # module
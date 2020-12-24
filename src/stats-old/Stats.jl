module Stats

using JLD


include("metrics/metrics.jl")

include("general.jl")
include("ml.jl")
include("gd.jl")
include("net.jl")

include("quantization_stats.jl")
export QStats, update_qstats!

struct AllStats
    general_stats::GeneralStats
    mlstats::MLStats
    gdstore_stats::GDStoreStats
    netstats::NetStats

    AllStats(
        num_comm_round::Int,
        num_clients::Int,
        num_clients_per_round::Int,
        num_weights::Int,
        compressor::Compressor
    ) = new(
        GeneralStats(num_comm_round, num_clients, num_clients_per_round),
        MLStats(num_weights),
        GDStoreStats(compressor, num_weights),
        NetStats()
    )
end


"""
    update_stats!(stats, round_num, acc, loss, database_length, num_requested_bases, num_unknown_bases)

Updates all the statistics at once.
"""
function update_stats!(
    stats::AllStats,
    round_num::Int,
    acc::Float32,
    loss::Float32,
    database_length::Int,
    num_requested_bases::Int,
    num_unknown_bases::Int
)
    update_mlstats!(stats.mlstats, acc, loss)
    update_gdstore_stats!(stats.gdstore_stats, database_length, num_requested_bases, num_unknown_bases)
    update_netstats!(stats.netstats, stats.general_stats, stats.gdstore_stats, round_num)
end


export AllStats, update_stats!

end # module
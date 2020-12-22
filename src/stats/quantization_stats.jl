struct QStats
    general_stats::GeneralStats
    mlstats::MLStats
    netstats::NetStats

    round_changes::Vector{Float32}
    changes_per_weights::Vector{Vector{Float32}}

    QStats(
        num_comm_round::Int,
        num_clients::Int,
        num_clients_per_round::Int,
        num_weights::Int,
    ) = new(
        GeneralStats(num_comm_round, num_clients, num_clients_per_round),
        MLStats(num_weights),
        NetStats(),
        Vector{Float32}(undef, 0),
        Vector{Vector{Float32}}(undef, 0)
    )
end


"""
    update_qstats!(stats, acc, loss)

Update the stats related to quantization.
"""
function update_qstats!(stats::QStats, acc::Float32, loss::Float32)
    update_mlstats!(stats.mlstats, acc, loss)
    update_netstats!(stats.netstats, stats.general_stats)
end

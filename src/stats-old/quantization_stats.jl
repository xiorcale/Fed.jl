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
function update_qstats!(stats::QStats, round_num::Int, acc::Float32, loss::Float32, req_data::Vector, res_data::Vector{Vector})
    update_mlstats!(stats.mlstats, acc, loss)
    update_vanilla_netstats!(stats.netstats, stats.general_stats, stats.mlstats, round_num)

    push!(stats.round_changes, compute_round_changes(req_data, res_data))
    push!(stats.changes_per_weights, compute_changes_per_weights(req_data, res_data))
end

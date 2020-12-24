struct NetStats
    downlink::Vector{Int}
    uplink::Vector{Int}

    NetStats() = new(Vector{Int}(undef, 0), Vector{Int}(undef, 0))
end


"""
    update_vanilla_netstats(stats, round_num)

Updates the network statistics by tracking the uplink/downlink traffic of the
round, assuming no gd has been applied.
"""
function update_vanilla_netstats!(
    stats::NetStats,
    general_stats::GeneralStats,
    mlstats::MLStats,
    round_num::Int
)
    model_size = mlstats.num_weights * sizeof(QDTYPE)
    num_comm = general_stats.num_clients_per_round * round_num
    uplink = num_comm * model_size
    push!(stats.uplink, uplink)

    # without GD, we have a symetrical communication...
    downlink = uplink
    push!(stats.downlink, downlink)
end


"""
    update_gd_netstats!(stats, general_stats, gdstats, round_num)

Updates the network statistics by tracking the uplink/downlink traffic of the
round, taking the gd into account (i.e. by using the store statistics).
"""
function update_gd_netstats!(
    stats::NetStats,
    general_stats::GeneralStats,
    gdstats::GDStoreStats,
    round_num::Int
)
    num_requested_bases = gdstats.num_requested_bases[end]
    num_unknown_bases = gdstats.num_unknown_bases[end]

    # downlink
    gdfile_downlink = round_num * general_stats.num_clients_per_round * gdstats.gdfile_size
    hashes_downlink = num_requested_bases * gdstats.hashsize
    bases_downlink = num_unknown_bases * gdstats.basesize
    push!(stats.downlink, gdfile_downlink + hashes_downlink + bases_downlink)

    # uplink
    gdfile_uplink = round_num * general_stats.num_clients_per_round * gdstats.gdfile_size
    hashes_uplink = num_unknown_bases * gdstats.hashsize
    bases_uplink = num_requested_bases * gdstats.basesize
    push!(stats.uplink, gdfile_uplink + hashes_uplink + bases_uplink)
end

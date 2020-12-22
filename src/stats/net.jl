struct NetStats
    downlink::Vector{Int}
    uplink::Vector{Int}

    NetStats() = new(Vector{Int}(undef, 0), Vector{Int}(undef, 0))
end


"""
    update_netstats!(stats, general_stats, gdstats, round_num)

Updates the network statistics by tracking the uplink/downlink traffic of the
round.
"""
function update_netstats!(
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

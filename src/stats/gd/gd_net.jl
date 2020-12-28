"""
    GDNetStats

Network statistics for `GDConfig`.
"""
mutable struct GDNetStats <: Statistics
    # gdfile stats
    gdfile_length::Int
    basis_size::Int
    deviation_size::Int
    hash_size::Int

    # network traffic
    uplink::Vector{Int}
    downlink::Vector{Int}

    num_requested_bases::Int
    num_unknown_bases::Int

    num_identical_hashes::Int
    num_identical_devs::Int

    GDNetStats(
        gdfile_length,
        basis_size,
        hash_size,
        deviation_size
    ) = new(
        gdfile_length,
        basis_size, 
        hash_size,
        deviation_size,
        Vector{Int}(undef, 0), 
        Vector{Int}(undef, 0),
        0,
        0,
        0, 
        0,
    )
end


"""
    update_stats!(stats)

Updates the network traffic stats of a `GDConfig`.
"""
function update_stats!(stats::GDNetStats, round_num::Int)
    num_comm = round_num * STATS.common.num_clients_per_round

    gdfile_size = (stats.hash_size + stats.deviation_size) * stats.gdfile_length

    down_hash_size_earned = (stats.hash_size-1) * stats.num_identical_hashes
    down_dev_size_earned = (stats.deviation_size-1) * stats.num_identical_devs
    download_saved = down_hash_size_earned + down_dev_size_earned
    @show download_saved

    uplink = (num_comm * gdfile_size) + (stats.num_requested_bases * stats.basis_size) + (stats.num_unknown_bases * stats.hash_size)
    downlink = (num_comm * gdfile_size - download_saved) + (stats.num_requested_bases * stats.hash_size) + (stats.num_unknown_bases * stats.basis_size)
    
    push!(stats.uplink, uplink)
    push!(stats.downlink, downlink)
end

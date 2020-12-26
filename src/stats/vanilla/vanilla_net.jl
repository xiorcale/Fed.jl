"""
    VanillaNetStats

Network statistics for `VanillaConfig`.
"""
struct VanillaNetStats <: Statistics
    # network traffic
    uplink::Vector{Int}
    downlink::Vector{Int}

    VanillaNetStats() = new(Vector{Int}(undef, 0), Vector{Int}(undef, 0))
end


"""
    update_stats!(stats, round_num)

Updates the network traffic stats of a `VanillaConfig`.
"""
function update_stats!(stats::VanillaNetStats, round_num::Int)
    num_comm = round_num * STATS.common.num_clients_per_round
    updown = num_comm * STATS.common.num_weights * sizeof(STATS.common.dtype) # symetrical communication
    push!(stats.uplink, updown)
    push!(stats.downlink, updown)
end

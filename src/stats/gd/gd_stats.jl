mutable struct GDStats{T <: Real} <: Statistics
    common::CommonStats{T}
    network::GDNetStats

    GDStats{T}(config::GDConfig, num_weights::Int) where T <: Real = begin
        
        gdfile_length = ceil(Int, num_weights / config.chunksize)
        # call hash function with fake data to find the hash size
        hash_size = sizeof(config.fingerprint([0x00]))
        deviation_size = sizeof(config.common.dtype) * 8 - config.msbsize
        basis_size = config.msbsize * config.chunksize / 8

        return new(
            CommonStats{T}(
                config.common.num_comm_rounds,
                config.common.fraction_clients,
                config.common.num_total_clients, 
                num_weights
            ),
            GDNetStats(gdfile_length, basis_size, hash_size, deviation_size)
        )
    end
end

# function update_stats!(
#     stats::GDStats,
#     round_num::Int,
#     loss::Float32,
#     accuracy::Float32
# )
#     update_stats!(stats.common, loss, accuracy)
#     update_stats!(stats.network, round_num)

# end
using ..Config: GDConfig


mutable struct GDStats{T <: Unsigned} <: Statistics
    T::Type{T}
    base::BaseStats
    network::GDNetStats

    hash_round_changes::Vector{Float32}
    deviation_round_changes::Vector{Float32}

    GDStats{T}(config::Configuration, num_weights::Int) where T <: Unsigned = begin
        gdfile_length = ceil(Int, num_weights / config.chunksize)
        # call hash function with fake data to find the hash size
        hash_size = sizeof(config.fingerprint([0x00]))
        lsbsize = sizeof(T) * 8 - config.msbsize
        deviation_size = lsbsize * config.chunksize / 8
        basis_size = config.msbsize * config.chunksize / 8

        return new(
            T,
            BaseStats(
                config.base.num_comm_rounds,
                config.base.fraction_clients,
                config.base.num_total_clients, 
                num_weights
            ),
            GDNetStats(gdfile_length, basis_size, deviation_size, hash_size),
            Vector{Float32}(undef, 0),
            Vector{Float32}(undef, 0)
        )
    end
end

function update_stats!(stats::GDStats) 
    req_hashes = stats.base.req_data.hashes
    res_hashes = map(gdfile -> gdfile.hashes, stats.base.res_data)
    push!(stats.hash_round_changes, compute_round_changes(req_hashes, res_hashes))

    req_dev = stats.base.req_data.deviations
    res_dev = map(gdfile -> gdfile.deviations, stats.base.res_data)
    push!(stats.deviation_round_changes, compute_round_changes(req_dev, res_dev))
end
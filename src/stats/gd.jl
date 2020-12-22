using ..Fed: CHUNKSIZE, QDTYPE
using GD


mutable struct GDStoreStats
    chunksize::Int
    basesize::Int
    hashsize::Int
    deviation_size::Int
    gdfile_pad::Int
    gdfile_length::Int
    gdfile_size::Int
    database_size::Int
    database_length::Vector{Int}
    num_requested_bases::Vector{Int}
    num_unknown_bases::Vector{Int}

    GDStoreStats(compressor::Compressor, num_weights::Int) = begin
        dtype_size = sizeof(QDTYPE)
        # generate fake data to extract statistics from the GD Store
        gdfile, bases = GD.compress(compressor, rand(QDTYPE, num_weights))

        basesize = length(bases[1]) * dtype_size
        hashsize = length(gdfile.hashes[1]) # hashes are always UInt8 -> 1 Byte
        deviation_size = length(gdfile.deviations[1]) * dtype_size

        gdfile_length = length(gdfile.hashes)
        gdfile_size = gdfile_length * (hashsize + deviation_size)

        return new(
            CHUNKSIZE,
            basesize,
            hashsize,
            deviation_size,
            gdfile.padsize,
            gdfile_length,
            gdfile_size,
            0, # database size
            Vector{Int}(undef, 0),
            Vector{Int}(undef, 0),
            Vector{Int}(undef, 0)
        )
    end
end


"""
    update_gdstore_stats!(stats, database_length, num_requested_bases, num_unknown_bases)

Updates the GD Store stats by tracking database size/length, as well as the
number of unknown/requested bases.
"""
function update_gdstore_stats!(
    stats::GDStoreStats,
    database_length::Int,
    num_requested_bases::Int,
    num_unknown_bases::Int
)
    stats.database_size = database_length * (stats.hashsize + stats.basesize)
    push!(stats.database_length, database_length)
    push!(stats.num_requested_bases, num_requested_bases)
    push!(stats.num_unknown_bases, num_unknown_bases)
end

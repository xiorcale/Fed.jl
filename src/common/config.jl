# using ConfParser
using CRC32c
using SHA


struct Config{T <: Real}
    # endpoints
    serverurl::String
    register_node::String
    fit_node::String
    gd_bases::String

    # quantization
    qdtype::Type{T}
    qmin::T
    qmax::T

    # gd
    chunksize::Int
    fingerprint::Function
    permutations_file::String

    # transform
    msbsize::T

    # serialization
    payload_serde::PayloadSerde

    Config{T}(
        serverurl,
        qdtype,
        qmin,
        qmax,
        chunksize,
        fingerprint,
        permutations_file,
        msbsize,
        payload_serde,
    ) where T <: Real = new(
        serverurl,
        "/register",
        "/fit",
        "/bases",
        qdtype,
        qmin,
        qmax,
        chunksize,
        fingerprint,
        permutations_file,
        msbsize,
        payload_serde,
    )
end


"""
    new_vanilla_config()

Returns a new vanilla configuration, without any quantization or generalized
deduplication. Good ol' serialization.
"""
function new_vanilla_config(serverurl::String)::Config{Float32}
    # quantization - default values (quantization is unused for this config)
    qdtype = Float32
    qmin = -1.0
    qmax = 1.0

    # gd - default values (gd is unused for this config)
    chunksize = 0
    fingerprint = () -> undef

    permutations_file = ""
    msbsize = 0.0f0

    # serialization
    payload_serde = VanillaPayloadSerde()

    return Config{Float32}(
        serverurl,
        qdtype,
        qmin,
        qmax,
        chunksize,
        fingerprint,
        permutations_file,
        msbsize,
        payload_serde,
    )
end


"""
    new_quantized_config()

Returns a new configuration, with quantized weights but without generalized
deduplication.
"""
function new_quantized_config(serverurl::String, qdtype::Type{T}, qmin::T, qmax::T)::Config{T} where T <: Real
    # gd - default values (gd is unused for this config)
    chunksize = 0
    fingerprint = () -> undef

    permutations_file = ""
    msbsize = 0.0f0

    # serialization
    payload_serde = QuantizedPayloadSerde{T}(qmin, qmax)

    stats_type = "vanilla"

    return Config{T}(
        serverurl,
        T,
        qmin,
        qmax,
        chunksize,
        fingerprint,
        permutations_file,
        msbsize,
        payload_serde,
        stats_type
    )
end


"""
    new_gd_config()

Returns a new configuration, with quantized weights and generalized
deduplication.
"""
function new_gd_config(serverurl::String, qdtype::Type{T}, qmin::T, qmax::T)::Config{T} where T <: Real
    # gd
    chunksize = 256
    fingerprint = sha1

    permutations_file = "./permutations.jld"
    msbsize = round(qdtype, sizeof(qdtype) * 8 * 0.6) # 60% goes in the basis

    # serialization
    payload_serde = GDPayloadSerde{T}(qmin, qmax, chunksize, fingerprint, msbsize, permutations_file)

    return Config{T}(
        serverurl,
        T,
        qmin,
        qmax,
        chunksize,
        fingerprint,
        permutations_file,
        msbsize,
        payload_serde,
    )
end
using GD
using GD.Storage: Compressor, Store, GDFile, compress!, extract, patch, unpatch,
    setup_api_endpoint, validate_remote!


"""
    GDStaticPayloadSerde(chunksize, fingerprint, msbsize, store_host, store_port, is_client)

Applies both quantization and GD to the weights before serialization in order to
compress the payload. Quantization is a lossy process, thus a lost of 
information is to be expected after deserialization. Depending on the chosen
fingerprint, collisions can occur, also leading to a loss of information.
"""
mutable struct GDStaticPayloadSerde{T <: Unsigned} <: PayloadSerde
    store::Store
    is_client::Bool
    quantizer::Quantizer{T}
    gdfile::GDFile

    GDStaticPayloadSerde{T}(
        chunksize::Int,
        fingerprint::Function,
        msbsize::T,
        store_host::String,
        store_port::Int,
        is_client::Bool
    ) where T <: Unsigned = begin
        quantizer = GD.Transform.Quantizer{T}(chunksize, msbsize)
        compressor = Compressor(chunksize, quantizer, fingerprint)
        store = Store(compressor, Dict(), 0, 0)
        @async setup_api_endpoint(store, store_host, store_port)

        return new(
            store,
            is_client,
            Quantizer{T}(-1.0f0, 1.0f0),
            GDFile(Vector(undef, 0), Vector(undef, 0), 0)
        )
    end
end


"""
    serialize_payload(::GDPayloadSerde, weights)

Serializes `weights` with the `GDPayloadSerde` where quantization and
generalized deduplication are applied before serialization.
"""
function serialize_payload(
    p::GDStaticPayloadSerde{T},
    weights::Vector{Float32}
)::Vector{UInt8} where T <: Unsigned
    # quantize weights
    qweights = [quantize(p.quantizer, w) for w in weights]

    # gd compression
    gdfile = compress!(p.store, qweights)

    # patching
    if p.is_client
        gdfile = GD.patch(gdfile, p.gdfile)
    else
        p.gdfile = gdfile
    end

    STATS.base.req_data = gdfile

    payload = GDPayload(gdfile, p.quantizer.minval, p.quantizer.maxval)

    return pack(payload)
end


"""
    deserialize_payload(GDPayloadSerde, data, from)

Deserializes `data` with the `GDPayloadSerde` where generalized deduplication
and dequantization are applied before deserialization.
"""
function deserialize_payload(
    p::GDStaticPayloadSerde{T},
    data::Vector{UInt8},
    from::String
)::Vector{Float32} where T <: Unsigned
    payload = unpack(data)

    # patching
    if p.is_client
        p.gdfile = payload.data
    else
        num_identical_hash = sum([1 for el in payload.data.hashes if el == [0x00]])
        num_identical_dev = sum([1 for el in payload.data.deviations if el == [0x00]])
        STATS.network.num_identical_hashes += num_identical_hash
        STATS.network.num_identical_devs += num_identical_dev

        payload.data = GD.unpatch(payload.data, p.gdfile)
    end

    push!(STATS.base.res_data, payload.data)

    # gd decompression
    STATS.network.num_unknown_bases += validate_remote!(p.store, payload.data, from)
    # since deserializing a client payload means the client is done with his work, we
    # can also update the number of requested bases, to make sure the one requested by
    # this client are taken into account.
    STATS.network.num_requested_bases = p.store.num_requested_bases


    qweights = extract(p.store, payload.data)

    # dequantize weights
    weights = [dequantize(p.quantizer, w) for w in qweights]

    return weights
end



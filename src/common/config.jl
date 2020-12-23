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
end


# # load and parse configuration
# conf = ConfParse("./config.ini")
# parse_conf!(conf)


# #--------------
# # Endpoints
# #--------------

# const SERVERURL = retrieve(conf, "endpoint", "serverurl")
# const REGISTER_NODE = retrieve(conf, "endpoint", "register_node")
# const FIT_NODE = retrieve(conf, "endpoint", "fit_node")
# const GD_BASES = retrieve(conf, "endpoint", "gd_bases")


# #--------------
# # Serialization
# #--------------

# const PAYLOAD_SERDE = retrieve(conf, "serialization", "payload_serde")


# #--------------
# # Quantization
# #--------------

# datatype = Dict(
#     "UInt8" => UInt8,
#     "UInt16" => UInt16,
#     "Float32" => Float32
# )

# const QDTYPE = datatype[retrieve(conf, "quantization", "qdtype")]
# const QMIN = parse(QDTYPE, retrieve(conf, "quantization", "qmin"))
# const QMAX = parse(QDTYPE, retrieve(conf, "quantization", "qmax"))


# #--------------
# # GD
# #--------------

# hashfunc = Dict(
#     "sha1" => sha1,
#     "crc32" => crc32c
# )

# const CHUNKSIZE = parse(Int, retrieve(conf, "gd", "chunksize"))
# const FINGERPRINT = hashfunc[retrieve(conf, "gd", "fingerprint")]
# const PERMUTATIONS_FILE = retrieve(conf, "gd", "permutations_file")


# # Transform
# const MSBSIZE = parse(QDTYPE, retrieve(conf, "transform", "msbsize"))

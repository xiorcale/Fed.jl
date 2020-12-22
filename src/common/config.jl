using  CRC32c
using SHA
# using JLD

#------------------
# Server endpoints
#------------------

const SERVERURL = "http://127.0.0.1:8080"

const REGISTER_NODE = "/register"


#------------------
# Client endpoints
#------------------

const FIT_NODE = "/fit"


#------------------
# GD endpoints
#------------------

const GD_BASES = "/bases"


#----------------
# Serde config
#----------------

# quantization
const QDTYPE = UInt8
const MINVAL = 0x00
const MAXVAL = 0xFF

# const QDTYPE = UInt16
# const MINVAL = 0x0000
# const MAXVAL = 0xFFFF

# const QDTYPE = Float32
# const MINVAL = -1.0
# const MAXVAL = 1.0

# permutation
const PERMUTATIONS_FILE = "./permutations.jld"

# generalized deduplication
const FINGERPRINT = sha1
# const FINGERPRINT = crc32c

const CHUNKSIZE = 256
const MSBSIZE = 0x05


# function save_config()
#     save(
#         "config.jld",
#         "serverurl", SERVERURL,
#         "register_node", REGISTER_NODE,
#         "fit_node", FIT_NODE,
#         "gd_bases", GD_BASES,
#         "qdtype", QDTYPE,
#         "minval", MINVAL,
#         "maxval", MAXVAL,
#         "permutations_file", PERMUTATIONS_FILE,
#         "chunksize", CHUNKSIZE,
#         "msbsize", MSBSIZE
#     )
# end
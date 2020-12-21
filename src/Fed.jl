module Fed


include("common/config.jl")
export QDTYPE, MINVAL, MAXVAL, REGISTER_NODE, FIT_NODE, CHUNKSIZE, MSBSIZE, SERVERURL, GD_BASES

include("common/tools.jl")
export curry


include("serde/Serde.jl")
using .Serde:  PayloadSerde, serialize_payload, deserialize_payload
export PayloadSerde, serialize_payload, deserialize_payload


include("server/Server.jl")
include("client/Client.jl")


end # module
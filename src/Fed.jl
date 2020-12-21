module Fed

include("serde/Serde.jl")
using .Serde:  PayloadSerde, serialize_payload, deserialize_payload
export PayloadSerde, serialize_payload, deserialize_payload

# global config, where both Client and Server need to use the same configuration.
const QDTYPE = UInt8
const MINVAL = 0x00
const MAXVAL = 0xFF


include("server/Server.jl")
include("client/Client.jl")

include("common/tools.jl")
export curry

end # module
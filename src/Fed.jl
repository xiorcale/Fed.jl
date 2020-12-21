module Fed

include("serde/Serde.jl")
using .Serde:  PayloadSerde, serialize_payload, deserialize_payload
export PayloadSerde, serialize_payload, deserialize_payload

include("server/Server.jl")
include("client/Client.jl")

include("common/tools.jl")
export curry

end # module
module Fed


# include("common/config.jl")
# export QDTYPE, QMIN, QMAX, REGISTER_NODE, FIT_NODE, CHUNKSIZE, MSBSIZE, SERVERURL, GD_BASES, FINGERPRINT, PERMUTATIONS_FILE, PAYLOAD_SERDE

include("common/tools.jl")
export curry


include("serde/Serde.jl")
using .Serde:  PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload
export PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload


include("common/config.jl")
export Config


# include("stats/Stats.jl")
# using .Stats: AllStats, update_stats!, QStats, update_qstats!
# export AllStats, update_stats!, QStats, update_qstats!


include("server/Server.jl")
include("client/Client.jl")


end # module
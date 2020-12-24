module Fed


include("common/tools.jl")
export curry


include("stats/Stats.jl")
using .Stats: Statistics, BaseStats, VanillaStats, update_stats!, initialize_stats, STATS, compute_changes_per_weights, compute_round_changes
export Statistics, BaseStats, VanillaStats, update_stats!, initialize_stats, STATS, compute_changes_per_weights, compute_round_changes


include("serde/Serde.jl")
using .Serde:  PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload
export PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload


include("common/config.jl")
export Config


include("server/Server.jl")
include("client/Client.jl")


end # module
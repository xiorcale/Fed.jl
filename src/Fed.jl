module Fed


abstract type Statistics end
STATS = Statistics
export Statistics, STATS

include("common/tools.jl")
export curry


include("serde/Serde.jl")
using .Serde:  PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload, pack, unpack
export PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload, pack, unpack


include("config/Config.jl")
using .Config: Configuration, VanillaConfig, QuantizedConfig, GDConfig, CommonConfig


include("stats/Stats.jl")
using .Stats: CommonStats, VanillaStats, GDStats, VanillaNetStats, GDNetStats, update_stats!, compute_elements_difference, compute_changes_per_element, compute_round_changes
export CommonStats, VanillaStats, GDStats, VanillaNetStats, GDNetStats, update_stats, compute_elements_difference, compute_changes_per_element, compute_round_changes


function initialize_stats(config::Configuration, num_weights::Int)
    global STATS = VanillaStats{config.common.dtype}(config, num_weights)
end


function initialize_stats(config::GDConfig, num_weights::Int)
    global STATS = GDStats{config.common.dtype}(config, num_weights)
end

export initialize_stats


include("server/Server.jl")
include("client/Client.jl")


end # module
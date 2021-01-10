module Fed


abstract type Statistics end
STATS = Statistics
export Statistics, STATS


include("serde/Serde.jl")
using .Serde


include("config/Config.jl")
using .Config


include("stats/Stats.jl")
using .Stats


function initialize_stats(config::VanillaConfig, num_weights::Int)
    global STATS = VanillaStats{Float32}(config, num_weights)
end

function initialize_stats(config::QuantizedConfig{T}, num_weights::Int) where T <: Unsigned
    global STATS = VanillaStats{T}(config, num_weights)
end

function initialize_stats(config::QuantizedDedupConfig{T}, num_weights::Int) where T <: Unsigned
    global STATS = VanillaStats{T}(config, num_weights)
end

function initialize_stats(config::GDConfig{T}, num_weights::Int) where T <: Unsigned
    global STATS = GDStats{T}(config, num_weights)
end

export initialize_stats


include("server/Server.jl")
include("client/Client.jl")


end # module
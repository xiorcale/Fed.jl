module Config

using ..Fed: PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde

abstract type Configuration end
export Configuration

include("common_config.jl")
export CommonConfig

include("vanilla_config.jl")
export VanillaConfig

include("quantized_config.jl")
export QuantizedConfig

include("gd_config.jl")
export GDConfig

end # module
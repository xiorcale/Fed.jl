module Config


"""
    Configuration

Interface used by the `CentralNode` and the `Node` to work with any 
configuration.
"""
abstract type Configuration end


# --------------------------------
# Include
# --------------------------------

include("base_config.jl")
include("vanilla_config.jl")
include("quantized_config.jl")
include("quantized_dedup_config.jl")
include("gd_config.jl")


# --------------------------------
# Export
# --------------------------------

export Configuration, BaseConfig, VanillaConfig, QuantizedConfig,
    QuantizedDedupConfig, GDConfig


end # module

using ..Serde: QuantizedPayloadSerde


"""
    QuantizedConfig{T <: Unsigned}(base::BaseConfig) <: Configuration

Configuration for compression through quantization. The quantization type needs
to be speficied when the configuration is instanciated. This configuration
instanciates a  [QuantizedPayloadSerde](@ref).
"""
struct QuantizedConfig{T <: Unsigned} <: Configuration
    base::BaseConfig
    payload_serde::QuantizedPayloadSerde{T}

    QuantizedConfig{T}(base::BaseConfig) where T <: Unsigned = 
        new(base, QuantizedPayloadSerde{T}())
end

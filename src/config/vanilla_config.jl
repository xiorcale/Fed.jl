using ..Serde: VanillaPayloadSerde


"""
    VanillaConfig(base)

Configuration for the baseline, where no compression is applied. The raw data
are sent over the network.
"""
struct VanillaConfig <: Configuration
    base::BaseConfig
    payload_serde::VanillaPayloadSerde
    VanillaConfig(base::BaseConfig) = new(base, VanillaPayloadSerde())
end

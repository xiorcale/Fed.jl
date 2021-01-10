struct VanillaConfig{T <: Real} <: Configuration
    common::CommonConfig{T}
    payload_serde::VanillaPayloadSerde

    VanillaConfig{T}(
        common_config::CommonConfig{T}
    ) where T <: Real = new(
        common_config,
        VanillaPayloadSerde()
    )
end
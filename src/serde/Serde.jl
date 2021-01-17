module Serde


# --------------------------------
# Include
# --------------------------------

# tools
include("packing.jl")
include("quantizer.jl")
include("delta_compressor.jl")

# payload serde
include("payloads/payload.jl")
include("payloads/vanilla_payload.jl")
include("payloads/quantized_payload.jl")
include("payloads/qdiff_payload.jl")
include("payloads/qdiff_static_payload.jl")
include("payloads/gd_payload.jl")
include("payloads/gd_static_payload.jl")


# --------------------------------
# Export
# --------------------------------
export pack, unpack, Quantizer, quantize, dequantize, Patch, diff, patch,
    PayloadSerde, serialize_payload, deserialize_payload, VanillaPayloadSerde, 
    QuantizedPayloadSerde, QDiffPayloadSerde, QDiffStaticPayloadSerde,
    GDPayloadSerde


end # module

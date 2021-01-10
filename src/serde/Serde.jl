module Serde


# --------------------------------
# Include
# --------------------------------

# tools
include("packing.jl")
include("quantizer.jl")
include("diff_deduplication.jl")

# payload serde
include("payloads/payload.jl")
include("payloads/vanilla_payload.jl")
include("payloads/quantized_payload.jl")
include("payloads/quantized_dedup_payload.jl")
include("payloads/gd_payload.jl")


# --------------------------------
# Export
# --------------------------------
export pack, unpack, Quantizer, quantize, dequantize, to_chunks, 
    diff_deduplication, reverse_diff_deduplication, PayloadSerde, 
    serialize_payload, deserialize_payload, VanillaPayloadSerde, 
    QuantizedPayloadSerde, QuantizedDedupPayloadSerde, GDPayloadSerde


end # module

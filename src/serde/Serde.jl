module Serde

include("packing.jl")
export pack, unpack

include("quantizer.jl")
export Quantizer, quantize, dequantize

include("deduplication.jl")
export to_chunks, diff, patch_quantized, unpatch_quantized

include("payloads/payload.jl")
export PayloadSerde, serialize_payload, deserialize_payload

include("payloads/vanilla_payload.jl")
export VanillaPayloadSerde, serialize_payload, deserialize_payload

include("payloads/quantized_payload.jl")
export QuantizedPayloadSerde, serialize_payload, deserialize_payload

include("payloads/quantized_dedup_payload.jl")
export QuantizedDedupPayloadSerde, serialize_payload, deserialize_payload

include("payloads/gd_payload.jl")
export GDPayloadSerde, serialize_payload, deserialize_payload

end # module
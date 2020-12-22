module Serde

include("packing.jl")

include("quantizer.jl")
export Quantizer, quantize, dequantize

include("payloads/payload.jl")
export PayloadSerde, serialize_payload, deserialize_payload

include("payloads/vanilla_payload.jl")
export VanillaPayloadSerde, serialize_payload, deserialize_payload

include("payloads/quantized_payload.jl")
export QuantizedPayloadSerde, serialize_payload, deserialize_payload

include("payloads/gd_payload.jl")
export GDPayloadSerde, serialize_payload, deserialize_payload

end # module
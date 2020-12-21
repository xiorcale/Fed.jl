module Serde

include("packing.jl")

include("quantizer.jl")
export Quantizer, quantize, dequantize

include("payload.jl")
export Payload, PayloadSerializer, serialize_payload, deserialize_payload

end # module
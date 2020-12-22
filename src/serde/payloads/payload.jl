abstract type PayloadSerde end

function serialize_payload(p::PayloadSerde, weights::Vector{Float32})::Vector{UInt8} end
function deserialize_payload(p::PayloadSerde, data::Vector{UInt8}; from::String)::Vector{Float32} end
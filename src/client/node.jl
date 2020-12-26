using HTTP
using ..Fed: PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload
using ..Fed: Configuration

struct Node{T <: Real}
    # networking
    host::String
    port::Int

    # hook
    fit::Function

    config::Configuration

    Node{T}(host, port, fit, config) where T <: Real = begin
        new(host, port, fit, config)
    end
end


"""
    register_to_server(node, config)

Register the `node` to the server, letting it knows that it is available to take
part in the training.
"""
function register_to_server(node::Node)::HTTP.Response
    endpoint = node.config.common.serverurl * node.config.common.register_node
    payload = "http://$(node.host):$(node.port)"
    response = HTTP.request("POST", endpoint, [], payload)
    return response
end

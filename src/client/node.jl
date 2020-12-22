using HTTP
using ..Fed: PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload
using ..Fed: QDTYPE, MINVAL, MAXVAL, REGISTER_NODE, SERVERURL


struct Node
    host::String
    port::Int
    payload_serde::QuantizedPayloadSerde{QDTYPE}

    fit::Function

    Node(host, port, fit) = begin
        payload_serde = QuantizedPayloadSerde{QDTYPE}(MINVAL, MAXVAL)
        new(host, port, payload_serde, fit)
    end
end


"""
    register_to_server(node, config)

Register the `node` to the server, letting it knows that it is available to take
part in the training.
"""
function register_to_server(node::Node)::HTTP.Response
    endpoint = SERVERURL * REGISTER_NODE
    payload = "http://$(node.host):$(node.port)"
    response = HTTP.request("POST", endpoint, [], payload)
    return response
end

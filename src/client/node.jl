using HTTP
using ..Fed: PayloadSerde, serialize_payload, deserialize_payload


struct Config
    serverurl::String

    Config() = new("http://127.0.0.1:8080")
end

struct Node
    host::String
    port::Int
    payload_serde::PayloadSerde{UInt8}

    fit::Function

    Node(host, port, fit) = begin
        payload_serde = PayloadSerde{UInt8}(0x00, 0xff)
        new(host, port, payload_serde, fit)
    end
end


"""
    register_to_server(node, config)

Register the `node` to the server, letting it knows that it is available to take
part in the training.
"""
function register_to_server(node::Node, config::Config)::HTTP.Response
    endpoint = config.serverurl * REGISTER_NODE
    payload = "http://$(node.host):$(node.port)"
    response = HTTP.request("POST", endpoint, [], payload)
    return response
end

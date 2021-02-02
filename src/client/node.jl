using HTTP
using ..Fed: Configuration, serialize_payload, deserialize_payload


"""
    Node(host, port, fit, config)

Orchestrate the training on local data of the clients participating in the
federated training. A `Node` is registerating itself to the server on startup,
and then wait for server requests for training on its local data.

The `fit` function is called "proxied function". It should define the training
loop and respect the following signature:

    fit(weights::Vector{Float32})::Vector{Float32}

Where `weights` is a flatten 1D array contianing the model parameters.
"""
struct Node
    host::String
    port::Int
    fit::Function
    config::Configuration
end


"""
    register_to_server(node::Node)

Register the `node` to the server, letting it knows that a node is available to
take part in the training.

!!! info

    **API Client**: this is an HTTP client request.
"""
function register_to_server(node::Node)::HTTP.Response
    endpoint = node.config.base.serverurl * node.config.base.register_node
    payload = "http://$(node.host):$(node.port)"
    response = HTTP.request("POST", endpoint, [], payload)
    return response
end


"""
    fit_service(node::Node, request::HTTP.Request)

Fit the received weights contained in the `request` with the node's local data,
and return the updated weights to the caller. This function is calling the
"proxied function" `fit` from the `Node`.

!!! info

    **API Endpoint**: this is an HTTP client endpoint.
"""
function fit_service(node::Node, request::HTTP.Request)::HTTP.Response
    weights = deserialize_payload(node.config.payload_serde, request.body, "http://127.0.0.1:9090")
    weights = node.fit(weights)
    payload = serialize_payload(node.config.payload_serde, weights)
    return HTTP.Response(200, payload)
end

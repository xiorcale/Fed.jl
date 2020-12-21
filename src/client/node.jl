using HTTP
using Sockets: IPv4, getipaddr

struct Config
    serverurl::String
end

struct Node
    host::IPv4
    port::Int

    fit::Function
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

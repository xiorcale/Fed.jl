using HTTP
using ..Fed: Serde


"""
    fit_service(node, request)

Endpoint which fit the received weights contained in the `request` with the node
local data, and return the updated weights to the caller.
"""
function fit_service(node::Node, request::HTTP.Request)::HTTP.Response
    weights = deserialize_payload(node.config.payload_serde, request.body, SERVERURL)
    weights = node.fit(weights)
    payload = serialize_payload(node.config.payload_serde, weights)
    return HTTP.Response(200, payload)
end

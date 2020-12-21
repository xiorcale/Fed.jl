using HTTP


"""
    fit_service(node, request)

Endpoint which fit the received weights contained in the `request` with the node
local data, and return the updated weights to the caller.
"""
function fit_service(node::Node, request::HTTP.Request)::HTTP.Response
    weights = unpack(request.body) # Vector{Float32}

    weights = node.fit(weights) # updated Vector{Float32}

    # GD -> transform -> ... -> pack
    payload = pack(weights)

    return HTTP.Response(200, payload)
end
using GD
using HTTP
using ..Fed: curry, FIT_NODE, GD_BASES


"""
    build_router(node)

Builds the routes to the node endpoints.
"""
function build_router(node::Node)
    router = HTTP.Router()

    HTTP.@register(router, "POST", FIT_NODE, curry(fit_service, node))
    HTTP.@register(router, "GET", GD_BASES, curry(GD.return_bases, node.payload_serde.store))

    return router
end


function start_client(node::Node)
    router = build_router(node)

    response = register_to_server(node)
    @assert response.status == 200
    @info "[$(node.host):$(node.port)] $(String(response.body))"

    HTTP.serve(router, node.host, node.port)
end

using ..Fed: initialize_stats
using GD
using HTTP


"""
    build_router(node)

Builds the routes to the node endpoints.
"""
function build_router(node::Node)
    router = HTTP.Router()

    HTTP.@register(
        router,
        "POST",
        node.config.base.fit_node,
        (request::HTTP.Request) -> fit_service(node, request)
    )

    return router
end


"""
    start(node)

Start the given `node` by setting up its router, and registering it to the
server.
"""
function start(node::Node)
    router = build_router(node)

    # hackish way to prevent PayloadSerde to fail while recording stats
    initialize_stats(node.config, 0)

    response = register_to_server(node)
    @assert response.status == 200
    @info "[$(node.host):$(node.port)] $(String(response.body))"

    HTTP.serve(router, node.host, node.port)
end

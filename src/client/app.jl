using GD
using HTTP
using ..Fed: curry, initialize_stats


"""
    build_router(node)

Builds the routes to the node endpoints.
"""
function build_router(node::Node)
    router = HTTP.Router()

    HTTP.@register(router, "POST", node.config.fit_node, curry(fit_service, node))

    # setup GD store endpoint if we're unsing GDPayloadSerde
    if typeof(node.config.payload_serde) == GDPayloadSerde{node.config.qdtype}
        HTTP.@register(router, "GET", node.config.gd_bases, curry(GD.return_bases, node.config.payload_serde.store))
    end

    return router
end


function start_client(node::Node)
    router = build_router(node)

    # hackish way to prevent PayloadSerde to fail while recording stats
    initialize_stats(
        node.config.stats_type,
        node.config.qdtype,
        0, 0.0f0, 0, 0
    )

    response = register_to_server(node)
    @assert response.status == 200
    @info "[$(node.host):$(node.port)] $(String(response.body))"

    HTTP.serve(router, node.host, node.port)
end

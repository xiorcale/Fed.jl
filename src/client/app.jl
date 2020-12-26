using GD
using HTTP
using ..Fed: curry, initialize_stats, VanillaConfig, QuantizedConfig, GDConfig

"""
    build_router(node)

Builds the routes to the node endpoints.
"""
function build_router(node::Node)
    router = HTTP.Router()

    HTTP.@register(router, "POST", node.config.common.fit_node, curry(fit_service, node))

    # setup GD store endpoint if we're unsing GDPayloadSerde
    if typeof(node.config) == GDConfig{node.config.common.dtype}
        HTTP.@register(router, "GET", node.config.common.gd_bases, curry(GD.return_bases, node.config.payload_serde.store))
    end

    return router
end


function start_client(node::Node)
    router = build_router(node)

    # hackish way to prevent PayloadSerde to fail while recording stats
    initialize_stats(node.config, 0)

    response = register_to_server(node)
    @assert response.status == 200
    @info "[$(node.host):$(node.port)] $(String(response.body))"

    HTTP.serve(router, node.host, node.port)
end

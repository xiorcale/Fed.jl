using HTTP

"""
    build_router(node)

Builds the routes to the node endpoints.
"""
function build_router(node::Node)
    router = HTTP.Router()

    HTTP.@register(router, "POST", FIT_NODE, curry(fit_service, node))

    return router
end


function start_client(node::Node, config::Config)
    router = build_router(node)

    response = register_to_server(node, config)
    @assert response.status == 200

    HTTP.serve(router, node.host, node.port)
end

using GD
using HTTP


"""
    build_router(central_node)

Builds the routes to the central node endpoints.
"""
function build_router(central_node::CentralNode)::HTTP.Router
    router = HTTP.Router()

    HTTP.@register(
        router,
        "POST",
        central_node.config.base.register_node,
        (request::HTTP.Request) -> register_client!(central_node.client_manager, request)
    )

    return router
end


"""
    start_server()

Start a Fed.jl HTTP server.
"""
function start(central_node::CentralNode)
    router = build_router(central_node)

    # start the HTTP server
    s = @async HTTP.serve(router, central_node.host, central_node.port)

    # wait for all the clients to join...
    wait_for(central_node.client_manager, central_node.config.base.num_total_clients)

    # federated training
    fit(central_node)

    # stop the HTTP server
    @async Base.throwto(s,  InterruptException())
end

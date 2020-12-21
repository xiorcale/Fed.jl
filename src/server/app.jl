using HTTP


"""
    build_router(client_manager)

Builds the routes to the central node endpoints.
"""
function build_router(cm::ClientManager)::HTTP.Router
    router = HTTP.Router()

    HTTP.@register(router, "POST", REGISTER_NODE, curry(register_client!, cm))

    return router
end


"""
    start_server()

Start a Fed.jl HTTP server.
"""
function start_server(central_node::CentralNode, config::Config)
    router = build_router(central_node.client_manager)

    # start the HTTP server
    s = @async HTTP.serve(router, central_node.host, central_node.port)

    # wait for all the clients to join...
    wait_for(central_node.client_manager, config.num_total_clients)

    # federated training
    fit(central_node, config)

    # stop the HTTP server
    @async Base.throwto(s,  InterruptException())
end

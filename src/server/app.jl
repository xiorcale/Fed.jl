using GD
using HTTP
using ..Fed: curry, REGISTER_NODE, GD_BASES



"""
    build_router(client_manager)

Builds the routes to the central node endpoints.
"""
function build_router(central_node::CentralNode)::HTTP.Router
    router = HTTP.Router()

    HTTP.@register(router, "POST", REGISTER_NODE, curry(register_client!, central_node.client_manager))
    HTTP.@register(router, "GET", GD_BASES, curry(GD.return_bases, central_node.payload_serde.store))

    return router
end


"""
    start_server()

Start a Fed.jl HTTP server.
"""
function start_server(central_node::CentralNode)
    router = build_router(central_node)

    # start the HTTP server
    s = @async HTTP.serve(router, central_node.host, central_node.port)

    # wait for all the clients to join...
    wait_for(central_node.client_manager, central_node.config.num_total_clients)

    # federated training
    fit(central_node)

    # stop the HTTP server
    @async Base.throwto(s,  InterruptException())
end

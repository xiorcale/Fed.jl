using GD
using HTTP
using ..Fed: curry, VanillaConfig, QuantizedConfig, GDConfig



"""
    build_router(client_manager)

Builds the routes to the central node endpoints.
"""
function build_router(central_node::CentralNode)::HTTP.Router
    router = HTTP.Router()

    HTTP.@register(router, "POST", central_node.config.common.register_node, curry(register_client!, central_node.client_manager))

    # setup GD store endpoint if we're unsing GDPayloadSerde
    try
        HTTP.@register(router, "GET", central_node.config.common.gd_bases, curry(GD.return_bases, central_node.config.payload_serde.store))
    catch
        # nothing to do, it is not a GD config...
    end

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
    wait_for(central_node.client_manager, central_node.config.common.num_total_clients)

    # federated training
    fit(central_node)

    # stop the HTTP server
    @async Base.throwto(s,  InterruptException())
end

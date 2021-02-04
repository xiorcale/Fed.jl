module Server


# --------------------------------
# Include
# --------------------------------

include("startegy/federated_averaging.jl")

include("client_manager.jl")
include("central_node.jl")
include("service.jl")
include("app.jl")


# --------------------------------
# Export
# --------------------------------

export federated_averaging, ClientManager, length, num_available_clients, 
    register, sample_clients, CentralNode, register_client, start, build_router


end # module

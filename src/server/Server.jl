module Server


include("startegy/federated_averaging.jl")
export federated_averaging

include("client_manager.jl")
export ClientManager, length, num_available_clients, register, sample_clients

include("central_node.jl")
export CentralNode

include("service.jl")
export register_client

include("app.jl")
export start_server


end # module
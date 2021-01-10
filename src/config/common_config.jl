"""
    CommonConfig

Part of the configuration common to any type of configuration.
"""
struct CommonConfig{T <: Real} 
    dtype::Type{T}

    # endpoints
    serverurl::String
    register_node::String
    fit_node::String

    # federated learning
    num_comm_rounds::Int
    fraction_clients::Float32
    num_total_clients::Int

    CommonConfig{T}(
        serverurl::String,
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
    ) where T <: Real = new(
        T,
        serverurl,
        "/register",
        "/fit",
        num_comm_rounds,
        fraction_clients,
        num_total_clients
    )
end

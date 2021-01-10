"""
    BaseConfig

Parts of the configuration which are common to any type of configuration.
"""
struct BaseConfig
    # endpoints
    serverurl::String
    register_node::String
    fit_node::String

    # federated learning
    num_comm_rounds::Int
    fraction_clients::Float32
    num_total_clients::Int

    BaseConfig(
        serverurl::String,
        num_comm_rounds::Int,
        fraction_clients::Float32,
        num_total_clients::Int,
    ) = new(
        serverurl,
        "/register",
        "/fit",
        num_comm_rounds,
        fraction_clients,
        num_total_clients
    )
end

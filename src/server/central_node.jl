using JLD
using HTTP
using ..Fed: PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload
using ..Fed: Configuration, STATS, update_stats!, initialize_stats


struct CentralNode{T <: Real}
    # networking
    host::String
    port::Int
    client_manager::ClientManager

    # machine learning
    weights::Vector{Float32}
    strategy::Function

    # hook
    evaluate::Function

    config::Configuration

    CentralNode{T}(
        host::String,
        port::Int,
        weights::Vector{Float32},
        strategy::Function,
        evaluate::Function,
        config::Configuration
    ) where T <: Real = begin

        client_manager = ClientManager()

        return new(
            # networking
            host, port, client_manager, 
           
            # ml
            weights, strategy,
           
            # hook
            evaluate,
            
            config
        )
    end
end


function fit(central_node::CentralNode)
    global_weights = central_node.weights

    initialize_stats(central_node.config, length(global_weights))

    for round_num in 1:central_node.config.common.num_comm_rounds
        @info "Communication round $round_num"

        # chose the clients subset for the round
        clients = sample_clients(central_node.client_manager, central_node.config.common.fraction_clients)

        # serialize the global model
        payload = serialize_payload(central_node.config.payload_serde, global_weights)

        # ask clients to train on the global model
        clients_payload = fit_clients(central_node.config.common.fit_node, clients, payload)

        # deserialize the results
        round_weights = [
            deserialize_payload(central_node.config.payload_serde, payload, clients[i])
            for (i, payload) in enumerate(clients_payload)
        ]

        # update the global model
        global_weights = central_node.strategy(round_weights)

        # evaluate global model
        loss, acc = central_node.evaluate(global_weights)
        @info "loss: $loss, acc: $acc"

        # record statistics
        update_stats!(STATS, round_num, loss, acc)

        save("stats.jld", "stats", STATS)
    end
end


"""
    fit_clients(clients, payload)

Ask each client from `clients` to train on their local data, by using the model
weights contained in the `payload`. Returns a `Vector` where each element is the
serialized weights of one client.
"""
function fit_clients(fit_node::String, clients::Vector{String}, payload::Vector{UInt8})::Vector{Vector{UInt8}}
    # asynchronously ask the clients subset to train
    tasks = [@async fit_client(fit_node, client, payload) for client in clients]
    wait.(tasks)

    round_weights = map(task -> task.result, tasks)

    return round_weights
end


"""
    fit_client(client, payload)

Asks one `client` to train on its local data, by using the model weights
contained in the `payload`. Returns the serialized updated `weights`.
"""
function fit_client(fit_node::String, client::String, payload::Vector{UInt8})::Vector{UInt8}
    endpoint = client *  fit_node
    response = HTTP.request("POST", endpoint, [], payload)
    return response.body
end

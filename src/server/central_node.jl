using JLD
using HTTP
using ..Fed: PayloadSerde, VanillaPayloadSerde, QuantizedPayloadSerde, GDPayloadSerde, serialize_payload, deserialize_payload
# using ..Fed: AllStats, update_stats!, QStats, update_qstats!
using ..Fed: Config


struct CentralNode{T <: Real}
    # networking
    host::String
    port::Int
    client_manager::ClientManager

    # machine learning
    weights::Vector{Float32}
    strategy::Function

    # federated learning
    num_comm_rounds::Int
    fraction_clients::Float32
    num_total_clients::Int

    # hook
    evaluate::Function

    config::Config{T}

    # stats
    # stats::QStats

    CentralNode{T}(
        host::String,
        port::Int,
        weights::Vector{Float32},
        strategy::Function,
        evaluate::Function,
        config::Config{T}
    ) where T <: Real = begin

        client_manager = ClientManager()
       
        num_comm_rounds = 100
        fraction_clients = 0.1f0
        num_total_clients = 100

        # stats = QStats(
        #     config.num_comm_rounds,
        #     config.num_total_clients,
        #     max(round(Int, config.fraction_clients * config.num_total_clients), 1),
        #     length(weights)
        # )

        # stats = AllStats(
        #     config.num_comm_rounds,
        #     config.num_total_clients,
        #     max(round(Int, config.fraction_clients * config.num_total_clients), 1),
        #     length(weights),
        #     # payload_serde.store.compressor
        # )

        return new(
            # networking
            host, port, client_manager, 
           
            # ml
            weights, strategy,
           
            # fl
            num_comm_rounds, fraction_clients, num_total_clients,
           
            # hook
            evaluate,
            
            config
        )
    end
end


function fit(central_node::CentralNode)
    global_weights = central_node.weights

    for round_num in 1:central_node.num_comm_rounds
        @info "Communication round $round_num"

        # chose the clients subset for the round
        clients = sample_clients(central_node.client_manager, central_node.fraction_clients)

        # serialize the global model
        req_weights = global_weights
        payload = serialize_payload(central_node.config.payload_serde, global_weights)

        # ask clients to train on the global model
        clients_payload = fit_clients(central_node.config.fit_node, clients, payload)

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
        # database_length = length(central_node.payload_serde.store.database)
        # num_requested_bases = central_node.payload_serde.store.num_requested_bases
        # num_unknown_bases = central_node.payload_serde.store.num_unknown_bases
        
        # update_stats!(
        #     central_node.stats,
        #     round_num,
        #     acc,
        #     loss,
        #     database_length,
        #     num_requested_bases,
        #     num_unknown_bases 
        # )

        # update_qstats!(central_node.stats, round_num, acc, loss, req_weights, round_weights)

        # save("stats.jld", "stats", central_node.stats)
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

    round_weights = map(task -> task.result, tasks) # decompression could occurs here?

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

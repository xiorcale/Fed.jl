using JLD
using HTTP
using ..Fed: PayloadSerde, serialize_payload, deserialize_payload
using ..Fed: QDTYPE, MINVAL, MAXVAL, FIT_NODE
using ..Fed: AllStats, update_stats!


struct Config
    # machine learning
    weights::Vector{Float32}
    strategy::Function

    # networking
    num_comm_rounds::Int
    fraction_clients::Float32
    num_total_clients::Int

    Config(weights, strategy, num_comm_rounds, fraction_clients, num_total_clients) =
        new(weights, strategy, num_comm_rounds, fraction_clients, num_total_clients)

    Config(weights, strategy) = begin
        num_comm_rounds = 100
        fraction_clients = 0.1
        num_total_clients = 100
        new(weights, strategy, num_comm_rounds, fraction_clients, num_total_clients)
    end
    
end


struct CentralNode
    host::String
    port::Int
    client_manager::ClientManager
    payload_serde::PayloadSerde{QDTYPE}
    evaluate::Function

    config::Config

     # stats
     stats::AllStats

    CentralNode(host::String, port::Int, evaluate::Function, weights::Vector{Float32}, strategy::Function) = begin
        client_manager = ClientManager()
        payload_serde = PayloadSerde{QDTYPE}(MINVAL, MAXVAL)

        config = Config(weights, strategy)

        stats = AllStats(
            config.num_comm_rounds,
            config.num_total_clients,
            max(round(Int, config.fraction_clients * config.num_total_clients), 1),
            length(weights),
            payload_serde.store.compressor
        )

        return new(
            host, port, 
            client_manager, 
            payload_serde, 
            evaluate,
            config,
            stats
        )
    end
end


function fit(central_node::CentralNode)
    global_weights = central_node.config.weights

    for round_num in 1:central_node.config.num_comm_rounds
        @info "Communication round $round_num"

        # chose the clients subset for the round
        clients = sample_clients(central_node.client_manager, central_node.config.fraction_clients)

        # serialize the global model
        payload = serialize_payload(central_node.payload_serde, global_weights)

        # ask clients to train on the global model
        clients_payload = fit_clients(clients, payload)

        # deserialize the results
        round_weights = [
            deserialize_payload(central_node.payload_serde, clients[i], payload)
            for (i, payload) in enumerate(clients_payload)
        ]

        # update the global model
        global_weights = central_node.config.strategy(round_weights)

        # evaluate global model
        loss, acc = central_node.evaluate(global_weights)
        @info "loss: $loss, acc: $acc"

        # record statistics
        database_length = length(central_node.payload_serde.store.database)
        num_requested_bases = central_node.payload_serde.store.num_requested_bases
        num_unknown_bases = central_node.payload_serde.store.num_unknown_bases
        
        update_stats!(
            central_node.stats,
            round_num,
            acc,
            loss,
            database_length,
            num_requested_bases,
            num_unknown_bases 
        )

        save("stats.jld", "stats", central_node.stats)
    end
end


"""
    fit_clients(clients, payload)

Ask each client from `clients` to train on their local data, by using the model
weights contained in the `payload`. Returns a `Vector` where each element is the
serialized weights of one client.
"""
function fit_clients(clients::Vector{String}, payload::Vector{UInt8})::Vector{Vector{UInt8}}
    # asynchronously ask the clients subset to train
    tasks = [@async fit_client(client, payload) for client in clients]
    wait.(tasks)

    round_weights = map(task -> task.result, tasks) # decompression could occurs here?

    return round_weights
end


"""
    fit_client(client, payload)

Asks one `client` to train on its local data, by using the model weights
contained in the `payload`. Returns the serialized updated `weights`.
"""
function fit_client(client::String, payload::Vector{UInt8})::Vector{UInt8}
    endpoint = client * FIT_NODE
    response = HTTP.request("POST", endpoint, [], payload)
    return response.body
end

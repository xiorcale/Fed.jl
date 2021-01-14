using JLD
using HTTP
using ..Config: Configuration
using ..Serde: serialize_payload, deserialize_payload, unpack
using ..Fed: STATS, update_stats!, initialize_stats


"""
    CentralNode(host, port, weights, strategy, evaluate, config)

`CentralNode` is orchestrating the entire federated learning process, handling
the clients registration and requesting them to train on their local data.
"""
struct CentralNode
    # networking
    host::String
    port::Int
    client_manager::ClientManager

    # machine learning
    weights::Vector{Float32}
    strategy::Function

    # proxy
    evaluate::Function

    config::Configuration

    CentralNode(
        host::String,
        port::Int,
        weights::Vector{Float32},
        strategy::Function,
        evaluate::Function,
        config::Configuration
    ) = new(host, port, ClientManager(), weights, strategy, evaluate, config)
end


function get_store_url(url)
    protocol, url, port = split(url, ":")
    return protocol * ":" * url * ":" * string(parse(Int, port) + 1010)
end


"""
    fit(central_node)

Fit the global model by orchestrating the federated training.
"""
function fit(central_node::CentralNode)
    global_weights = central_node.weights

    initialize_stats(central_node.config, length(global_weights))

    jldopen("data/request.jld", "w") do req_file
        jldopen("data/response.jld", "w") do res_file
            for round_num in 1:central_node.config.base.num_comm_rounds
                @info "Communication round $round_num"

                # uplink communication
                # 1. chose the clients subset for the round.
                clients = sample_clients(central_node.client_manager, central_node.config.base.fraction_clients)
                # 2. serialize the global model.
                payload = serialize_payload(central_node.config.payload_serde, global_weights)
                # 3. ask clients to train on the global model.
                clients_payload = fit_clients(central_node.config.base.fit_node, clients, payload)

                write(req_file, "$round_num", global_weights)
                client_w = map(p -> p.gdfile, unpack.(clients_payload))
                write(res_file, "$round_num", client_w)
                
                # downlink communication
                # 4. deserialize the results.
                round_weights = [
                    deserialize_payload(central_node.config.payload_serde, payload, get_store_url(clients[i]))
                    for (i, payload) in enumerate(clients_payload)
                ]

                # update, convergeance tracking, ...
                # 5. update the global model.
                global_weights = central_node.strategy(round_weights)
                # 6. evaluate global model.
                loss, acc = central_node.evaluate(global_weights)
                @info "loss: $loss, acc: $acc"

                # 7. record statistics.
                update_stats!(STATS, round_num, loss, acc)

                save("stats.jld", "stats", STATS)
            end
        end
    end
end


"""
    fit_clients(clients, payload)

Asks each client from `clients` to train on their local data, by using the model
weights contained in the `payload`. Returns a `Vector` where each element is the
serialized weights of one client.
"""
function fit_clients(
    fit_node::String,
    clients::Vector{String},
    payload::Vector{UInt8}
)::Vector{Vector{UInt8}}
    # asynchronously ask the clients subset to train, and wait on the results.
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
function fit_client(
    fit_node::String,
    client::String,
    payload::Vector{UInt8}
)::Vector{UInt8}
    endpoint = client *  fit_node
    response = HTTP.request("POST", endpoint, [], payload)
    return response.body
end

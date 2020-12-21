using HTTP

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

    Config(weights, strategy) = 
    new(weights, strategy, 100, 0.1, 100)
end


struct CentralNode
    host::String
    port::Int
    client_manager::ClientManager
    evaluate::Function

    CentralNode(host::String, port::Int, evaluate::Function) = begin
        client_manager = ClientManager()
        return new(host, port, client_manager, evaluate)
    end
end


function fit(central_node::CentralNode, config::Config)
    global_weights = config.weights
    
    for round_num in 1:config.num_comm_rounds
        @info "Communication round $round_num"

        # chose the clients subset for the round
        clients = sample_clients(central_node.client_manager, config.fraction_clients)
        # weights -> transform -> payload -> serialize
        payload = pack(global_weights)

        round_weights = fit_clients(clients, payload)

        global_weights = config.strategy(round_weights)

        # evaluate global model
        loss, acc = central_node.evaluate(global_weights)
        @info "loss: $loss, acc: $acc"
    end
end


"""
    fit_clients(clients, payload)

Ask each client from `clients` to train on their local data, by using the model
weights contained in the `payload`. Returns a `Vector` where each element is the
serialized weights of one client.
"""
function fit_clients(clients::Vector{String}, payload::Vector{UInt8})::Vector{Vector{Float32}}
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
function fit_client(client::String, payload::Vector{UInt8})::Vector{Float32}
    endpoint = client * FIT_NODE
    response = HTTP.request("POST", endpoint, [], payload)
    return unpack(response.body)
end

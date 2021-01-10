using SHA

@testset "Client" begin

    host = "127.0.0.1"
    server_port = 8080
    server_url = "http://" * host * ":" * string(server_port)

    num_comm_rounds = 1
    fraction_clients = 0.1f0
    num_total_clients = 10
    chunksize = 256

    newconfig() = Fed.Config.QuantizedConfig{UInt8}(
        Fed.Config.BaseConfig(
            server_url,
            num_comm_rounds,
            fraction_clients,
            num_total_clients
        )
    )

    function start_testing_server() 
        # dummy values for testing purpose
        weights = rand(Float32, 199210)
        strategy = Fed.Server.federated_averaging
        eval_hook = (weights::Vector{Float32}) -> (0.0f0, 0.0f0)
        config = newconfig()
        
        central_node = Fed.Server.CentralNode(
            host,
            server_port,
            weights,
            strategy,
            eval_hook,
            config
        )

        @async Fed.Server.start(central_node)
    end

    @testset "Start client" begin
        server = start_testing_server()

        train_hook = (weights::Vector{Float32}) -> weights
        config = newconfig()

        node = Fed.Client.Node(
            host,
            8081,
            train_hook,
            config
        )

        @async Fed.Client.start(node)
        sleep(2)
        @test true
    end

end
using SHA

@testset "Server" begin

    host = "127.0.0.1"
    port = 8080
    server_url = "http://" * host * ":" * string(port)
        
    num_comm_rounds = 1
    fraction_clients = 0.1f0
    num_total_clients = 10

    chunksize = 256
    is_client = false

    # dummy values for testing purpose
    weights = rand(Float32, 199210)
    strategy = Fed.Server.federated_averaging
    eval_hook = (weights::Vector{Float32}) -> (0.0f0, 0.0f0)

    common_config = Fed.Config.CommonConfig{UInt8}(
        server_url,
        num_comm_rounds,
        fraction_clients,
        num_total_clients
    )

    function start_stop_server(config)
        central_node = Fed.Server.CentralNode{config.common.dtype}(
            host,
            port,
            weights,
            strategy,
            eval_hook,
            config
        )

        # start and stop server
        task = @async Fed.Server.start_server(central_node)

        @test length(central_node.client_manager) == 0

        @async Base.throwto(task,  InterruptException())
    end

    @testset "Start vanilla config" begin
        local common_config = Fed.Config.CommonConfig{Float32}(
            server_url,
            num_comm_rounds,
            fraction_clients,
            num_total_clients
        )
        config = Fed.Config.VanillaConfig{Float32}(common_config)
        start_stop_server(config)
    end

    @testset "Start quantzed config" begin
        config = Fed.Config.QuantizedConfig{UInt8}(
            common_config,
            chunksize
        )
        start_stop_server(config)
    end

    @testset "Start deduplicated quantized config" begin
        config = Fed.Config.QuantizedDedupConfig{UInt8}(
            common_config,
            chunksize,
            is_client
        )
        start_stop_server(config)
    end

    @testset "Start GD config" begin
        config = Fed.Config.GDConfig{UInt8}(
            common_config,
            chunksize,
            sha1,
            0x05,
            host,
            9090,
            is_client
        )
        start_stop_server(config)
    end

end
using SHA

@testset "Payload" begin

    host = "127.0.0.1"
    port = 8080
    server_url = "http://" * host * ":" * string(port)
        
    num_comm_rounds = 1
    fraction_clients = 0.1f0
    num_total_clients = 10
    
    base_config = Fed.Config.BaseConfig(
        server_url,
        num_comm_rounds,
        fraction_clients,
        num_total_clients
    )

    weights = rand(Float32, 199210)
    chunksize = 256
    is_client = false

    function serde(config)
        Fed.initialize_stats(config, length(weights))
        data = Fed.Serde.serialize_payload(config.payload_serde, weights)
        return Fed.Serde.deserialize_payload(config.payload_serde, data, "http://127.0.0.1:9090")
    end

    @testset "Vanilla" begin
        config = Fed.Config.VanillaConfig(base_config)
        @test serde(config) == weights
    end

    @testset "Quantized" begin
        config = Fed.Config.QuantizedConfig{UInt8}(base_config)
        res = serde(config)
        @test sum(res - weights) / length(weights) < 0.1 # quantzation generates a small error
    end
    
    @testset "Quantized dedup" begin
        config = Fed.Config.QuantizedDedupConfig{UInt8}(base_config, chunksize, is_client)
        res = serde(config)
        @test sum(res - weights) / length(weights) < 0.1 # quantzation generates a small error
    end

    @testset "GD" begin
        config = Fed.Config.GDConfig{UInt8}(base_config, chunksize, sha1, 0x05, host, 9090, is_client)
        res = serde(config)
        @test sum(res - weights) / length(weights) < 0.1 # quantzation generates a small error
    end
end
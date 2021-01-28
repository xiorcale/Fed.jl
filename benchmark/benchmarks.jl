using BenchmarkTools
using Fed
using Random
using SHA

const suite = BenchmarkGroup()


suite["payload_serde"] = BenchmarkGroup(["serialize", "deserialize"])


# config
const SERVERURL = "http://127.0.0.1:8080"
const NUM_COMM_ROUNDS = 100
const FRACTION_CLIENTS = 0.1f0
const NUM_TOTAL_CLIENTS = 100

const base_config = Fed.Config.BaseConfig(
    SERVERURL,
    NUM_COMM_ROUNDS,
    FRACTION_CLIENTS,
    NUM_TOTAL_CLIENTS
)

weights = rand(Float32, Int(1024*1024/4)) # 1MB
chunksize = 256


# Vanilla
vanilla_config = Fed.Config.VanillaConfig(base_config)
initialize_stats(vanilla_config, length(weights))
vanilla_payload = Fed.Serde.serialize_payload(vanilla_config.payload_serde, weights)

suite["payload_serde"]["vanilla_serialize"] = @benchmarkable Fed.Serde.serialize_payload(vanilla_config.payload_serde, weights)
suite["payload_serde"]["vanilla_deserialize"] = @benchmarkable Fed.Serde.deserialize_payload(vanilla_config.payload_serde, vanilla_payload, "")


# quantized
quantized_config = Fed.Config.QuantizedConfig{UInt8}(base_config)
initialize_stats(quantized_config, length(weights))
quantized_payload = Fed.Serde.serialize_payload(quantized_config.payload_serde, weights)

suite["payload_serde"]["quantized_serialize"] = @benchmarkable Fed.Serde.serialize_payload(quantized_config.payload_serde, weights)
suite["payload_serde"]["quantized_deserialize"] = @benchmarkable Fed.Serde.deserialize_payload(quantized_config.payload_serde, quantized_payload, "")


# qdiff
qdiff_config = Fed.Config.QDiffConfig{UInt8}(base_config, 256, false)
initialize_stats(qdiff_config, length(weights))
old_weights = deepcopy(weights)
old_weights[1:131072]  = rand(Float32, 131072)
old_weights = shuffle(old_weights)
qdiff_payload = Fed.Serde.serialize_payload(qdiff_config.payload_serde, old_weights)

qdiff_config.payload_serde.is_client = true
suite["payload_serde"]["qdiff_serialize"] = @benchmarkable Fed.Serde.serialize_payload(qdiff_config.payload_serde, weights)

qdiff_config.payload_serde.is_client = false
suite["payload_serde"]["qdiff_deserialize"] = @benchmarkable Fed.Serde.deserialize_payload(qdiff_config.payload_serde, qdiff_payload, "")

# gd
gd_config = Fed.Config.GDConfig{UInt8}(
    base_config,
    chunksize,
    sha1,
    # hash_crc32,
    round(UInt8, 0.6 * sizeof(UInt8) * 8),
    "127.0.0.1",
    9090,
    false
)

initialize_stats(gd_config, length(weights))
old_weights = deepcopy(weights)
old_weights[1:131072]  = rand(Float32, 131072)
gd_payload = Fed.Serde.serialize_payload(gd_config.payload_serde, old_weights)

gd_config.payload_serde.is_client = true
suite["payload_serde"]["gd_serialize"] = @benchmarkable Fed.Serde.serialize_payload(gd_config.payload_serde, weights)

gd_config.payload_serde.is_client = false
suite["payload_serde"]["gd_deserialize"] = @benchmarkable Fed.Serde.deserialize_payload(gd_config.payload_serde, gd_payload, "http://127.0.0.1:9090")


# Saving params

paramspath = joinpath(dirname(@__FILE__), "params.json")

if isfile(paramspath)
    loadparams!(suite, BenchmarkTools.load(paramspath)[1], :evals);
else
    tune!(suite)
    BenchmarkTools.save(paramspath, params(suite));
end
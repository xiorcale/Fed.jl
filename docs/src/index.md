# Fed.jl

`Fed.jl` is a framework-agnostic federated learning platform developed with
flexibility of configuration and extensibility in mind. The library does not
target a production environment but rather aims to facilitate research in the
field of federated learning. In particular, network traffic compression.

In summary, the platform leverages a client/server architecture where a central
server and multiple nodes communicate through HTTP APIs.


!!! warning

    Currently, `Fed.jl` does not offer any mechanics to handle disconnection or
    unavailable client/server. Thus, the server needs to be started first, and
    we assume every registered node to be always available.


## Getting started

The server has to be launched first and will wait on the clients before starting
the training. The minimum number of clients to wait on is specified in the
`BaseConfig`.


```julia
using Fed

# server url
host = "127.0.0.1"
port = 8080
serverurl = "http://" * host * ":" * string(port)

num_comm_round = 100
fraction_clients = 0.1f0
# the server will wait until 100 clients have joined to start the training
num_total_clients = 100

# setup the base config used for the federated training
base_config = BaseConfig(
    serverurl,
    num_comm_round,
    fraction_clients,
    num_total_clients
)

# pick a configuration (in this case, no compresison is applied)
config = Fed.Config.VanillaConfig(base_config)

# fake flatten parameters we want to train
weights = rand(Flaot32, 1000)

# pick an aggregation strategy
strategy = Fed.Server.federated_averaging

# proxied function to evaluate the global model. We need to define this function
# ousrself as its logic depend on the framework used.
eval_proxy = evaluate(weights)

# instanciate the server
central_node = Fed.Server.CentralNode(
    host,
    port,
    weights,
    strategy,
    eval_proxy,
    config
)

# finally, start the server
@info "Server started on [http://$host:$port]"
Fed.Server.start(central_node)
```

Once the server is up and running, we can start to launch clients which will
register themselves to the server.

```julia
# client url
host = "127.0.0.1"
port = 8081

# Be sure to define the same config as the one used by the server as this is 
# where is specified the compression scheme used for communication.
config = Fed.Config.VanillaConfig(base_config)

# proxied function to train the local model (training loop). We need to define
# this function ousrself as its logic depend on the framework used.
train_proxy = fit(weights)

# instanciate the client
node = Fed.Client.Node(host, port, train_proxy, config)

# finally, start the client
@info "Client started on [http://$host:$port]"
Fed.Client.start(node)
```


## Available configurations for compression

In the example above, we used a `VanillaConfig` which applies no compression.
However, there are other configurations with different compression schemes that
can be applied to reduce the communication cost. Their specifications are
described in [Serde](@ref).

- `VanillaConfig`: Classic serialization, without any compression
- `QuantizedConfig`: Lossy compression where the weights are quantized on `UInt8`
- `QDiffConfig`: Quantization + delta compression, only applicable for the server downlink
- `GDConfig`: Quantization + Generalized Deduplication (through [GD.jl](https://xiorcale.github.io/GD.jl/))

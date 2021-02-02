# Server

```@meta
CurrentModule = Fed.Server
```

The server is the orchestrator of the training, aggregating the results from the
clients to improve the global model. As the clients, it is independent of the
machine learning tools. The server can evaluate the global model by proxying an
`evaluate()` function.

## App

Entry point to start the `CentralNode`. The server must be started before
launching clients.

```@docs
build_router
start
```

## CentralNode

Data structure containing the server's configuration and its API for
communicating with the nodes.

```@docs
CentralNode
fit
fit_client
fit_clients
register_client!
```

## ClientManager

The `ClientManager` handles the nodes registrations and synchronize the server
to make it start when the clients are ready.

```@docs
ClientManager
length(::ClientManager)
num_available_clients
register!
sample_clients
wait_for
```

## Strategy

```@docs
federated_averaging
```
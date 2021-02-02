# Client

```@meta
CurrentModule = Fed.Client
```

The client is a microservice which exposes the infrastructure required to
communicate with the server. It is however independent of the machine learning
tools. The training loop is defined externally by the user, and then is
"proxied" by the client.

## App

Entry point to start a client node. The setup is done automatically on startup
and assumes the server is reachable.

```@docs
build_router
start
```

## Node

Data structure containing the client's configuration and its API for
communicating with the server.

```@docs
Node
fit_service
register_to_server
```

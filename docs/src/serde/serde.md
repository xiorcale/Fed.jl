# Serde

```@meta
CurrentModule = Fed.Serde
```

This module exposes different way to (de)serialize the payloads exchanged
between the server and the nodes. Excepted the [VanillaPayloadSerde](@ref), all the
other [Payloads](@ref) are making use of various compression schemes to reduce the
communication cost.



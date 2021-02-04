# Serde

```@meta
CurrentModule = Fed.Serde
```

This module exposes different ways to (de)serialize the payloads exchanged
between the server and the nodes. Excepted for the [VanillaPayloadSerde](@ref),
all the other [Payloads](@ref) are making use of various compression schemes to
reduce the communication cost.

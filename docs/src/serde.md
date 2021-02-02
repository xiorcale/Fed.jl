# Serde

```@meta
CurrentModule = Fed.Serde
```

This module exposes different way to (de)serialize the payloads exchanged
between the server and the nodes. Excepted the `VanillaPayloadSerde`, all the
other `PayloadSerde` are making use of various compression schemes to reduce the
communication cost.

## Packing

Tools which ease the the weights (de)serialization.

```@docs
pack
unpack
```

## Quantizer

Tools to (de)quantize an vector of values.

```@docs
Quantizer
Quantizer(::Float32, ::Float32)
Quantizer(::Vector{Float32})
quantize
dequantize
```

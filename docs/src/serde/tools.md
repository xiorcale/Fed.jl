# Tools

```@meta
CurrentModule = Fed.Serde
```

## Packing

Tools which ease the the weights (de)serialization.

```@docs
pack
unpack
```

## Quantizer

Tools to (de)quantize a vector of values.

```@docs
Quantizer
Quantizer(::Float32, ::Float32)
Quantizer(::Vector{Float32})
quantize
dequantize
```

## Delta compressor

Expose a generic `diff` and `patch` mechanism to remove redundant elements from
a `Vector`.

```@docs
Patch
diff
patch
```
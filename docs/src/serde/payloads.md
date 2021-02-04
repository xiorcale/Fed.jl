# Payloads

```@meta
CurrentModule = Fed.Serde
```

Abstraction for the (de)serialization and (de)compression processes. This gives
good capabilities of extensions as implementing the abstraction does not require
any other changes in the library to use the new scheme.

The implemented `PayloadSerde` are presented below, but first, let's describe
the abstraction to implement.

```@docs
PayloadSerde
serialize_payload(::PayloadSerde, ::Vector{Float32})
deserialize_payload(::PayloadSerde, ::Vector{UInt8}, ::String)
```

##  VanillaPayloadSerde

```@docs
VanillaPayloadSerde
serialize_payload(::VanillaPayloadSerde, ::Vector{Float32})
deserialize_payload(::VanillaPayloadSerde, ::Vector{UInt8}, ::String)
```

## QuantizedPayloadSerde

```@docs
QuantizedPayloadSerde
QPayload
serialize_payload(::QuantizedPayloadSerde, ::Vector{Float32})
deserialize_payload(::QuantizedPayloadSerde, ::Vector{UInt8}, ::String)
```

## QDiffPayloadSerde

```@docs
QDiffPayloadSerde
QDiffPayload
serialize_payload(::QDiffPayloadSerde, ::Vector{Float32})
deserialize_payload(::QDiffPayloadSerde, ::Vector{UInt8}, ::String)
```

## GDPayloadSerde

```@docs
GDPayloadSerde
GDPayload
serialize_payload(::GDPayloadSerde, ::Vector{Float32})
deserialize_payload(::GDPayloadSerde, ::Vector{UInt8}, ::String)
```

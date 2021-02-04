# Config

```@meta
CurrentModule = Fed.Config
```

This module exposes the pre-configurations of the [Payloads](@ref) implementations.
Each configuration contains the instance of the related payload. In this way, it
is easy to make sure the [CentralNode](@ref) and the [Node](@ref) are using the
same compression scheme. 


```@docs
Configuration
```

## BaseConfig

```@docs
BaseConfig
```

## VanillaConfig

```@docs
VanillaConfig
```

## QuantizedConfig

```@docs
QuantizedConfig
```

## QDiffConfig

```@docs
QDiffConfig
```

## GDConfig

```@docs
GDConfig
```

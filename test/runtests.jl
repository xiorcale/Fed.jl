using Fed
using Test


# make sure that everything can start up correctly
include("startup/server.jl")
include("startup/client.jl")

# test the serialization/deserialization
include("payload/serde.jl")

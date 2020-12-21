module Fed

include("serde/Serde.jl")
using .Serde

include("server/Server.jl")
include("client/Client.jl")

include("common/tools.jl")
export curry

end # module
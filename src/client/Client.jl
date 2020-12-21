module Client

include("../common/tools.jl")
include("../common/endpoints_url.jl")

include("node.jl")
export Node, Config, register_to_server

include("service.jl")
export fit_service

include("app.jl")
export start_client

end # module
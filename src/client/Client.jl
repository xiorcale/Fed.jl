module Client


include("node.jl")
export Node, register_to_server

include("service.jl")
export fit_service

include("app.jl")
export start_client


end # module
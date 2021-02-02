using Documenter, DocumenterLaTeX
using Fed

makedocs(
    sitename = "Fed.jl",
    author = "xiorcale",
    pages = [
        "Home" => "index.md",
        "Client" => "client.md",
        "Server" => "server.md",
        "Serde" => "serde.md",
        "Config" => "config.md"
    ]
)

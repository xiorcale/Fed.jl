using Documenter, DocumenterLaTeX
using Fed

makedocs(
    sitename = "Fed.jl",
    author = "xiorcale",
    pages = [
        "Home" => "index.md",
        "Client" => "client.md",
        "Server" => "server.md",
        "Serde" => Any[
            "Introduction" => "serde/serde.md", 
            "Tools" => "serde/tools.md",
            "Payloads" => "serde/payloads.md"
        ],
        "Config" => "config.md"
    ]
)

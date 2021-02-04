using HTTP


"""
    register_client!(cm::ClientManager, req::HTTP.Request)

Register a new client in the `ClientManager`. The body of the request should
contain the client URL: `http://hostname:port`.

!!! info

    **API Endpoint**: this is an HTTP server endpoint.
"""
function register_client!(cm::ClientManager, req::HTTP.Request)::HTTP.Response
    client_url = String(req.body)
    register!(cm, client_url)
    @info "client registered: $client_url"
    return HTTP.Response(200, "Client registered successfully")
end

using HTTP


"""
    register_client!(service, req)

Endpoint which register a new client in the `ClientManager`.
The body of the request should contain the client URL.
"""
function register_client!(cm::ClientManager, req::HTTP.Request)::HTTP.Response
    client_url = String(req.body)
    register!(cm, client_url)
    return HTTP.Response(200, "Client registered successfully")
end

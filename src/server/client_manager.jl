"""
This file is inspired from:
https://github.com/adap/flower/blob/main/src/py/flwr/server/client_manager.py
"""

import Base.length
using StatsBase: sample


"""
    ClientManager()

Structure which manages the clients registration and syncrhonize the server to
make it work with them.
"""
struct ClientManager
    clients::Set{String}
    cond::Threads.Condition

    ClientManager() = begin
        clients = Set{String}()
        cond = Threads.Condition()
        return new(clients, cond)
    end
end


length(cm::ClientManager) = length(cm.clients)


"""
    wait_for(cm, num_clients)

Block until at least `num_clients` are available.
"""
function wait_for(cm::ClientManager, num_clients::Int)
    lock(cm.cond) do 
        while length(cm.clients) < num_clients
            wait(cm.cond)
        end
    end
end


"""
    num_available_clients(cm)

Returns the number of available clients.
"""
num_available_clients(cm::ClientManager) = length(cm)


"""
    register!(cm, client_url)

Register a new `client_url`.
"""
function register!(cm::ClientManager, client_url::String)
    push!(cm.clients, client_url)
    lock(cm.cond) do
        notify(cm.cond)
    end
end


"""
    sample_clients(cm, fraction)

Sample randomly `fraction`% of the clients, without replacement. Returns at
least one client if the number of available clients > 0.
"""
function sample_clients(cm::ClientManager, fraction::Float32)::Vector{String}
    length(cm) == 0 && return Vector{String}(undef, 0)
    num_clients = max(round(Int, fraction * num_available_clients(cm)), 1)
    return sample(collect(cm.clients), num_clients, replace=false)
end

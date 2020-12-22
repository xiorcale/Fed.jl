using ..Fed: QDTYPE

"""
compute_changes_per_weights(req_weights, res_weights)

Computes the number of changes occuring for each weigh by comparing all the
weights from the request with the received ones.

[Location based metric] Where are the changes occuring in the model?
"""
function compute_changes_per_weights(req_weights::Vector{Float32}, res_weights::Vector{Vector{Float32}})::Vector{Float32}
return sum([
    weights .!= req_weights
    for weights in res_weights
])
end

"""
compute_round_changes(req_weights, res_weights)

Computes the percentage of changes occuring for the given round by comparing
all the weights from the request with the received ones.
"""
function compute_round_changes(req_weights::Vector{Float32}, res_weights::Vector{Vector{Float32}})::Float32
result = sum(compute_changes_per_weights(req_weights, res_weights)) 
result /= (length(req_weights) * length(res_weights))
return result
end
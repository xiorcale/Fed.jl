"""
changes_per_weights(req_weights, res_weights)

Computes the number of changes occuring for each weigh by comparing all the
weights from the request with the received ones.

[Location based metric] Where are the changes occuring in the model?
"""
function changes_per_weights(req_weights::Vector{T}, res_weights::Vector{Vector{T}})::Vector{Float32} where T <: Real
return sum([
    weights .!= req_weights
    for weights in res_weights
])
end

"""
round_changes(req_weights, res_weights)

Computes the percentage of changes occuring for the given round by comparing
all the weights from the request with the received ones.
"""
function round_changes(req_weights::Vector{T}, res_weights::Vector{Vector{T}})::Float32 where T <: Real
result = sum(changes_per_weights(req_weights, res_weights)) 
result /= (length(req_weights) * length(res_weights))
return result
end
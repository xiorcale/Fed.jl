"""
compute_changes_per_weights(req_data, res_data)

Computes the number of changes occuring for each weigh by comparing all the
weights from the request with the received ones.

[Location based metric] Where are the changes occuring in the model?
"""
function compute_changes_per_weights(req_data, res_data)::Vector{Float32}
return sum([
    weights .!= req_data
    for weights in res_data
]) / length(res_data)
end

"""
compute_round_changes(req_data, res_data)

Computes the percentage of changes occuring for the given round by comparing
all the weights from the request with the received ones.
"""
function compute_round_changes(req_data, res_data)::Float32
    result = sum(compute_changes_per_weights(req_data, res_data)) 
    result /= length(req_data)
    return result
end

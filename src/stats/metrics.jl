using LinearAlgebra: normalize

"""
    compute_changes_per_element(req_data, res_data)

Computes the number of changes occuring for each element by comparing all the
elements from the request with the received ones.

[Location based metric] Where are the changes occuring in the model?
"""
function compute_changes_per_element(req_data, res_data)::Vector{Float32}
return sum([
    weights .!= req_data
    for weights in res_data
]) / length(res_data)
end


"""
compute_round_changes(req_data, res_data)

Computes the percentage of changes occuring for the given round by comparing
all the element from the request with the received ones.
"""
function compute_round_changes(req_data, res_data)::Float32
    result = sum(compute_changes_per_element(req_data, res_data)) 
    result /= length(req_data)
    return result
end


"""
    compute_elements_difference(req_data, res_data, values_range)

Computes the importance of changes occuring for each element by computing the
average absolute difference between the element from the request with the
received ones.

[Location based metric] Where are the changes occuring in the model?
"""
function compute_elements_difference(req_data, res_data)::Vector{Float32}
    return normalize(sum([
        abs.(Float32.(weights) - Float32.(req_data))
        for weights in res_data
    ]) / length(res_data))
end
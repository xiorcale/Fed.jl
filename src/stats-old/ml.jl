struct MLStats
    num_weights::Int
    accuracies::Vector{Float32}
    losses::Vector{Float32}

    MLStats(num_weights) = 
        new(num_weights, Vector{Float32}(undef, 0), Vector{Float32}(undef, 0))
end


"""
    update_mlstats!(stats, acc, loss)

Updates the ML stats by adding new accuracy and loss.
"""
function update_mlstats!(stats::MLStats, acc::Float32, loss::Float32)
    push!(stats.accuracies, acc)
    push!(stats.losses, loss)
end

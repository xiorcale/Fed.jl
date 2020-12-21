"""
    federated_averaging(weights)

Implement the federated averaging algorithm descibed in:
- Communication-Efficient Learning of Deep Networks from Decentralized Data
https://arxiv.org/abs/1602.05629

`round_weights` should be an array containing the weights from each clients
participating in the round.
"""
function federated_averaging(round_weights)
    mapreduce(w -> w[:], +, round_weights) / length(round_weights)
end

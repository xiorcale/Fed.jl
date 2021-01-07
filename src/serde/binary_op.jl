"""
    add_col(x, y, carry)

Adds one column of the addition, taking the carry into account.
"""
@inline function add_col(x, y, carry)
    result = x + y + carry
    result == 1 && return 1, 0
    result == 2 && return 0, 1
    result == 3 && return 1, 1
    return 0, 0
end

"""
    add(x, y)

Performs the binarry addition `x` + `y`.
"""
function add(x::BitVector, y::BitVector)::BitVector
    result = BitVector(undef, length(x))

    local carry = 0
    @inbounds for i = length(x):-1:1
        result[i], carry = add_col(x[i], y[i], carry)
    end

    carry == 1 && push!(result, carry)

    return result
end


"""
    sub_col(x, y, borrowed)

Substracts one column of the substraction, taking the borrowed value into account.
"""
@inline function sub_col(x, y, borrowed)
    x -= borrowed
    x == y && return 0, 0
    x < y && return 1, 1 # need to borrow
    return 1, 0
end


"""
    substract(x, y)

Performs the binarry substract `x` - `y`.
"""
function substract(x::BitVector, y::BitVector)::BitVector
    result = BitVector(undef, length(x))
    local borrowed = 0
    @inbounds for i = length(x):-1:1
        result[i], borrowed = sub_col(x[i], y[i], borrowed)
    end

    # borrowed == 1 && @show "negative number..."
    
    return result
end


"""
    is_bigger(x, y)

Return true if the binarry number `x` is bigger than the binary number `y`.
"""
is_bigger(x, y) = findfirst(el -> el == 1, x) <= findfirst(el -> el == 1, y)


"""
    tobits(data::Vector{T})

Unpack an array into a bitarray, where each valze is padded on `8 * sizeof(T)`
bits.

/!/ Note that the MSB is in first position of the bitarray.
"""
function tobits(data::Vector{T}) where T <: Unsigned
    numbits = 8 * sizeof(T)
    bit_array = BitVector(undef, numbits * length(data))
    masks = [1 << i for i in numbits-1:-1:0]

    for (i, elem) in enumerate(data)
        start = (i - 1) * numbits
        @inbounds for (j, mask) in enumerate(masks)
            bit_array[start+j] = elem & mask > 0
        end
    end

    return bit_array
end
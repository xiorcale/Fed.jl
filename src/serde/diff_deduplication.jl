"""
    to_chunks(data, chunksize)

Transform data into an array of chunks. Last chunk is not padded and thus will
be smaller if `length(data)` is not a multiple of `chunksize`.
"""
function to_chunks(data::Vector{T}, chunksize::Int)::Vector{Vector{T}} where T <: Unsigned
    chunks = Vector{Vector{T}}(undef, ceil(Int, length(data) / chunksize))
    second_to_last = length(chunks) - 1

    j = 0
    for i in 1:second_to_last
        chunks[i] = data[j+1:j+chunksize]
        j += chunksize
    end

    # last chunks may be smaller than `chunksize`. if `length(data)` is not a
    # multiple of `chunksize`.
    chunks[end] = data[j+1:end]
   
    return chunks
end


"""
    diff_deduplication(x, y)

Returns `x` if `x != y` else `[0x00]`
"""
diff_deduplication(x, y) = x == y ? [0x00] : x


"""
    reverse_diff_deduplication(x, y)

Unpatches `x` by replacing the `[0x00]` values by the values in `y`.
"""
function reverse_diff_deduplication(x, y)
    result = deepcopy(x)
    for (i, chunk) in enumerate(y)
        if result[i] == [0x00]
            result[i] = chunk
        end
    end
    return result
end

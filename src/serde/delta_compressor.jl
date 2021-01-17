
struct Patch{T <: Any}
    range::Vector{UnitRange{Int32}}
    data::Vector{T}
end


function diff(old::Vector{T}, new::Vector{T}, sizeof_T::Int)::Patch{T} where T <: Any
    min_range_dist = (2 * sizeof(Int32)) / sizeof_T - 1
    range = Vector{UnitRange{Int32}}()
    data = Vector{T}()

    start = 1
    for i in 1:length(old)
        # current elements do not match
        if old[i] != new[i]
            # is the last serie of identical elements big enough?
            if i - start >= min_range_dist
                push!(range, start:i-1)
                append!(data, new[i])
            else # not enough elements...
                append!(data, new[start:i])
            end
            start = i + 1
        end
    end

    # we may have reached the end with identical elements...
    if start <= length(old)
        if length(old) - start >= min_range_dist
            push!(range, start:length(old))
        else
            append!(data, new[start:length(old)])
        end
    end

    return Patch{T}(range, data)
end


function patch(old::Vector{T}, patch::Patch{T})::Vector{T} where T <: Any
    patched = similar(old)

    curr = curr_data = 1
    for range in patch.range
        
        if range.start != curr
            num_val_to_copy = range.start - curr
            patched[curr:curr+num_val_to_copy-1] = patch.data[curr_data:curr_data+num_val_to_copy-1]
            curr += num_val_to_copy
            curr_data += num_val_to_copy
        end

        patched[range] = old[range]
        curr += length(range)
    end

    patched[curr:end] = patch.data[curr_data:end]

    return patched
end

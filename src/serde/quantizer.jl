"""
    Quantizer

Apply value quantization by scaling it down from one type to another, which
requires less bits than the original type.
"""
struct Quantizer{T <: Unsigned}
    minval::Float32
    maxval::Float32
    scale::Float32
    zero_point::Float32

    Quantizer{T}(minval, maxval) where T <: Unsigned = begin
        scale = (maxval - minval) / typemax(T)
        zero_point = -minval / scale
        return new(minval, maxval, scale, zero_point)
    end

    Quantizer{T}(data::Vector{Float32}) where T <: Unsigned = begin
        minval = minimum(data)
        maxval = maximum(data)
        return Quantizer{T}(minval, maxval)
    end
end


"""
    quantize(q, x)

Quantize `x` with the Quantizer `q`.
"""
quantize(q::Quantizer{T}, x) where T <: Unsigned = round(T, x / q.scale + q.zero_point)


"""
    dequantize(q, x)

Dequantize `x` with the Quantizer `q`.
"""
dequantize(q::Quantizer, x) = q.scale * (x - q.zero_point)

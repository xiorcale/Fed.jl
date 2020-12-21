struct Quantizer{T <: Real}
    type::Type{T}
    qmin::Float32
    qmax::Float32
    minval::Float32
    maxval::Float32
    scale::Float32
    zero_point::Float32

    Quantizer{T}(qmin, qmax, minval, maxval) where T <: Real = begin
        scale = (maxval - minval) / (qmax - qmin)
        zero_point =  qmin - minval / scale
        return new(T, qmin, qmax, minval, maxval, scale, zero_point)
    end

    Quantizer{T}(minval, maxval) where T <: UInt8 = begin
        scale = (maxval - minval) / 255
        zero_point = -minval / scale
        return new(UInt8, 0, 255, minval, maxval, scale, zero_point)
    end

    Quantizer{T}(minval, maxval) where T <: UInt16 = begin
        scale = (maxval - minval) / 65535
        zero_point = -minval / scale
        return new(UInt16, 0, 65535, minval, maxval, scale, zero_point)
    end
end


"""
    quantize(q, x)

Quantize `x` with the Quantizer `q`.
"""
quantize(q::Quantizer, x) = x / q.scale + q.zero_point |> q.type
quantize(q::Quantizer{T}, x) where T <: Integer = round( x / q.scale + q.zero_point) |> q.type

"""
    dequantize(q, x)

Dequantize `x` with the Quantizer `q`.
"""
dequantize(q::Quantizer, x) = q.scale * (x - q.zero_point)

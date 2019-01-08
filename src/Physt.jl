module Physt

export h1

abstract type Binning{AxisType} end
abstract type Histogram end

struct RegularBinning{AxisType} <: Binning{AxisType}
    nbins::Int64
end

function fit(binning::RegularBinning{AxisType}, entries::AbstractArray{AxisType})::Array{AxisType, 1} where AxisType
    min = minimum(entries)
    max = maximum(entries)
    step = (max - min) / binning.nbins
    return collect(range(min, length=binning.nbins + 1, step=step))
end

function transform(edges::AbstractArray{AxisType}, entries::AbstractArray{AxisType})::Array{Int64, 1} where AxisType
    # Least effective of all implementations
    nbins = length(edges) - 1
    result = zeros(Int64, nbins)
    for v in entries
        rightedge = findfirst(e -> e > v, edges)
        if rightedge == nothing 
            # Last edge is inclusive
            if v == edges[end]
                result[end] += 1
            end
        elseif rightedge > 1
            result[rightedge-1] += 1
        end
    end
    return result
end

function fit_and_transform(binning::Binning, entries::AbstractArray{AxisType})::Tuple{Array{AxisType, 1}, Array{Int64, 1}} where AxisType
    edges = fit(binning, entries)
    return edges, transform(edges, entries)
end

struct Histogram1D{AxisType, ValueType} <: Histogram where AxisType
    edges::AbstractArray{AxisType, 1}
    values::AbstractArray{ValueType, 1}
end

function h1(entries::AbstractArray{AxisType}, nbins::Integer=10) where AxisType
    binning = RegularBinning{AxisType}(nbins)
    edges, values = fit_and_transform(binning, entries)
    return Histogram1D{AxisType, Int64}(edges, values)
end

end # module

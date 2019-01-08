module Physt

export h1, fill, find_bin

abstract type Binning{AxisType} end
abstract type Histogram end

struct RegularBinning{AxisType} <: Binning{AxisType}
    nbins::Int64
end

struct Histogram1D{AxisType, ValueType} <: Histogram where AxisType
    edges::AbstractArray{AxisType, 1}
    values::AbstractArray{ValueType, 1}
end

function fit(binning::RegularBinning{AxisType}, entries::AbstractArray{AxisType})::Array{AxisType, 1} where AxisType
    min = minimum(entries)
    max = maximum(entries)
    step = (max - min) / binning.nbins
    return collect(range(min, length=binning.nbins + 1, step=step))
end

@inline function find_bin(edges::AbstractArray{AxisType}, value::AxisType) where AxisType
    rightedge = findfirst(e -> e > value, edges)
    if rightedge == nothing 
        # Last edge is inclusive
        if value == edges[end]
            return length(edges) - 1
        end
    elseif rightedge > 1
        return rightedge - 1
    end
    return nothing
end

function find_bin(histogram::Histogram1D, value)
    return find_bin(histogram.edges, value)
end

function transform(edges::AbstractArray{AxisType}, entries::AbstractArray{AxisType})::Array{Int64, 1} where AxisType
    # Least effective of all implementations
    nbins = length(edges) - 1
    result = zeros(Int64, nbins)
    for value in entries
        bin = find_bin(edges, value)
        if bin !== nothing
            result[bin] += 1
        end
    end
    return result
end

function fit_transform(binning::Binning, entries::AbstractArray{AxisType})::Tuple{Array{AxisType, 1}, Array{Int64, 1}} where AxisType
    edges = fit(binning, entries)
    return edges, transform(edges, entries)
end

function fill(histogram::Histogram1D{AxisType, ValueType}, entries::AbstractArray{AxisType}) where AxisType where ValueType
    new_values = transform(histogram.edges, entries)
    values = histogram.values .+ new_values
    return Histogram1D{AxisType, ValueType}(histogram.edges, values)
end

function fill(histogram::Histogram1D{AxisType, ValueType}, entry::AxisType) where AxisType where ValueType
    new_values = copy(histogram.values)
    bin = find_bin(histogram.edges, entry)
    if bin != nothing
        new_values[bin] += 1
    end
    return Histogram1D{AxisType, ValueType}(histogram.edges, new_values)
end

function h1(entries::AbstractArray{AxisType}, nbins::Integer=10) where AxisType
    binning = RegularBinning{AxisType}(nbins)
    edges, values = fit_transform(binning, entries)
    return Histogram1D{AxisType, Int64}(edges, values)
end

function h1(entries::AbstractArray{AxisType}, edges::AbstractArray{AxisType}) where AxisType
    values = transform(edges, entries)
    return Histogram1D{AxisType, Int64}(edges, values)
end

end # module

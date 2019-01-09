module Physt

import Base.<<, Base.deepcopy, Base.copy
export h1, update, update!, find_bin

abstract type Binning{AxisType} end
abstract type Histogram end

struct RegularBinning{AxisType} <: Binning{AxisType}
    nbins::Int64
end

struct Histogram1D{AxisType, ValueType} <: Histogram where AxisType
    edges::Array{AxisType, 1}
    values::Array{ValueType, 1}
end

function copy(old::Histogram1D{AxisType, ValueType}) where AxisType where ValueType
    new = Histogram1D{AxisType, ValueType}(copy(old.edges), copy(old.values))
end

deepcopy(histogram::Histogram) = copy(histogram)

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

function update(histogram::Histogram, any)
    new = copy(histogram)
    update!(new, any)
    return new
end

function update!(histogram::Histogram1D{AxisType}, entry) where AxisType
    entry_converted = convert(AxisType, entry)
    bin = find_bin(histogram.edges, entry_converted)
    if bin != nothing
        histogram.values[bin] += 1
    end
    return histogram
end

function update!(histogram::Histogram1D{AxisType}, entries::AbstractArray) where AxisType
    new_values = transform(histogram.edges, entries)
    histogram.values .+= new_values
    return histogram
end

<<(histogram::Histogram, what_to_update) = update(histogram, what_to_update)

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

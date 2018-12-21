module Physt

export h1

using StatsBase

struct Histogram1D
    
end

function h1(data, bins::Integer)
    fit(Histogram, data, nbins=bins)
end

end # module

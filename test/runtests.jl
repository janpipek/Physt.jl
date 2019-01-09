println("Testing...")

using Physt

h = h1([1,2,3,4,5,6,7], 2)


h = h1(rand(100), 12)
println(h)

h_ = h << .4
println(h_)
h__ = h_ << rand(20)

println(h)
update!(h, .40)
println(h)
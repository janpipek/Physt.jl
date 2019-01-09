# Physt.jl

Physt reimplementation in Julia. Also an excercise to learn the language
and find new ideas that can be retrofitted into original physt.

See <https://github.com/janpipek/physt>

## Example

```julia
using Physt

hist = h1(rand(100))
update(hist, .12)   # Not inline!
update!(hist, .12)  # Inline
```

# NetalignUtils documentation

# Introduction

NetalignUtils.jl contains function relevant to network alignment, including
function to read/write static and dynamic networks, and other utility functions
to deal with static and dynamic networks.

# Installation

NetalignUtils can be installed as follows.

```julia
Pkg.clone("https://github.com/vvjn/NetalignUtils.jl")
```

# Types

```@docs
DynamicNetwork
Network
```

# Functions

## Dynamic networks

```@docs
readeventlist(fd::IO; symmetric=true, header=false,
              sortby=nothing, format=:timefirst)
writeeventlist(fd::IO, dy::DynamicNetwork; format=:timefirst)
events2dynet(I, J, V, n, nodes; symmetric=true)
snapshots2dynet(snaps::Vector{Network};
 symmetric=false,sortby=nothing)
```

## Static networks

```@docs
readgw(fd::IO)
readedgelist(fd::IO; header=false)
writeedgelist(fd::IO, st::Network; prefix="",suffix="")
writegw(fd::IO, st::Network)
```

## Alignments

```@docs
nodecorrectness(f::AbstractVector{Int},
 nodes1::AbstractVector,nodes2::AbstractVector)
readaln(fd::IO, nodes1::AbstractVector,
 nodes2::AbstractVector, flip=false)
writealn(fd::IO, nodes1::AbstractVector, nodes2::AbstractVector)
readseeds(fd::IO,
 nodes1::AbstractVector,nodes2::AbstractVector)
```

## Matrices

```@docs
readlistmat(fd::IO, nodes1::Vector{<:AbstractString}, nodes2::Vector{<:AbstractString};
          header=false, ignore=false, minval=-Inf, dense=false)
readlistmat!(fd::IO, B::AbstractMatrix, nodes1::Vector{<:AbstractString}, nodes2::Vector{<:AbstractString};
                    header=false, ignore=false, minval=-Inf)
```

## Network measures

```@docs
readgdv(fd::IO, nodesidx::Dict)
writegdv(fd::IO, X::AbstractMatrix, nodes::AbstractVector)
```

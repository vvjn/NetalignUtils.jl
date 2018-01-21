# NetalignUtils documentation

# Introduction

NetalignUtils.jl contains function relevant to network alignment, including
function to read/write static and dynamic networks, and other utility functions
to deal with static and dynamic networks.

# Installation

NetalignUtils can be installed as follows.

```julia
Pkg.add("NetalignUtils")
```

```@meta
CurrentModule=NetalignUtils
```

# Types

```@docs
DynamicNetwork
Network
```

# Functions
## Dynamic networks

```@docs
readeventlist
writeeventlist
events2dynet
snapshots2dynet
```

## Static networks

```@docs
readgw
readedgelist
writeedgelist
writegw
```

## Alignments

```@docs
nodecorrectness
readaln
writealn
readseeds
```

## Matrices

```@docs
readlistmat
readlistmat!
```

## Network measures

```@docs
readgdv
writegdv
```

## Network generation
```@docs
SFGD
GEOGD
SocialNE
rand
```

## Randomization
```@docs
strict_events_shuffle
links_shuffle
```

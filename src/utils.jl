export nodecorrectness

# name => idx map like in statsbase
# indexmap(nodes) = Dict(node => i for (i,node) in enumerate(nodes))

"""
    nodecorrectness(f::AbstractVector{Int},
                    nodes1::AbstractVector,nodes2::AbstractVector) -> nc

Calculates node correctness when given an alignment.

# Arguments
- `f` : Alignment between nodes1 and nodes2. `f[i]` describes the aligned
node pairs `nodes1[i]` and `nodes2[f[i]]`. Thus, `f` describes `length(f)`
aligned node pairs.
- `nodes1`,`nodes2` : Node sets that `f` desribes the alignment of.

# Output
- `nc` : Node correctness between 0 and 1.
"""
nodecorrectness(f::AbstractVector{Int},
                nodes1::AbstractVector,nodes2::AbstractVector) =
                   mean(i -> nodes1[i]==nodes2[f[i]], 1:length(f))

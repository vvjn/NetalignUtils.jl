export Network, DynamicNetwork

import Base: getindex, ==

"""
    immutable Network
        G :: SparseMatrixCSC{Int,Int}
        nodes :: Vector
    end

A `Network` is a sparse matrix and a list of nodes.
`G` is assumed to be symmetric, unless specified otherwise.
"""
immutable Network
    G :: SparseMatrixCSC{Int,Int}
    nodes :: Vector
    function Network(G::SparseMatrixCSC{Int,Int}, nodes :: Vector)
        length(nodes)==size(G,1) || error("size")
        new(G,nodes)
    end
end

getindex(nt::Network, I::AbstractVector) = Network(nt.G[I,I], nt.nodes[I])
==(t1::Network, t2::Network) = (t1.nodes == t2.nodes) && (t1.G == t2.G)

"""
    immutable DynamicNetwork
        G :: SparseMatrixCSC{Events,Int}
        nodes :: Vector
    end

A `DynamicNetwork` is a sparse matrix of `Events` and a list of nodes.
`G` is assumed to be symmetric, unless specified otherwise.
The `Events` structure is defined in the NetalignMeasures.jl package (it is a list
of timestamps, where a timestamp is a tuple (start_time, end_time).
"""
immutable DynamicNetwork
    G :: SparseMatrixCSC{Events,Int}
    nodes :: Vector
    function DynamicNetwork(G::SparseMatrixCSC{Events,Int}, nodes::Vector)
        length(nodes)==size(G,1) || error("size")
        new(G,nodes)
    end
end

getindex(nt::DynamicNetwork, I::AbstractVector) =
    DynamicNetwork(nt.G[I,I], nt.nodes[I])
==(t1::DynamicNetwork, t2::DynamicNetwork) =
    (t1.nodes == t2.nodes) && (t1.G == t2.G)

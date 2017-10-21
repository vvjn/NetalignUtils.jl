__precompile__()

module NetalignUtils

using NetalignMeasures

export Network, DynamicNetwork, flatten

immutable Network
    G :: SparseMatrixCSC{Int,Int}
    nodes :: Vector
    function Network(G::SparseMatrixCSC{Int,Int}, nodes :: Vector)
        length(nodes)==size(G,1) || error("size")
        new(G,nodes)
    end
end

immutable DynamicNetwork
    G :: SparseMatrixCSC{Events,Int}
    nodes :: Vector
    function DynamicNetwork(G::SparseMatrixCSC{Events,Int}, nodes::Vector)
        length(nodes)==size(G,1) || error("size")
        new(G,nodes)
    end
end

"""
Convert dynamic network to static network
where each dynamic edge corresponds to a static edge with weight 1
"""
flatten(nt::Network) = nt
flatten(G::SparseMatrixCSC{<:Number,Int}) = G
flatten(G::SparseMatrixCSC{Events,Int}) =
    SparseMatrixCSC(G.m,G.n,G.colptr,G.rowval,ones(Int,length(G.nzval)))
flatten(dy::DynamicNetwork) = Network(flatten(dy.G), dy.nodes)

include("io.jl")

end # module

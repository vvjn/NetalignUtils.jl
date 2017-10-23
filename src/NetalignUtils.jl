__precompile__()

module NetalignUtils

using NetalignMeasures

export Network, DynamicNetwork, flatten, events2dynet

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

function events2dynet(I, J, V, n, nodes; makesymmetric=true)
    if makesymmetric
        G = sparse(vcat(I,J),vcat(J,I),vcat(V,V),n,n,fixevents)
    else
        G = sparse(I,J, V, n, n, fixevents)
    end
    DynamicNetwork(G,nodes)
end

include("ionet.jl")
include("iodynet.jl")
include("iomeasures.jl")
include("ioaln.jl")
include("iomatrix.jl")

end # module

__precompile__()

module NetalignUtils

using NetalignMeasures

export Network, DynamicNetwork

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

include("utils.jl")
include("dynet.jl")
include("ionet.jl")
include("iodynet.jl")
include("iomeasures.jl")
include("ioaln.jl")
include("iomatrix.jl")

end # module

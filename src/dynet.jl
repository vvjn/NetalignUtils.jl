export flatten, events2dynet

"""
Convert dynamic network to static network
where each dynamic edge corresponds to a static edge with weight 1
"""
flatten(G::SparseMatrixCSC{<:Number,Int}) = G
flatten(G::SparseMatrixCSC{Events,Int}) =
    SparseMatrixCSC(G.m,G.n,G.colptr,G.rowval,ones(Int,length(G.nzval)))
flatten(nt::Network) = nt
flatten(dy::DynamicNetwork) = Network(flatten(dy.G), dy.nodes)

function events2dynet(I, J, V, n, nodes; makesymmetric=true)
    if makesymmetric
        G = sparse(vcat(I,J),vcat(J,I),vcat(V,V),n,n,fixevents)
    else
        G = sparse(I,J, V, n, n, fixevents)
    end
    DynamicNetwork(G,nodes)
end

"""
Convert snapshots into dynamic network with event duration 1
and time starting at 0
"""
function snapshots2dynet(snaps::Vector{Network};
                                 makesymmetric=false,sortby=nothing)
    nodes = Set{String}()
    events = Vector{Tuple{String,String,Float64,Float64}}()
    for t = 1:length(snaps)
        Gc = snaps[t].G
        nodesc = snaps[t].nodes
        Ic,Jc,Vc = findnz(triu(Gc,1))
        append!(events, collect(zip(nodesc[Ic],nodesc[Jc],
                                    fill(Float64(t-1),length(Vc)),
                                    fill(Float64(t),length(Vc)))))
        union!(nodes,nodesc)
    end
    nodes = collect(nodes)
    if sortby!=nothing
        nodes = sort(nodes,by=sortby)
    end
    nodesnum = indexmap(nodes)
    edges = Matrix{Int}(length(events),2)
    timestamps = Vector{Vector{Tuple{Float64,Float64}}}(length(events))
    for i = 1:length(events)
        vals = events[i]
        n1 = nodesnum[vals[1]]
        n2 = nodesnum[vals[2]]
        edges[i,1] = min(n1,n2)
        edges[i,2] = max(n1,n2)
        timestamps[i] = [(vals[3],vals[4])]
    end
    events2dynet(edges[:,1], edges[:,2], timestamps,
                 length(nodes), nodes,
                 makesymmetric=makesymmetric)
end

export nodecorrectness

# name => idx map
indexmap(nodes) = Dict(node => i for (i,node) in enumerate(nodes))

function nodecorrectness(f::Vector{Int},
                         gnodes::AbstractVector,hnodes::AbstractVector)
    nc = 0
    for i = 1:length(f)
        nc += Int(gnodes[i]==hnodes[f[i]])
    end
    nc/length(f)
end

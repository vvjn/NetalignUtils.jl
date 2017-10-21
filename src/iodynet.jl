export readeventlist, writeeventlist

"""
returns graph as sparse matrix
with values on the top right triangle if makesymmetric is false
    format: start_time stop_time node1 node2
    formatflipped: node1 node2 start_time stop_time
"""
function readeventlist(fd::IO; makesymmetric=true, header=false,
                       sortby=nothing, formatflipped=false)
    nodes = Set{String}()
    events = Vector{Tuple{String,String,Float64,Float64}}()
    if header
        readline(fd)
    end
    while !eof(fd)
        line = readskipping(fd)
        if isempty(line); continue; end
        vals = split(strip(line))
        if length(vals)==4
            if formatflipped
                vals = vals[[3,4,1,2]]
            end
            t_s = parse(Float64,vals[1])
            t_e = parse(Float64,vals[2])
            if t_s > t_e error("Event time start > end") end
            vals[3]==vals[4] && continue
            push!(events,(vals[3],vals[4],t_s,t_e))
            push!(nodes,vals[3])
            push!(nodes,vals[4])
        else
            error("Format error: $line")
        end
    end
    nodes = collect(nodes)
    if sortby!=nothing
        nodes = sort(nodes,by=sortby)
    end
    nodesnum = Dict(node => i for (i,node) = enumerate(nodes))
    edges = Matrix{Int}(length(events),2)
    timestamps = Vector{Events}(length(events))
    for i = 1:length(events)
        vals = events[i]
        n1 = nodesnum[vals[1]]
        n2 = nodesnum[vals[2]]
        edges[i,1] = min(n1,n2)
        edges[i,2] = max(n1,n2)
        timestamps[i] = Events([(vals[3],vals[4])])
    end
    events2dynet(edges[:,1], edges[:,2], timestamps,
                 length(nodes), nodes,
                 makesymmetric=makesymmetric)
end

readeventlist(file::AbstractString; args...) =
    open(x -> readeventlist(x;args...), file, "r")


# write temporal network to file
function writeeventlist(fd::IO, dy::DynamicNetwork; formatflipped=false)
    G = dy.G
    nodes = d.nodes
    m,n = size(G)
    for col = 1:n
        for j = nzrange(G,col)
            row = G.rowval[j]
            val = G.nzval[j]
            for x in val
                if formatflipped
                    println(fd, nodes[row], " ", nodes[col], " ", x[1], " ", x[2])
                else
                    println(fd, x[1], " ", x[2], " ", nodes[row], " ", nodes[col])
                end
            end
        end
    end
end

writeeventlist(file::AbstractString, dy::DynamicNetwork,
               formatflipped=false) =
    open(fd -> writeeventlist(fd,dy,formatflipped), file, "w")

export readeventlist, writeeventlist

"""
    readeventlist(fd::IO; <keyword args>)
    readeventlist(file::AbstractString; <keyword args>) -> SparseMatrixCSC{Events}, node list

Read list of events from file returns undirected dynamic network represented as sparse matrix.
An event is an interaction between two nodes from start time to stop time.

# Keyword arguments
- `symmetric=true` : If false, only fill the top right triangle, else make resulting matrix symmetric.
- `header=false` : If true, ignore first line.
- `sortby=nothing`: If not `nothing`, sort nodes w.r.t this function (`by` argument in `sort`).
- `format=:timefirst` : If `format=:timefirst`, each line has format (`start_time stop_time node1 node2`).
    If `format=:nodefirst`, each line has format (`node1 node2 start_time stop_time`).
"""
function readeventlist(fd::IO; symmetric=true, header=false,
                       sortby=nothing, format=:timefirst)
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
            if format==:nodefirst
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
    nodesnum = indexmap(nodes)
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
                 symmetric=symmetric)
end
readeventlist(file::AbstractString; args...) =
    open(x -> readeventlist(x;args...), file, "r")

"""
    writeeventlist(fd::IO, dy::DynamicNetwork; <keyword args>)
    writeeventlist(file::AbstractString, dy::DynamicNetwork; <keyword args>)

Write list of events to file from undirected dynamic network represented as sparse matrix.
An event is an interaction between two nodes from start time to stop time.

# Keyword arguments
- `format=:timefirst` : If `format=:timefirst`, each line has format (`start_time stop_time node1 node2`).
    If `format=:nodefirst`, each line has format (`node1 node2 start_time stop_time`).
"""    
function writeeventlist(fd::IO, dy::DynamicNetwork; format=:timefirst)
    G = dy.G
    nodes = dy.nodes
    m,n = size(G)
    for col = 1:n
        for j = nzrange(G,col)
            row = G.rowval[j]
            val = G.nzval[j]
            for x in val.timestamps
                if format==:nodefirst
                    println(fd, nodes[row], " ", nodes[col], " ", x[1], " ", x[2])
                else
                    println(fd, x[1], " ", x[2], " ", nodes[row], " ", nodes[col])
                end
            end
        end
    end
end
writeeventlist(file::AbstractString, args...) =
    open(fd -> writeeventlist(fd,args...), file, "w")

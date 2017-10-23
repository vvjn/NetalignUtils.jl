export readgw, readedgelist, writegw, writeedgelist

"""
return line after skipping if pred(line) is true
default: after skipping empty lines and commented lines
"""
function readskipping(fd::IO,
                      pred=line -> length(line)==0 || line[1]=='#' || line[1]=='%')
    while !eof(fd)
        line = strip(readline(fd))
        if pred(line); continue; end
        return line
    end
    return ""
end

"""
Reads a LEDA format file (undirected graph)
example is in test/
"""
function readgw(fd::IO)
    line = readskipping(fd)
    strip(line)=="LEDA.GRAPH" || error("Error in line: $line")
    for i = 1:3; readskipping(fd); end
    nverts = parse(Int,readskipping(fd))
    vertices = Array{String}(nverts)
    for i = 1:nverts
        line = readskipping(fd)
        vertices[i] = match(r"\|{(.*?)}\|",line).captures[1]
    end
    nedges = parse(Int,readskipping(fd))
    I = Vector{Int}(nedges)
    J = Vector{Int}(nedges)
    for i = 1:nedges
        line = readskipping(fd)
        caps = match(r"(\d+) (\d+) 0 \|{.*}\|",line).captures
        n1 = parse(Int,caps[1])
        n2 = parse(Int,caps[2])
        n1==n2 && continue
        I[i] = n1
        J[i] = n2
    end
    G = sparse(vcat(I,J), vcat(J,I), 1, nverts, nverts, max)
    return Network(G,vertices)
end

readgw(file::AbstractString) = open(readgw, file, "r")


"""
    Read list of edges and create network form it (undirected graph)
"""    
function readedgelist(fd::IO; header=false)
    nodes = Set{String}()
    edges = Vector{Tuple{String,String}}()
    header && readline(fd)
    while !eof(fd)
        line = readskipping(fd)
        isempty(line) && continue
        vals = split(strip(line))
        length(vals)!=2 && error("length")
        push!(edges,(vals[1],vals[2]))
        push!(nodes,vals[1])
        push!(nodes,vals[2])
    end
    nodes = collect(nodes)
    nodesnum = Dict(node => i for (i,node) = enumerate(nodes))
    I = Vector{Int}()
    J = Vector{Int}()
    for vals in edges
        n1 = nodesnum[vals[1]]
        n2 = nodesnum[vals[2]]
        n1==n2 && continue
        push!(I, n1)
        push!(J, n2)
    end
    nverts = length(nodes)
    G = sparse(vcat(I,J), vcat(J,I), 1, nverts, nverts, max)
    Network(G,nodes)
end

readedgelist(file::AbstractString; args...) =
    open(x -> readedgelist(x;args...), file, "r")

function writeedgelist(fd::IO, st::Network; prefix="",suffix="")
    G = st.G
    nodes = st.nodes
    m,n = size(G)
    for col = 1:n
        for j = nzrange(G,col)
            row = G.rowval[j]
            if row < col
                println(fd, prefix, nodes[row], " ", nodes[col], suffix)
            end
        end
    end
end

writeedgelist(file::AbstractString, st::Network; args...) =
    open(fd -> writeedgelist(fd, st; args...), file, "w")

function writegw(fd::IO, st::Network)
    G = st.G
    gnodes = st.nodes
    print(fd,"LEDA.GRAPH\nvoid\nvoid\n-2\n")
    m,n = size(G)
    println(fd,n)
    for node in gnodes
        println(fd,"|{",node,"}|")
    end
    println(fd,div(nnz(G),2))
    for col = 1:n
        for j = nzrange(G,col)
            row = G.rowval[j]
            if row < col
                println(fd,row," ",col," 0 |{}|")
            end
        end
    end
end

writegw(filename::AbstractString, st::Network) =
    open(fd -> writegw(fd,st), filename,"w")


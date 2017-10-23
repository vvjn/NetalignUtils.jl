export readspmat, readspmat!

"""
Read matrix in list format
# nodeA1 nodeA2 4.5
# nodeB1 nodeB2 3.4
# nodeA1 nodeB2 0.3
# nodeB1 nodeA2 0.6

where the first column corresponds to nodes1
and the second to nodes2.

Returns sparse matrix

If ignoreunmatched, then it skips to the next line
if you have a node not in nodes1 or nodes2 resp.
"""
function readspmat(fd::IO, nodes1::Vector, nodes2::Vector;
                   header=false, ignoreunmatched=false, minval=-Inf)
    nodes1 = Dict(node=>i for (i,node) = enumerate(nodes1))
    nodes2 = Dict(node=>i for (i,node) = enumerate(nodes2))
    I = Int[]
    J = Int[]
    V = Float64[]
    header && readline(fd)
    for line in eachline(fd)
        vals = split(strip(line))
        if !ignoreunmatched ||
            (haskey(nodes1,vals[1]) && haskey(nodes2,vals[2]))
            push!(I, nodes1[vals[1]])
            push!(J, nodes2[vals[2]])
            push!(V, max(minval, parse(Float64,vals[3])))
        end
    end
    sparse(I,J,V,length(nodes1),length(nodes2))
end

readspmat(file::AbstractString,args...) =
    open(fd -> readspmat(fd,args...), file, "r")


"""
Stores matrix in B
"""
function readspmat!(fd::IO, B::AbstractMatrix, nodes1::Vector, nodes2::Vector;
                    header=false, ignoreunmatched=false, minval=-Inf)
    nodes1 = Dict(node=>i for (i,node) = enumerate(nodes1))
    nodes2 = Dict(node=>i for (i,node) = enumerate(nodes2))
    header && readline(fd)
    for line in eachline(fd)
        vals = split(strip(line))
        if !ignoreunmatched ||
            (haskey(nodes1,vals[1]) && haskey(nodes2,vals[2]))
            B[nodes1[vals[1]],nodes2[vals[2]]] = max(minval,parse(Float64,vals[3]))
        end
    end
    B
end
readspmat!(file::AbstractString,args...) =
    open(fd -> readspmat!(fd,args...), file, "r")

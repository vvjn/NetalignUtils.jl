export readlistmat, readlistmat!

"""
    readlistmat(fd::IO, nodes1::Vector, nodes2::Vector; <keyword arguments>)
    readlistmat(file::AbstractString, nodes1::Vector, nodes2::Vector; <keyword arguments>)
              
Reads a numerical matrix stored in list format, where the first and second columns correspond
to string vectors nodes1 and nodes2, respectively. E.g.

# nodeA1 nodeA2 4.5
# nodeB1 nodeB2 3.4
# nodeA1 nodeB2 0.3
# nodeB1 nodeA2 0.6

Returns a sparse matrix by default. Set keyword option `dense=true` to return a dense matrix.

# Arguments
- `fd`,`file` : file name or file I/O
- `nodes1`,`nodes1` : node vectors corresponding to 1st and 2nd columns

# Keyword arguments
- `header=false` : set to true to ignore first line
- `ignore=false` : set to true to ignore nodes in file that is not in nodes1 or nodes2
- `dense=false` : set to true to return dense matrix
"""
function readlistmat(fd::IO, nodes1::Vector{<:AbstractString}, nodes2::Vector{<:AbstractString};
                   header=false, ignore=false, minval=-Inf, dense=false)
    if dense
        return readlistmat!(fd, nodes1, nodes2,
                          zeros(Float64,length(nodes1),length(nodes2)),
                          header=header, ignore=ignore, minval=minval)
    end
    nodes1 = indexmap(nodes1)
    nodes2 = indexmap(nodes2)
    I = Int[]
    J = Int[]
    V = Float64[]
    header && readline(fd)
    for line in eachline(fd)
        vals = split(strip(line))
        if !ignore ||
            (haskey(nodes1,vals[1]) && haskey(nodes2,vals[2]))
            push!(I, nodes1[vals[1]])
            push!(J, nodes2[vals[2]])
            push!(V, max(minval, parse(Float64,vals[3])))
        end
    end
    sparse(I,J,V,length(nodes1),length(nodes2))
end
readlistmat(file::AbstractString,args...) =
    open(fd -> readlistmat(fd,args...), file, "r")

"""
    readlistmat!(fd::IO, B::AbstractMatrix, nodes1::Vector, nodes2::Vector; <keyword arguments>)
    readlistmat!(file::AbstractString, B::AbstractMatrix, nodes1::Vector, nodes2::Vector; <keyword arguments>)
    
Same as [`readlistmat`](@ref) but stores the result in B.
"""
function readlistmat!(fd::IO, B::AbstractMatrix, nodes1::Vector{<:AbstractString}, nodes2::Vector{<:AbstractString};
                    header=false, ignore=false, minval=-Inf)
    nodes1 = indexmap(nodes1)
    nodes2 = indexmap(nodes2)
    header && readline(fd)
    for line in eachline(fd)
        vals = split(strip(line))
        if !ignore ||
            (haskey(nodes1,vals[1]) && haskey(nodes2,vals[2]))
            B[nodes1[vals[1]],nodes2[vals[2]]] = max(minval,parse(Float64,vals[3]))
        end
    end
    B
end
readlistmat!(file::AbstractString,args...) =
    open(fd -> readlistmat!(fd,args...), file, "r")

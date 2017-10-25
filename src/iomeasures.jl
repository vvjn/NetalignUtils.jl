export readgdv, writegdv

"""
    readgdv(fd::IO, nodes::AbstractVector)
    readgdv(file::AbstractString, nodes::AbstractVector)

Reads the .ndump2 file format that contains (static or dynamic)
graphlet counts, outputted by GraphCrunch1 (ncount program in
http://www0.cs.ucl.ac.uk/staff/natasa/graphcrunch/index.html), or
Graphcrunch2
(http://www0.cs.ucl.ac.uk/staff/natasa/graphcrunch2/index.html), or
the dynamic graphlets counting code (https://www3.nd.edu/~cone/DG/).

Graphlets are small, connected, induced sub-graphs of a network
(Przulj N, Corneil DG, Jurisica I: Modeling Interactome, Scale-Free or Geometric?, Bioinformatics 2004, 20(18):3508-3515.),
similar to network motifs.
"""
function readgdv(fd::IO, nodesidx::Dict)
    A = readdlm(fd,Any)
    X = zeros(Float64, (size(A,1),size(A,2)-1))
    X[map(i -> nodesidx[string(A[i,1])], 1:size(A,1)),:] = A[:,2:end]
    X
end
readgdv(fd::IO, nodes::AbstractVector) =
    readgdv(fd, indexmap(nodes))
readgdv(file::AbstractString,args...) =
    open(fd -> readgdv(fd,args...), file, "r")

"""
    writegdv(fd::IO, X::AbstractMatrix, nodes::AbstractVector)
    writegdv(file::AbstractString, X::AbstractMatrix, nodes::AbstractVector)

Writes to graphlets file format. See [`readgdv`](@ref).
"""
function writegdv(fd::IO, X::AbstractMatrix, nodes::AbstractVector)
    for i = 1:size(X,1)
        print(fd, nodes[i], " ")
        for j = 1:size(X,2)
            if j < size(X,2)
                print(fd, Int(X[i,j]), " ")
            else
                println(fd, Int(X[i,j]))
            end
        end
    end
end
writegdv(file::AbstractString, args...) =
    open(fd -> writegdv(fd, args...), file, "w")

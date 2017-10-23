export readgdv, writegdv

" read file outputted by the ncount gdv program in GraphCrunch"
function readgdv(filename, nodesidx::Dict{<:AbstractString,Int})
    A = open(fd -> readdlm(fd,Any),filename,"r")
    X = zeros(Float64, (size(A,1),size(A,2)-1))
    X[map(i -> nodesidx[string(A[i,1])], 1:size(A,1)),:] = A[:,2:end]
    X
end

function readgdv(filename, nodes::Vector{<:AbstractString})
    readgdv(filename, Dict{String,Int}(nodes => i for (i,nodes) in enumerate(nodes)))
end

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

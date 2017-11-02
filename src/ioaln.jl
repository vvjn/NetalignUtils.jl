export readaln, readseeds, writealn

"""
    readseeds(file::AbstractString,
              nodes1::AbstractVector,
              nodes2::AbstractVector) -> Matrix{Int} : n x 2

Outputs n x 2 matrix of node indices
associates with nodes1 and nodes2
"""
function readseeds(fd::IO,
                   nodes1::AbstractVector,nodes2::AbstractVector)
    aln = readdlm(fd,String)
    d1 = indexmap(nodes1)
    d2 = indexmap(nodes2)
    paln = zeros(Int,size(aln))
    for i = 1:size(paln,1)
        paln[i,1] = d1[aln[i,1]]
        paln[i,2] = d2[aln[i,2]]
    end
    paln
end
readseeds(file::AbstractString, args...) =
    open(fd -> readseeds(fd, args...), file, "r")

"""
    readaln(file::AbstractString, nodes1::Vector,
             nodes2::Vector, flip=false)

Read alignment file for pairwise network alignment.  Each line will
contain a node pair, with the first node from nodes1, and the second
node from nodes2.  Returns permutation from nodes1 to nodes2
corresponding to the node pairs (so need length(nodes1) <=
length(nodes2)) If flip=true, then returns permutation from nodes2 to
nodes1, (so need length(nodes2) <= length(nodes1)) where first node in
each line is from nodes2, and the second node is from nodes1.
"""    
function readaln(fd::IO, nodes1::AbstractVector,
                 nodes2::AbstractVector, flip=false)
    aln = readdlm(fd,String)
    if flip
        aln2perm(flipdim(aln,2),nodes2,nodes1)
    else
        aln2perm(aln,nodes1,nodes2)
    end
end
readaln(file::AbstractString, args...) =
    open(fd -> readaln(fd, args...), file, "r")

import NetalignMeasures: aln2perm
"""
Given aln :: n x 2 matrix of node names, 1st column from nodes1,
second column from nodes2, convert to a permutation from nodes1 to
nodes2 If fill=true and there are nodes in nodes2 that are not
considered, map to those nodes randomly, but all nodes from nodes1 need
to be considered.
"""
function aln2perm(aln::AbstractMatrix,nodes1::AbstractVector,nodes2::AbstractVector,fill=true)
    m = length(nodes1)
    n = length(nodes2)
    if size(aln,1)!=m error("Need aln size to match") end
    d1 = indexmap(nodes1)
    d2 = indexmap(nodes2)
    p = zeros(Int, ifelse(fill,n,m))
    for i = 1:m
        p[d1[aln[i,1]]] = d2[aln[i,2]]
    end
    if fill
        mapped_to = zeros(Int,n)
        for i = 1:n
            if p[i] > 0
                mapped_to[p[i]] = 1
            end
        end
        j = 1
        for i = 1:n
            if mapped_to[i] == 0
                mapped_to[j] = i
                j += 1
            end
        end
        rp = randperm(n-m)
        for i = 1:(n-m)
            p[m+i] = mapped_to[rp[i]]
        end
    end
    p
end

"""
    writealn(fd::IO, nodes1::AbstractVector, nodes2::AbstractVector)
    writealn(file::AbstractString, nodes1::AbstractVector, nodes2::AbstractVector)

Write alignment to file
"""    
function writealn(fd::IO, nodes1::AbstractVector, nodes2::AbstractVector)
    for i = 1:length(f)
        println(fd, nodes1[i], " ", nodes2[f[i]])
    end
end
writealn(file::AbstractString, args...) =
    open(fd -> writealn(fd,args...), file,"w")

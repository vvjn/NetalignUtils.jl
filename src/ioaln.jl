export readaln, aln2perm

"""
Read alignment file for pairwise network alignment.  Each line will
contain a node pair, with the first node from nodes1, and the second
node from nodes2.  Returns permutation from nodes1 to nodes2
corresponding to the node pairs (so need length(nodes1) <=
length(nodes2)) If flip=true, then returns permutation from nodes2 to
nodes1, (so need length(nodes2) <= length(nodes1)) where first node in
each line is from nodes2, and the second node is from nodes1.
"""    
function readaln(file::AbstractString, nodes1::Vector,
                 nodes2::Vector, flip=false)
    aln = readdlm(file,String)
    if flip
        aln2perm(flipdim(aln,2),nodes2,nodes1)
    else
        aln2perm(aln,nodes1,nodes2)
    end
end

"""
Given aln :: n x 2 matrix of node names, 1st column from nodes1,
second column from nodes2, convert to a permutation from nodes1 to
nodes2 If there are nodes that are not considered, map those nodes
randomly, but all nodes from nodes1 need to be available.    
"""
function aln2perm(aln,nodes1,nodes2)
    m = length(nodes1)
    n = length(nodes2)
    if size(aln,1)!=m error("Need aln size to match") end
    d1 = Dict(nodes => i for (i,nodes) in enumerate(nodes1)) # name => idx maps
    d2 = Dict(nodes => i for (i,nodes) in enumerate(nodes2))
    p = zeros(Int, n)
    for i = 1:m
        p[d1[aln[i,1]]] = d2[aln[i,2]]
    end
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
    p
end

function writealn(fd::IO, nodes1::Vector, nodes2::Vector)
    for i = 1:length(f)
        println(fd, nodes1[i], " ", nodes2[f[i]])
    end
end

writepaln(file::AbstractString, args...) =
    open(fd -> writepaln(fd,args...), file,"w")

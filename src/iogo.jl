export readgoterms

# read in go ontology data
# 2 columns
# 1: node name, 2: ontology assocated to node
# ignore ontology pairs that are not in nodesidx
function readgoterms(fd::IO,nodes::Vector)
    gobases = ["GO:0008372","GO:0008150","GO:0003674"]
    nodesidx = indexmap(nodes)
    goknown = [Vector{String}() for i in 1:length(nodesidx)]
    goterms = Set{String}()
    for line = eachline(fd)
        nodename,goterm = split(strip(line))
        #goterm = goterm[4:end]
        (!haskey(nodesidx,nodename) || findfirst(gobases,goterm)>0) && continue
        node = nodesidx[nodename]
        push!(goknown[node],goterm)
        push!(goterms,goterm)
    end
    goterms = collect(goterms)
    goknown,goterms
end
readgoterms(file::AbstractString,args...;vargs...) =
    open(fd->readgoterms(fd,args...;vargs...),file,"r")

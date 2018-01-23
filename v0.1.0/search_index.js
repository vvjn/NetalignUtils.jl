var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils documentation",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#NetalignUtils-documentation-1",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils documentation",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "NetalignUtils documentation",
    "title": "Introduction",
    "category": "section",
    "text": "NetalignUtils.jl contains function relevant to network alignment, including function to read/write static and dynamic networks, and other utility functions to deal with static and dynamic networks."
},

{
    "location": "index.html#Installation-1",
    "page": "NetalignUtils documentation",
    "title": "Installation",
    "category": "section",
    "text": "NetalignUtils can be installed as follows.Pkg.clone(\"https://github.com/vvjn/NetalignUtils.jl\")CurrentModule=NetalignUtils"
},

{
    "location": "index.html#NetalignUtils.DynamicNetwork",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.DynamicNetwork",
    "category": "Type",
    "text": "immutable DynamicNetwork\n    G :: SparseMatrixCSC{Events,Int}\n    nodes :: Vector\nend\n\nA DynamicNetwork is a sparse matrix of Events and a list of nodes. G is assumed to be symmetric, unless specified otherwise. The Events structure is defined in the NetalignMeasures.jl package (it is a list of timestamps, where a timestamp is a tuple (start_time, end_time).\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.Network",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.Network",
    "category": "Type",
    "text": "immutable Network\n    G :: SparseMatrixCSC{Int,Int}\n    nodes :: Vector\nend\n\nA Network is a sparse matrix and a list of nodes. G is assumed to be symmetric, unless specified otherwise.\n\n\n\n"
},

{
    "location": "index.html#Types-1",
    "page": "NetalignUtils documentation",
    "title": "Types",
    "category": "section",
    "text": "DynamicNetwork\nNetwork"
},

{
    "location": "index.html#Functions-1",
    "page": "NetalignUtils documentation",
    "title": "Functions",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#NetalignUtils.readeventlist",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readeventlist",
    "category": "Function",
    "text": "readeventlist(fd::IO; <keyword args>)\nreadeventlist(file::AbstractString; <keyword args>) -> SparseMatrixCSC{Events}, node list\n\nRead list of events from file returns undirected dynamic network represented as sparse matrix. An event is an interaction between two nodes from start time to stop time.\n\nKeyword arguments\n\nsymmetric=true : If false, only fill the top right triangle, else make resulting matrix symmetric.\nheader=false : If true, ignore first line.\nsortby=nothing: If not nothing, sort nodes w.r.t this function (by argument in sort).\nformat=:timefirst : If format=:timefirst, each line has format (start_time stop_time node1 node2).   If format=:nodefirst, each line has format (node1 node2 start_time stop_time).\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.writeeventlist",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.writeeventlist",
    "category": "Function",
    "text": "writeeventlist(fd::IO, dy::DynamicNetwork; <keyword args>)\nwriteeventlist(file::AbstractString, dy::DynamicNetwork; <keyword args>)\n\nWrite list of events to file from undirected dynamic network represented as sparse matrix. An event is an interaction between two nodes from start time to stop time.\n\nKeyword arguments\n\nformat=:timefirst : If format=:timefirst, each line has format (start_time stop_time node1 node2).   If format=:nodefirst, each line has format (node1 node2 start_time stop_time).\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.events2dynet",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.events2dynet",
    "category": "Function",
    "text": "events2dynet(I, J, V, n, nodes; symmetric=true) -> SparseMatrixCSC{Events}, nodes\n\nSimilar to sparse, given indices and values, create an dynamic network.\n\nArguments\n\nn : # of nodes in network\nI,J: indices\nV : vector of Events\nsymmetric=true : If true, make the sparse matrix symmetric.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.snapshots2dynet",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.snapshots2dynet",
    "category": "Function",
    "text": "snapshots2dynet(snaps::Vector{Network};\n          symmetric=false,sortby=nothing)\n\nConverts a vector of networks (i.e. temporal snapshots) into a dynamic network with event duration 1 and time starting at 0.\n\n\n\n"
},

{
    "location": "index.html#Dynamic-networks-1",
    "page": "NetalignUtils documentation",
    "title": "Dynamic networks",
    "category": "section",
    "text": "readeventlist\nwriteeventlist\nevents2dynet\nsnapshots2dynet"
},

{
    "location": "index.html#NetalignUtils.readgw",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readgw",
    "category": "Function",
    "text": "readgw(fd::IO)\nreadgw(file::AbstractString) -> SparseMatrixCSC, node list\n\nReads LEDA format file describing a network. Outputs an undirected network. An example of a LEDA file is in the examples/ directory.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.readedgelist",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readedgelist",
    "category": "Function",
    "text": "readedgelist(fd::IO; header=false)\nreadedgelist(file::AbstractString; header=false) -> SparseMatrixCSC, node list\n\nRead list of edges and output undirected network\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.writeedgelist",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.writeedgelist",
    "category": "Function",
    "text": "writeedgelist(fd::IO, st::Network; prefix=\"\",suffix=\"\")\nwriteedgelist(file::AbstractString, st::Network; prefix=\"\",suffix=\"\")\n\nWrite network to file as list of edges.\n\nprefix,suffix : Prefix and suffix to each line.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.writegw",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.writegw",
    "category": "Function",
    "text": "writegw(fd::IO, st::Network)\nwritegw(file::AbstractString, st::Network)\n\nWrite undirected network to file as LEDA format.\n\n\n\n"
},

{
    "location": "index.html#Static-networks-1",
    "page": "NetalignUtils documentation",
    "title": "Static networks",
    "category": "section",
    "text": "readgw\nreadedgelist\nwriteedgelist\nwritegw"
},

{
    "location": "index.html#NetalignUtils.nodecorrectness",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.nodecorrectness",
    "category": "Function",
    "text": "nodecorrectness(f::AbstractVector{Int},\n                nodes1::AbstractVector,nodes2::AbstractVector) -> nc\n\nCalculates node correctness when given an alignment.\n\nArguments\n\nf : Alignment between nodes1 and nodes2. f[i] describes the aligned\n\nnode pairs nodes1[i] and nodes2[f[i]]. Thus, f describes length(f) aligned node pairs.\n\nnodes1,nodes2 : Node sets that f desribes the alignment of.\n\nOutput\n\nnc : Node correctness between 0 and 1.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.readaln",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readaln",
    "category": "Function",
    "text": "readaln(file::AbstractString, nodes1::Vector,\n         nodes2::Vector, flip=false)\n\nRead alignment file for pairwise network alignment.  Each line will contain a node pair, with the first node from nodes1, and the second node from nodes2.  Returns permutation from nodes1 to nodes2 corresponding to the node pairs (so need length(nodes1) <= length(nodes2)) If flip=true, then returns permutation from nodes2 to nodes1, (so need length(nodes2) <= length(nodes1)) where first node in each line is from nodes2, and the second node is from nodes1.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.writealn",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.writealn",
    "category": "Function",
    "text": "writealn(fd::IO, nodes1::AbstractVector, nodes2::AbstractVector)\nwritealn(file::AbstractString, nodes1::AbstractVector, nodes2::AbstractVector)\n\nWrite alignment to file\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.readseeds",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readseeds",
    "category": "Function",
    "text": "readseeds(file::AbstractString,\n          nodes1::AbstractVector,\n          nodes2::AbstractVector) -> Matrix{Int} : n x 2\n\nOutputs n x 2 matrix of node indices associates with nodes1 and nodes2\n\n\n\n"
},

{
    "location": "index.html#Alignments-1",
    "page": "NetalignUtils documentation",
    "title": "Alignments",
    "category": "section",
    "text": "nodecorrectness\nreadaln\nwritealn\nreadseeds"
},

{
    "location": "index.html#NetalignUtils.readlistmat",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readlistmat",
    "category": "Function",
    "text": "readlistmat(fd::IO, nodes1::Vector, nodes2::Vector; <keyword arguments>)\nreadlistmat(file::AbstractString, nodes1::Vector, nodes2::Vector; <keyword arguments>)\n\nReads a numerical matrix stored in list format, where the first and second columns correspond to string vectors nodes1 and nodes2, respectively. E.g.\n\nnodeA1 nodeA2 4.5\nnodeB1 nodeB2 3.4\nnodeA1 nodeB2 0.3\nnodeB1 nodeA2 0.6\n\nReturns a dense matrix by default. Set keyword option dense=false to return a sparse matrix.\n\nArguments\n\nfd,file : file name or file I/O\nnodes1,nodes1 : node vectors corresponding to 1st and 2nd columns\n\nKeyword arguments\n\nheader=false : set to true to ignore first line\nignore=false : set to true to ignore nodes in file that is not in nodes1 or nodes2\ndense=true : set to false to return sparse matrix\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.readlistmat!",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readlistmat!",
    "category": "Function",
    "text": "readlistmat!(fd::IO, B::AbstractMatrix, nodes1::Vector, nodes2::Vector; <keyword arguments>)\nreadlistmat!(file::AbstractString, B::AbstractMatrix, nodes1::Vector, nodes2::Vector; <keyword arguments>)\n\nSame as readlistmat but stores the result in B.\n\n\n\n"
},

{
    "location": "index.html#Matrices-1",
    "page": "NetalignUtils documentation",
    "title": "Matrices",
    "category": "section",
    "text": "readlistmat\nreadlistmat!"
},

{
    "location": "index.html#NetalignUtils.readgdv",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.readgdv",
    "category": "Function",
    "text": "readgdv(fd::IO, nodes::AbstractVector)\nreadgdv(file::AbstractString, nodes::AbstractVector)\n\nReads the .ndump2 file format that contains (static or dynamic) graphlet counts, outputted by GraphCrunch1 (ncount program in http://www0.cs.ucl.ac.uk/staff/natasa/graphcrunch/index.html), or Graphcrunch2 (http://www0.cs.ucl.ac.uk/staff/natasa/graphcrunch2/index.html), or the dynamic graphlets counting code (https://www3.nd.edu/~cone/DG/).\n\nGraphlets are small, connected, induced sub-graphs of a network (Przulj N, Corneil DG, Jurisica I: Modeling Interactome, Scale-Free or Geometric?, Bioinformatics 2004, 20(18):3508-3515.), similar to network motifs.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.writegdv",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.writegdv",
    "category": "Function",
    "text": "writegdv(fd::IO, X::AbstractMatrix, nodes::AbstractVector)\nwritegdv(file::AbstractString, X::AbstractMatrix, nodes::AbstractVector)\n\nWrites to graphlets file format. See readgdv.\n\n\n\n"
},

{
    "location": "index.html#Network-measures-1",
    "page": "NetalignUtils documentation",
    "title": "Network measures",
    "category": "section",
    "text": "readgdv\nwritegdv"
},

{
    "location": "index.html#NetalignUtils.SFGD",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.SFGD",
    "category": "Type",
    "text": "Scale-free gene duplication\n\np\nq\narrival : node arrival function (:quad, :linear, :exp, :constant)\n\nVazquez, Alexei and Flammini, Alessandro and Maritan, Amos and Vespignani, Alessandro 2003 Modeling of protein interaction networks Complexus 1 38–44\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.GEOGD",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.GEOGD",
    "category": "Type",
    "text": "Geometric gene duplication with probability cutoff\n\np : probability cutoff\nε : distance (set this to 1)\narrival : node arrival function (:quad, :linear, :exp, :constant)\n\nPrzulj, N., Kuchaiev, O., Stevanovic, A., and Hayes, W. (2010). Geometric evolutionary dynamics of protein interaction networks. In Proc. of the Pacific Symposium Biocomputing, pages 4–8.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.SocialNE",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.SocialNE",
    "category": "Type",
    "text": "Social network evolution model\n\nλ : node active lifetime\nα, β : how active a node is at adding edges\n\nLeskovec, J., Backstrom, L., Kumar, R., and Tomkins, A. (2008). Microscopic evolution of social networks. In Proc. of the 14th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining, KDD'08, pages 462–470.\n\n\n\n"
},

{
    "location": "index.html#Base.Random.rand",
    "page": "NetalignUtils documentation",
    "title": "Base.Random.rand",
    "category": "Function",
    "text": "rand([rng::AbstractRNG], gf::GraphGenerator, Ntot::Integer, Tmax::Number, N0::Integer=5)\n\nArguments\n\nNtot : total # of nodes\nN0 : # of nodes at time 0\nTmax : end of timespan\n\nGenerates a random network depending on the GraphGenerator\n\n\n\n"
},

{
    "location": "index.html#Network-generation-1",
    "page": "NetalignUtils documentation",
    "title": "Network generation",
    "category": "section",
    "text": "SFGD\nGEOGD\nSocialNE\nrand"
},

{
    "location": "index.html#NetalignUtils.strict_events_shuffle",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.strict_events_shuffle",
    "category": "Function",
    "text": "strict_events_shuffle(G::SparseMatrixCSC{Events}, prob::Number)\nstrict_events_shuffle!(G::SparseMatrixCSC{Events}, prob::Number)\n\nprob : 0 <= prob <= 1\n\nThe following does the event shuffle as in page 15/30 of modern temporal network theory a colloquim eur phys j b 2015. After that it merges overlapping events between node pairs. The number of events between node pairs will not be conserved because it merges overlapping events.\n\nThe topology of the resulting network when it is flattened does not change since only the event times are changed.\n\n\n\n"
},

{
    "location": "index.html#NetalignUtils.links_shuffle",
    "page": "NetalignUtils documentation",
    "title": "NetalignUtils.links_shuffle",
    "category": "Function",
    "text": "links_shuffle(G::SparseMatrixCSC{Events}, prob::Number)\n\nprob : 0 <= prob <= 1\n\nPage 16/30 of modern temporal network theory. Rewires each link with probability prob.\n\n\n\n"
},

{
    "location": "index.html#Randomization-1",
    "page": "NetalignUtils documentation",
    "title": "Randomization",
    "category": "section",
    "text": "strict_events_shuffle\nlinks_shuffle"
},

]}

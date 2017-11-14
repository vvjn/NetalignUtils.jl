# -*- coding: utf-8;-*-
using Distributions
using StatsBase
using LightGraphs
using DataStructures

import Base: rand

export GraphGenerator, SocialNE, GEOGD, SFGD, nodearrival

abstract type GraphGenerator end

"""
    rand([rng::AbstractRNG], gf::GraphGenerator, Ntot::Integer, Tmax::Number, N0::Integer=5)

# Arguments
- `Ntot` : total # of nodes
- `N0` : # of nodes at time 0
- `Tmax` : end of timespan

Generates a random network depending on the `GraphGenerator`
"""
rand(gf::GraphGenerator, Ntot::Integer, Tmax::Number, N0::Integer=5) =
    rand(Base.GLOBAL_RNG, gf, Ntot, Tmax, N0)

"""
Node arrival functions for the dynamic networks
Ntot -- total numnber of nodes over all time
N0 -- initial number of nodes at time 0
Tmax -- max time
Returns t(i) for i=1..Ntot, where t(i) is the arrival time for node i
t(i) is sorted from smallest to largest
    """
nodearrival(rng::AbstractRNG, af::Symbol, Ntot::Integer, N0::Integer, Tmax::Number) =
    nodearrival(Val{af}(), Ntot, N0, Tmax)
nodearrival(af::Symbol, Ntot::Integer, N0::Integer, Tmax::Number) =
    nodearrival(Base.GLOBAL_RNG, Val{af}(), Ntot, N0, Tmax)

"""Constant node arrival rate
"""
function nodearrival(rng::AbstractRNG, af::Val{:constant}, Ntot::Integer, N0::Integer, Tmax::Number)
    nodes = zeros(Float64, Ntot)
    nodes[N0+1:end] = rand(rng, Float64, Ntot-N0) .* Tmax
    nodes
end

function newton(x0::Number, f, fprime, args::Tuple=();
                tol::AbstractFloat=1e-8, maxiter::Integer=50)
    for iter in 1:maxiter
        yprime = fprime(x0, args...)
        if abs(yprime) < eps(typeof(yprime))
            warn("First derivative is zero")
            return x0
        end
        y = f(x0, args...)
        x1 = x0 - y/yprime
        if abs(x1-x0) < tol
            return x1
        end
        x0 = x1
    end
    error("Max iteration exceeded")
end

"""Linear node arrival rate
pdf(x) = B0 + 2(1 - B0) x
cdf(x) = B0 x + (1 - B0) x^2
where x is time
"""
function nodearrival(rng::AbstractRNG, af::Val{:linear}, Ntot::Integer, N0::Integer, Tmax::Number)
    nodes = zeros(Float64,Ntot)
    # using inversion sampling
    B0 = N0/Ntot
    f(x,u) = B0*x + (1 - B0) * x^2 - u
    fp(x,u) = B0 + 2*(1 - B0) * x
    for i = N0+1:Ntot
        u = rand(rng, Float64)
        x = newton(0.5, f, fp, (u,))
        nodes[i] = x * Tmax
    end
    # nodes[N0+1:Ntot] = sqrt.(rand(rng, Float64, Ntot-N0)) .* Tmax
    nodes
end

"""Quadratic node arrival rate
pdf(x) = B0 + 3(1 - B0) x^2
cdf(x) = B0 x + (1 - B0) x^3
"""
function nodearrival(rng::AbstractRNG, af::Val{:quad}, Ntot::Integer, N0::Integer, Tmax::Number)
    nodes = zeros(Float64,Ntot)
    # using inversion sampling
    B0 = N0/Ntot
    f(x,u) = B0*x + (1-B0)*x^3 - u
    fp(x,u) = B0 + 3*(1-B0)*x^2
    for i = N0+1:Ntot
        u = rand(rng, Float64)
        x = newton(0.5, f, fp, (u,))
        nodes[i] = x * Tmax
    end
    # nodes[N0+1:Ntot] = (rand(rng, Float64, Ntot-N0) .^ (1/3)) .* Tmax
    nodes
end

"""Exponential node arrival rate
"""
function nodearrival(rng::AbstractRNG, af::Val{:exp}, Ntot::Integer, N0::Integer, Tmax::Number)
    nodes = zeros(Float64,Ntot)
    nodes[N0+1:Ntot] = log.(1 .+ rand(rng, Float64, Ntot-N0)) ./ log(2) .* Tmax
    nodes
end

function init_nodearrival_pq(nodetimes)
    # node (name, isalive, birthtime, lifetime) -> node waketime
    Q = PriorityQueue{Tuple{Int,Bool,Float64,Float64},Float64}()
    u = 1
    for t in nodetimes
        enqueue!(Q, (u, false, t, 0.0), t)
        u += 1
    end
    Q
end

"Pick a direction in 3D uniformly at random"
function sample_direction(rng::AbstractRNG)
    θ = 2π * rand(rng)
    z = 2 * rand(rng) - 1
    s = sqrt(1-z^2)
    (s * cos(θ), s * sin(θ), z)
end

"Pick a 3D point in a sphere uniformly at random"
function sample_sphere_volume(rng::AbstractRNG, R)
    (x,y,z) = sample_direction(rng)
    r = R*(rand(rng)^(1/3))
    (r*x, r*y, r*z)
end

"Euclidean distance between two points in 3D"
dist3d(x,y) = sqrt((x[1]-y[1])^2 + (x[2]-y[2])^2 + (x[3]-y[3])^2)

"""
Geometric gene duplication with probability cutoff

- `p` : probability cutoff
- `ε` : distance (set this to 1)
- `arrival` : node arrival function (:quad, :linear, :exp, :constant)
 
Przulj, N., Kuchaiev, O., Stevanovic, A., and Hayes, W. (2010). Geometric evolutionary dynamics of protein interaction networks. In Proc. of the Pacific Symposium Biocomputing, pages 4–8.
"""
immutable GEOGD <: GraphGenerator
    p::Float64
    ε::Float64
    arrival::Symbol
end
function rand(rng::AbstractRNG, gf::GEOGD, Ntot::Integer, Tmax::Number, N0::Integer=5)
    nodetimes = nodearrival(gf.arrival, Ntot, N0, Tmax-1)
    # initialize nodes
    Q = init_nodearrival_pq(nodetimes)
    nnodes = length(Q)
    I = Int[]
    J = Int[]
    events = Events[]
    points = Tuple{Int,Tuple{Float64,Float64,Float64}}[] # should be a kdtree or sth but hey
    # main loop
    while !isempty(Q)
        ((u,isalive,birthtime,lifetime),curtime) = dequeue_pair!(Q)
        if curtime == 0
            locu = sample_sphere_volume(rng, gf.ε/2)
        else
            (v,(vx,vy,vz)) = rand(rng, points)
            (x,y,z) = sample_direction(rng)
            if rand(rng) < gf.p
                r = gf.ε * rand(rng)
            else
                r = 10gf.ε * rand(rng)
            end
            locu = (vx+r*x,vy+r*y,vz+r*z)
        end
        push!(points, (u, locu))
        for i = 1:length(points)-1
            (v,locv) = points[i]
            if dist3d(locu,locv) < gf.ε
                push!(I, u)
                push!(J, v)
                push!(events, Events([(curtime, Tmax)]))
            end
        end
    end
    sparse(vcat(I,J), vcat(J,I), vcat(events,events), nnodes, nnodes, fixevents)
end

function add_event!(E::Dict, u, v, t_s, t_e)
    u, v = min(u,v), max(u,v)
    if (u,v) in keys(E)
        push!(E[(u,v)], (t_s,t_e))
    else
        E[(u,v)] = [(t_s,t_e)]
    end
end

function stop_event!(E::Dict, u, v, t_enew)
    u, v = min(u,v), max(u,v)
    (t_s,t_e) = E[(u,v)][end]
    if t_s == t_enew
        pop!(E[(u,v)])
    elseif t_e >= t_enew
        E[(u,v)][end] = (t_s,t_enew)
    else
        error("algo error")
    end
end

"""
 Scale-free gene duplication

- `p`
- `q`
- `arrival` : node arrival function (:quad, :linear, :exp, :constant)

 Vazquez, Alexei and Flammini, Alessandro and Maritan, Amos and Vespignani, Alessandro 2003 Modeling of protein interaction networks Complexus 1 38–44
"""
immutable SFGD <: GraphGenerator
    p::Float64
    q::Float64
    arrival::Symbol
end

function rand(rng::AbstractRNG, gf::SFGD, Ntot::Integer, Tmax::Number, N0::Integer=5)
    nodetimes = nodearrival(gf.arrival, Ntot, N0, Tmax-1)
    # initialize nodes
    Q = init_nodearrival_pq(nodetimes)
    nnodes = length(Q)
    G = Graph(nnodes)
    E = Dict{Tuple{Int,Int},Vector{Tuple{Float64,Float64}}}() # value vector will be max size 1 always
    nodes = Int[]
    # main loop
    while !isempty(Q)
        ((u,isalive,birthtime,lifetime),curtime) = dequeue_pair!(Q)
        push!(nodes, u)
        if curtime == 0
            for v in nodes[1:end-1]
                add_edge!(G, u, v)
                add_event!(E, u, v, curtime, Tmax)
            end
        else
            v = rand(rng, nodes[1:end-1]) # select a node randomly and make u its duplicate
            W = copy(neighbors(G,v))
            for w in W
                add_edge!(G, u, w)
                add_event!(E, u, w, curtime, Tmax)
            end
            for w in W
                if rand(rng) < 0.5
                    if rand(rng) < gf.q
                        rem_edge!(G, u, w)
                        stop_event!(E, u, w, curtime)
                    end
                else
                    if rand(rng) < gf.q
                        rem_edge!(G, v, w)
                        stop_event!(E, v, w, curtime)
                    end
                end
            end
            if rand(rng) < gf.p
                add_edge!(G, u, v)
                add_event!(E, u, v, curtime, Tmax)
            end
        end
    end
    I = Int[]
    J = Int[]
    events = Events[]
    for ((u,v),evs) in E
        if !isempty(evs)
            push!(I, u)
            push!(J, v)
            push!(events, Events(evs))
        end
    end
    sparse(vcat(I,J), vcat(J,I), vcat(events,events), nnodes, nnodes, fixevents)
end

function random_random_neighbor(rng, G,u)
    v = rand(rng, neighbors(G,u))
    W = neighbors(G,v)
    w = rand(rng, W)
end

""" Social network evolution model
- `λ` : node active lifetime
- `α, β` : how active a node is at adding edges

Leskovec, J., Backstrom, L., Kumar, R., and Tomkins, A. (2008). Microscopic evolution of social networks. In Proc. of the 14th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining, KDD'08, pages 462–470.
"""
immutable SocialNE <: GraphGenerator
    λ::Float64
    α::Float64
    β::Float64
    arrival::Symbol # node arrival function, see nodearrival
end

function rand(rng::AbstractRNG, gf::SocialNE, Ntot::Integer, Tmax::Number, N0::Integer=5)
    nodetimes = nodearrival(gf.arrival, Ntot, N0, Tmax-1)
    # initialize nodes
    Q = init_nodearrival_pq(nodetimes)
    nnodes = length(Q)
    G = Graph(nnodes)
    I = Int[]
    J = Int[]
    events = Events[]
    explaw = Exponential(1/gf.λ)
    # main loop
    iter = 1
    while !isempty(Q)
        ((u,isalive,birthtime,lifetime),curtime) = dequeue_pair!(Q)
        # distinguish between birth and wake
        if !isalive # if the node is born now
            isalive = true
            lifetime = rand(rng, explaw) # node u's lifetime
            if iter != 1
                # add u's first edge to node v w/ prob. prop. to v's degree
                v = sample(rng, 1:nnodes, StatsBase.Weights(LightGraphs.degree(G)))
                add_edge!(G, u, v)
                push!(I, u)
                push!(J, v)
                push!(events, Events([(curtime,Tmax)]))
            end
        else # if the node is waking up
            # do random-random triangle closing
            w = random_random_neighbor(rng, G, u)
            if v != w
                add_edge!(G, v, w)
                push!(I, v)
                push!(J, w)
                push!(events, Events([(curtime,Tmax)]))
            end
        end
        d = LightGraphs.degree(G,u)
        # set u's sleep time
        powerlawexpcutoff = Gamma(1 - gf.α, 1/(gf.β * d))
        sleeptime = rand(powerlawexpcutoff)
        waketime = curtime + sleeptime
        # add next waketime to queue
        if (waketime <= birthtime + lifetime) && (waketime < Tmax)
            # add to queue only if node active before lifetime
            enqueue!(Q, (u,isalive,birthtime,lifetime), waketime)
        end
        iter += 1
    end
    sparse(vcat(I,J), vcat(J,I), vcat(events,events), nnodes, nnodes, fixevents)
end

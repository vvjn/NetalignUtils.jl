export strict_events_shuffle, strict_events_shuffle!, links_shuffle

"""
    strict_events_shuffle(G::SparseMatrixCSC{Events}, prob::Number)
    strict_events_shuffle!(G::SparseMatrixCSC{Events}, prob::Number)

- `prob` : `0 <= prob <= 1`

The following does the event shuffle as
in page 15/30 of modern temporal network theory a colloquim eur phys j b 2015.
After that it merges overlapping events between node pairs.
The number of events between node pairs will not be conserved
because it merges overlapping events.

The topology of the resulting network when it is flattened does not change
since only the event times are changed.
"""
strict_events_shuffle(G::SparseMatrixCSC{Events}, prob::Number) =
    strict_events_shuffle!(deepcopy(G),prob)
function strict_events_shuffle!(G::SparseMatrixCSC{Events}, prob::Number)
    I,J,V = findnz(G)
    ns = map(x -> length(x.timestamps), V)
    cns = cumsum(ns)
    n = cns[end] # number of events
    pcns = [0;cns]

    for u = 1:n
        if rand() < prob
            v = rand(1:n)

            uix = searchsorted(cns,u).start # pick uth = (uix,ui) and vth = (vix,vi) event
            vix = searchsorted(cns,v).start
            ui = u-pcns[uix]
            vi = v-pcns[vix]

            temp = V[uix].timestamps[ui]
            V[uix].timestamps[ui] = V[vix].timestamps[vi]
            V[vix].timestamps[vi] = temp
        end
    end
    V = map(x -> Events(mergeevents!(sort!(x.timestamps))), V)
    sparse(I, J, V, size(G,1), size(G,2), mergeevents)
end

function stack(xs::AbstractVector{<:AbstractVector})
    ns = map(length, xs)
    ys = Vector{eltype(eltype(xs))}(sum(ns))
    k = 1
    for x in xs
        for z in x
            ys[k] = z
            k += 1
        end
    end
    ys
end

"""
    links_shuffle(G::SparseMatrixCSC{Events}, prob::Number)

- `prob` : `0 <= prob <= 1`

Page 16/30 of modern temporal network theory.
Rewires each link with probability `prob`.
"""
function links_shuffle(G::SparseMatrixCSC{Events}, prob::Number)
    Ih,Jh,Vh = findnz(G)
    ns = map(x -> length(x.timestamps), Vh)
    I = stack(map(i -> fill(Ih[i],ns[i]), 1:length(Vh)))
    J = stack(map(i -> fill(Jh[i],ns[i]), 1:length(Vh)))
    V = stack(map(x -> x.timestamps, Vh))
    n = sum(ns)
    for u = 1:length(V)
        if rand() < prob
            noselflink = false
            i,j,ip,jp = 0,0,0,0
            v = 0
            while !noselflink
                v = rand(1:n)
                i,j,ip,jp = I[u],J[u],I[v],J[v]
                # Pick link (i,j) and (i',j')
                if rand() < 0.5
                    # Replace (i,j)  and (i',j')
                    #      by (i,j') and (i',j)
                    i,j,ip,jp = i,jp,ip,j
                else
                    # Replace (i,j)  and (i',j')
                    #      by (i,i') and (j,j')
                    i,j,ip,jp = i,ip,j,jp
                end
                if !(i==j || ip==jp) && !(min(i,j)==min(ip,jp) && max(i,j)==max(ip,jp))
                    noselflink = true
                end
            end
            I[u],J[u] = min(i,j),max(i,j)
            I[v],J[v] = min(ip,jp),max(ip,jp)
        end
    end
    sparse(I, J, map(x -> Events([x]), V), size(G,1), size(G,1), mergeevents)
end

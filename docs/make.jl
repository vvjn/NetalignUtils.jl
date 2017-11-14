using Documenter, NetalignUtils

makedocs(
           format = :html,
           sitename = "NetalignUtils",
           pages = [
                    "index.md"
           ],
    modules = [NetalignUtils]
       )

deploydocs(
           repo = "github.com/vvjn/NetalignUtils.jl.git",
           target = "build",
           deps   = nothing,
           make   = nothing,
           julia = "0.6"
)

# module Layouts

# # using Genie, Stipple, StipplePlotly
# # import Genie.Renderer.Html: HTMLString, normal_element, register_normal_element
# # using Requires

# # export PlotLayoutMapbox, Mcenter

# # function optionals!(d::Dict, ptype::Any, opts::Vector{Symbol}) :: Dict
# #   for o in opts
# #     if getproperty(ptype, o) !== nothing
# #       d[o] = getproperty(ptype, o)
# #     end
# #   end

# #   d
# # end 

# # Base.@kwdef mutable struct Mcenter
# #   lon::Union{Float64, Int64} = -234
# #   lat::Union{Float64, Int64} = -234
# #   # family::String = raw"'Open Sans', verdana, arial, sans-serif"
# #   # size::Union{Int,Float64} = 12
# #   # color::String = "#444"
# # end

# # function MCenter(lon::Union{Float64, Int64}, lat::Union{Float64, Int64})
# #   mc = Mcenter()
# #   mc.lon = lon
# #   mc.lat = lat
# #   return mc
# # end

# # Base.@kwdef mutable struct PlotLayoutMapbox
# #   style::Union{String, Nothing} = nothing # "open-street-map"
# #   zoom::Union{Float64, Nothing} = nothing # 0
# #   center::Union{Mcenter, Nothing} = nothing # MCenter(0, 0)
# # end

# # function Base.show(io::IO, mapbox::PlotLayoutMapbox)
# #   output = "Layout Geo: \n"
# #   for f in fieldnames(typeof(mapbox))
# #     prop = getproperty(mapbox, f)
# #     if prop !== nothing
# #       output *= "$f = $prop \n"
# #     end
# #   end

# #   print(io, output)
# # end

# # function Base.Dict(mapbox::PlotLayoutMapbox)
# #   trace = Dict{Symbol, Any}()

# #   optionals!(trace, geo, [:style, :zoom, :center])
# # end

# # function Stipple.render(mapbox::PlotLayoutMapbox, fieldname::Union{Symbol,Nothing} = nothing)
# #   Dict(map)
# # end


# end
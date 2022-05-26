module Layouts

using Genie, Stipple, StipplePlotly
import Genie.Renderer.Html: HTMLString, normal_element, register_normal_element
using Requires

# export PlotLayoutGeo, PRotation, GeoProjection, MCenter, PlotLayoutMapbox

function optionals!(d::Dict, ptype::Any, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(ptype, o) !== nothing
      d[o] = getproperty(ptype, o)
    end
  end

  d
end

Base.@kwdef mutable struct Protation
  lon::Union{Float64, Int64} = -234
  lat::Union{Float64, Int64} = -234
  roll::Union{Float64, Int64} = -234
end

function PRotation(lon::Union{Float64, Int64}, lat::Union{Float64, Int64}, roll::Union{Float64, Int64})
  pr = Protation()
  pr.lon = lon
  pr.lat = lat
  pr.roll = roll
  return pr
end

Base.@kwdef mutable struct GeoProjection
  parallels::Union{Vector{Float64},Nothing} = nothing
  distance::Union{Float64,Nothing} = nothing
  scale::Union{Float64,Nothing} = nothing
  tilt::Union{Float64,Nothing} = nothing
  type::Union{String,Nothing} = nothing
  rotation::Union{Protation, Nothing} = nothing
end

function Base.show(io::IO, proj::GeoProjection)
  output = "Geo Layout Projection: \n"
  for f in fieldnames(typeof(proj))
    prop = getproperty(proj, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(proj::GeoProjection)
  trace = Dict{Symbol, Any}()

  optionals!(trace, proj, [:parallels, :distance, :scale, :tilt, :type, :rotation])
end

function Stipple.render(proj::GeoProjection, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(proj)
end

Base.@kwdef mutable struct Mcenter
  lon::Union{Float64, Int64} = -234
  lat::Union{Float64, Int64} = -234
end

function MCenter(lon::Union{Float64, Int64}, lat::Union{Float64, Int64})
  mc = Mcenter()
  mc.lon = lon
  mc.lat = lat
  return mc
end

Base.@kwdef mutable struct PlotLayoutGeo
  bgcolor::Union{String, Nothing} = nothing # ""
  center::Union{Mcenter, Nothing} = nothing # MCenter(0, 0)
  coastlinecolor::Union{String, Nothing} = nothing # ""
  coastlinewidth::Union{Int, Nothing} = nothing # 1
  countrycolor::Union{String, Nothing} = nothing # ""
  countrywidth::Union{Int, Nothing} = nothing # 1
  fitbounds::Union{Bool, Nothing} = nothing # false
  framecolor::Union{String, Nothing} = nothing # ""
  framewidth::Union{Int, Nothing} = nothing # 0
  lakecolor::Union{String, Nothing} = nothing # ""
  landcolor::Union{String, Nothing} = nothing # ""
  oceancolor::Union{String, Nothing} = nothing # ""
  geoprojection::Union{GeoProjection, Nothing} = nothing
  resolution::Union{String, Nothing} = nothing # 50
  rivercolor::Union{String, Nothing} = nothing # ""
  riverwidth::Union{Int, Nothing} = nothing # 1
  scope::Union{String, Nothing} = nothing # "world"
  showcoastlines::Union{Bool, Nothing} = nothing # true
  showcountries::Union{Bool, Nothing} = nothing # true
  showframe::Union{Bool, Nothing} = nothing # false
  showlakes::Union{Bool, Nothing} = nothing # true
  showland::Union{Bool, Nothing} = nothing # true
  showocean::Union{Bool, Nothing} = nothing # true
  showrivers::Union{Bool, Nothing} = nothing # true
  showsubunits::Union{Bool, Nothing} = nothing # true
  subunitcolor::Union{String, Nothing} = nothing # ""
  subunitwidth::Union{Int, Nothing} = nothing # 1
  uirevision::Union{Int, String, Nothing} = nothing # "number or categorical coordinate string
  visible::Union{Bool, Nothing} = nothing # true
end

function Base.show(io::IO, geo::PlotLayoutGeo)
  output = "Layout Geo: \n"
  for f in fieldnames(typeof(geo))
    prop = getproperty(geo, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(geo::PlotLayoutGeo)
  trace = Dict{Symbol, Any}()

  optionals!(trace, geo, [:bgcolor, :center, :coastlinecolor, :coastlinewidth, :countrycolor, :countrywidth, :fitbounds, :framecolor, :framewidth, :lakecolor, :landcolor, :oceancolor, :geoprojection, :resolution, :rivercolor, :riverwidth, :scope, :showcoastlines, :showcountries, :showframe, :showlakes, :showland, :showocean, :showrivers, :showsubunits, :subunitcolor, :subunitwidth, :uirevision, :visible])
end

function Stipple.render(geo::PlotLayoutGeo, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(geo)
end

Base.@kwdef mutable struct PlotLayoutMapbox
  style::Union{String, Nothing} = nothing # "open-street-map"
  zoom::Union{Float64, Nothing} = nothing # 0
  center::Union{Mcenter, Nothing} = nothing # MCenter(0, 0)
end

function Base.show(io::IO, mapbox::PlotLayoutMapbox)
  output = "Layout Geo: \n"
  for f in fieldnames(typeof(mapbox))
    prop = getproperty(mapbox, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(mapbox::PlotLayoutMapbox)
  trace = Dict{Symbol, Any}()

  optionals!(trace, geo, [:style, :zoom, :center])
end

function Stipple.render(mapbox::PlotLayoutMapbox, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(map)
end


end
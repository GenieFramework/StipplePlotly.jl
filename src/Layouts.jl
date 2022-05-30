module Layouts

using Genie, Stipple, StipplePlotly
import Genie.Renderer.Html: HTMLString, normal_element, register_normal_element
using Requires

const LAYOUT_TITLE_REF_CONTAINER = "container"
const LAYOUT_TITLE_REF_PAPER = "paper"
const LAYOUT_AUTO = "auto"
const LAYOUT_LEFT = "left"
const LAYOUT_CENTER = "center"
const LAYOUT_RIGHT = "right"
const LAYOUT_TOP = "top"
const LAYOUT_MIDDLE = "middle"
const LAYOUT_BOTTOM = "bottom"
const LAYOUT_ORIENTATION_VERTICAL = "v"
const LAYOUT_ORIENTATION_HORIZONTAL = "h"
const LAYOUT_ITEMSIZING_TRACE = "trace"
const LAYOUT_ITEMSIZING_CONSTANT = "constant"
const LAYOUT_CLICK_TOGGLE = "toggle"
const LAYOUT_CLICK_TOGGLEOTHERS = "toggleothers"
const LAYOUT_HIDE = "hide"
const LAYOUT_SHOW = "show"
const LAYOUT_ABOVE = "above"
const LAYOUT_BELOW = "below"
const LAYOUT_OVERLAY = "overlay"
const LAYOUT_GROUP = "group"
const LAYOUT_STACK = "stack"

function optionals!(d::Dict, ptype::Any, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(ptype, o) !== nothing
      d[o] = getproperty(ptype, o)
    end
  end

  d
end

#===#

Base.@kwdef mutable struct Font
  family::String = raw"'Open Sans', verdana, arial, sans-serif"
  size::Union{Int,Float64} = 12
  color::String = "#444"
end

function Font(fontsize::Union{Int,Float64})
  fs = Font()
  fs.size = fontsize
  return fs
end

Base.:(==)(x::Font, y::Font) = x.family == y.family && x.size == y.size && x.color == y.color

Base.hash(f::Font) = hash("$(f.family)$(f.size)$(f.color)")

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

#===#

Base.@kwdef mutable struct ColorBar
  thicknessmode::Union{String,Nothing} = nothing # "fraction" | "pixels", default is pixels
  thickness::Union{Int,Nothing} = nothing # 30
  lenmode::Union{String,Nothing} = nothing # "fraction" | "pixels", default is fraction
  len::Union{Float64,Int,Nothing} = nothing # 1
  x::Union{Float64,Nothing} = nothing # 1.02
  xanchor::Union{String,Nothing} = nothing # "left" | "center" | "right", default is left
  xpad::Union{Int,Nothing} = nothing # 10
  yanchor::Union{String,Nothing} = nothing # "top" | "middle" | "bottom", default is middle
  ypad::Union{Int,Nothing} = nothing # 10
  outlinecolor::Union{String,Nothing} = nothing # "#444"
  bordercolor::Union{String,Nothing} = nothing # "#444"
  borderwidth::Union{Int,Nothing} = nothing # 0
  bgcolor::Union{String,Nothing} = nothing # "rgba(0,0,0,0)"
  tickmode::Union{String,Nothing} = nothing
  nticks::Union{Int,Nothing} = nothing
  tick0::Union{Float64,Int,String,Nothing} = nothing
  dtick::Union{Float64,Int,String,Nothing} = nothing
  tickvals::Union{Vector{Float64},Vector{Int},Nothing} = nothing
  ticktext::Union{Vector{String},Nothing} = nothing
  ticks::Union{String,Nothing} = nothing # "outside" | "inside" | ""
  ticklabelposition::Union{String,Nothing} = nothing # "outside" | "inside" | "outside top" | "inside top" | "outside bottom" | "inside bottom", default is outside
  ticklen::Union{Int,Nothing} = nothing # 5
  tickwidth::Union{Int,Nothing} = nothing # 1
  tickcolor::Union{String,Nothing} = nothing # "#444"
  showticklabels::Union{Bool,Nothing} = nothing # true
  tickfont::Union{Font,Nothing} = nothing
  tickangle::Union{String,Int,Float64,Nothing} = nothing
  tickformat::Union{String,Nothing} = nothing
  tickformatstops::Union{Dict,Nothing} = nothing
  tickprefix::Union{String,Nothing} = nothing
  showtickprefix::Union{String,Nothing} = nothing # "all" | "first" | "last" | "none", default is all
  ticksuffix::Union{String,Nothing} = nothing
  showticksuffix::Union{String,Nothing} = nothing # "all" | "first" | "last" | "none",
  separatethousands::Union{Bool,Nothing} = nothing
  exponentformat::Union{String,Nothing} = nothing # none" | "e" | "E" | "power" | "SI" | "B", default is B
  minexponent::Union{Int,Nothing} = nothing
  showexponent::Union{String,Nothing} = nothing
  # needs special treatment:
  title_text::Union{String,Nothing} = nothing # ""
  title_font::Union{Font,Nothing} = nothing # Font()
  title_side::Union{String,Nothing} = nothing # LAYOUT_LEFT
end

function Base.show(io::IO, cb::ColorBar)
  output = "ColorBar: \n"
  for f in fieldnames(typeof(cb))
    prop = getproperty(cb, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(cb::ColorBar)
  trace = Dict{Symbol, Any}()

  d = Dict{Symbol, Any}()
  (cb.title_text !== nothing) && (d[:text] = cb.title_text)
  (cb.title_font !== nothing) && (d[:font] = cb.title_font)
  (cb.title_side !== nothing) && (d[:side] = cb.title_side)
  (length(d) > 0) && (trace[:title] = d)

  optionals!(trace, cb, [
    :thicknessmode, :thickness, :lenmode, :len, :x, :xanchor, :xpad, :yanchor, :ypad, :outlinecolor, :bordercolor,
    :borderwidth, :bgcolor, :tickmode, :nticks, :tick0, :dtick, :tickvals, :ticktext, :ticks, :ticklabelposition,
    :ticklen, :tickwidth, :tickcolor, :showticklabels, :tickfont, :tickangle, :tickformat, :tickformatstops, :tickprefix,
    :showtickprefix, :ticksuffix, :showticksuffix, :separatethousands, :exponentformat, :minexponent, :showexponent
  ])
end

function Stipple.render(cb::ColorBar, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(cb)
end

function ColorBar(text, title_font_size::Union{Int,Float64}, side)
  cb = ColorBar()
  cb.title_text = text
  cb.title_font = Font(title_font_size)
  cb.title_side = side
  cb
end

#===#

Base.@kwdef mutable struct ErrorBar
  visible::Union{Bool,Nothing} = nothing
  type::Union{String,Nothing} = nothing # "percent" | "constant" | "sqrt" | "data"
  symmetric::Union{Bool,Nothing} = nothing
  array::Union{Vector{Float64},Nothing} = nothing
  arrayminus::Union{Vector{Float64},Nothing} = nothing
  value::Union{Float64,Nothing} = nothing # 10
  valueminus::Union{Float64,Nothing} = nothing # 10
  traceref::Union{Int,Nothing} = nothing # 0
  tracerefminus::Union{Int,Nothing} = nothing # 0
  copy_ystyle::Union{Bool,Nothing} = nothing
  color::Union{String,Nothing} = nothing
  thickness::Union{Int,Nothing} = nothing # 2
  width::Union{Int,Nothing} = nothing # 0
end

function Base.show(io::IO, eb::ErrorBar)
  output = "Errorbar: \n"
  for f in fieldnames(typeof(eb))
    prop = getproperty(eb, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function ErrorBar(error_array::Vector; color::Union{String,Nothing} = nothing)
  eb = ErrorBar(visible=true, array=error_array, type="data", symmetric=true)
  (color !== nothing) && (eb.color = color)
  eb
end

function ErrorBar(error_array::Vector, error_arrayminus::Vector; color::Union{String,Nothing} = nothing)
  eb = ErrorBar(visible=true, array=error_array, type="data", symmetric=false, arrayminus=error_arrayminus)
  (color !== nothing) && (eb.color = color)
  eb
end

function ErrorBar(error_value::Number; color::Union{String,Nothing} = nothing)
  eb = ErrorBar(visible=true, value=error_value, type="percent", symmetric=true)
  (color !== nothing) && (eb.color = color)
  eb
end

function ErrorBar(error_value::Number, error_valueminus::Number; color::Union{String,Nothing} = nothing)
  eb = ErrorBar(visible=true, value=error_value, type="percent", symmetric=false, valueminus=error_valueminus)
  (color !== nothing) && (eb.color = color)
  eb
end

function Base.Dict(eb::ErrorBar)
  trace = Dict{Symbol, Any}()

  optionals!(trace, eb, [
    :visible, :type, :symmetric, :array, :arrayminus, :value, :valueminus,
    :traceref, :tracerefminus, :copy_ystyle, :color, :thickness, :width
  ])
end

function Stipple.render(eb::ErrorBar, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(eb)
end

#===#

Base.@kwdef mutable struct PlotAnnotation
  visible::Union{Bool,Nothing} = nothing
  text::Union{String,Nothing} = nothing
  textangle::Union{Float64,Int,Nothing} = nothing
  font::Union{Font,Nothing} = nothing
  width::Union{Float64,Int,Nothing} = nothing
  height::Union{Float64,Int,Nothing} = nothing
  opacity::Union{Float64,Nothing} = nothing
  align::Union{String,Nothing} = nothing
  valign::Union{String,Nothing} = nothing
  bgcolor::Union{String,Nothing} = nothing
  bordercolor::Union{String,Nothing} = nothing
  borderpad::Union{Int,Nothing} = nothing
  borderwidth::Union{Int,Nothing} = nothing
  showarrow::Union{Bool,Nothing} = nothing
  arrowcolor::Union{String,Nothing} = nothing
  arrowhead::Union{Int,Nothing} = nothing
  startarrowhead::Union{Int,Nothing} = nothing
  arrowside::Union{String,Nothing} = nothing
  arrowsize::Union{Float64,Nothing} = nothing
  startarrowsize::Union{Float64,Nothing} = nothing
  arrowwidth::Union{Float64,Nothing} = nothing
  standoff::Union{Int,Nothing} = nothing
  startstandoff::Union{Int,Nothing} = nothing
  ax::Union{String,Int,Float64,Nothing} = nothing
  ay::Union{String,Int,Float64,Nothing} = nothing
  axref::Union{String,Nothing} = nothing
  ayref::Union{String,Nothing} = nothing
  xref::Union{String,Int,Float64,Nothing} = nothing
  x::Union{String,Int,Float64,Nothing} = nothing
  xanchor::Union{String,Nothing} = nothing
  xshift::Union{Int,Float64,Nothing} = nothing
  yref::Union{String,Int,Float64,Nothing} = nothing
  y::Union{String,Int,Float64,Nothing} = nothing
  yanchor::Union{String,Nothing} = nothing
  yshift::Union{Int,Float64,Nothing} = nothing
  # TODO: clicktoshow
  # TODO: xclick
  # TODO: yclick
  hoverlabel::Union{Dict,Nothing} = nothing
  captureevents::Union{Bool,Nothing} = nothing
  name::Union{String,Nothing} = nothing
  templateitemname::Union{String,Nothing} = nothing
end

function Base.show(io::IO, an::PlotAnnotation)
  output = "Annotation: \n"
  for f in fieldnames(typeof(an))
    prop = getproperty(an, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(an::PlotAnnotation)
  trace = Dict{Symbol,Any}()

  if an.font !== nothing
    trace[:font] = Dict(
      :family => an.font.family,
      :size => an.font.size,
      :color => an.font.color
    )
  end

  if an.hoverlabel !== nothing
    trace[:hoverlabel] = an.hoverlabel
  end

  optionals!(trace, an, [:visible, :text, :textangle, :width, :height, :opacity,
          :align, :valign, :bgcolor, :bordercolor, :borderpad, :borderwidth, :showarrow,
          :arrowcolor, :arrowhead, :startarrowhead, :arrowside, :arrowsize, :startarrowsize,
          :arrowwidth, :standoff, :startstandoff, :ax, :ay, :axref, :ayref, :xref, :x,
          :xanchor, :xshift, :yref, :y, :yanchor, :yshift, :captureevents, :name, :templateitemname])

end

function Stipple.render(anv::Vector{PlotAnnotation}, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(an) for an in anv]
end

#===#

Base.@kwdef mutable struct PlotLayoutAxis
  xy::String = "x" # "x" or "y"
  index::Int = 1 # 1, 2, 3 etc. for subplots

  visible::Union{Bool,Nothing} = nothing
  title::Union{String,Nothing} = nothing # "axis title"
  font::Union{Font,Nothing} = nothing
  title_text::Union{String,Nothing} = nothing
  title_font::Union{Font,Nothing} = nothing
  title_standoff::Union{Int,Nothing} = nothing
  automargin::Union{Bool,Nothing} = nothing
  ticks::Union{String,Nothing} = nothing
  showline::Union{Bool,Nothing} = nothing
  zeroline::Union{Bool,Nothing} = nothing
  linecolor::Union{String,Nothing} = nothing
  linewidth::Union{Int,Nothing} = nothing
  mirror::Union{Bool,String,Nothing} = nothing
  ticklabelposition::Union{String,Nothing} = nothing
  tickson::Union{String,Nothing} = nothing
  ticklabelmode::Union{String,Nothing} = nothing
  ticklen::Union{Int,Nothing} = nothing
  tickwidth::Union{Int,Nothing} = nothing
  tickcolor::Union{String,Nothing} = nothing
  showticklabels::Union{Bool,Nothing} = nothing
  showspikes::Union{Bool,Nothing} = nothing
  spikecolor::Union{String,Nothing} = nothing
  spikethickness::Union{Int,Nothing} = nothing
  spikedash::Union{String,Nothing} = nothing
  spikemode::Union{String,Nothing} = nothing
  spikesnap::Union{String,Nothing} = nothing
  showgrid::Union{Bool,Nothing} = nothing
  gridcolor::Union{String,Nothing} = nothing
  gridwidth::Union{Int,Nothing} = nothing
  side::Union{String,Nothing} = nothing
  anchor::Union{String,Nothing} = nothing
  position::Union{Float64,Nothing} = nothing
  domain::Union{Vector{Float64},Nothing} = nothing
  scaleanchor::Union{String,Nothing} = nothing
  scaleratio::Union{Int,Nothing} = nothing
  constrain::Union{String,Nothing} = nothing
  constraintoward::Union{String,Nothing} = nothing
  autorange::Union{Bool,String,Nothing} = nothing
  rangemode::Union{String,Nothing} = nothing
  range::Union{Vector{Int},Vector{Float64},Nothing} = nothing
  fixedrange::Union{Bool,Nothing} = nothing
  type::Union{String,Nothing} = nothing
  autotypenumbers::Union{String,Nothing} = nothing
  tickmode::Union{String,Nothing} = nothing
  nticks::Union{Int,Nothing} = nothing
  tick0::Union{Float64,Int,String,Nothing} = nothing
  dtick::Union{Float64,Int,String,Nothing} = nothing
  tickvals::Union{Vector{Float64},Vector{Int},Nothing} = nothing
  ticktext::Union{Vector{String},Nothing} = nothing
  tickformat::Union{String,Nothing} = nothing
  tickfont::Union{Font,Nothing} = nothing
  tickangle::Union{String,Int,Float64,Nothing} = nothing
  tickprefix::Union{String,Nothing} = nothing
  ticksuffix::Union{String,Nothing} = nothing
  showexponent::Union{String,Nothing} = nothing
  minexponent::Union{Int,Nothing} = nothing
  hoverformat::Union{String,Nothing} = nothing
  zerolinecolor::Union{String,Nothing} = nothing
  zerolinewidth::Union{Int,Nothing} = nothing
  showdividers::Union{Bool,Nothing} = nothing
  dividercolor::Union{String,Nothing} = nothing
  dividerwidth::Union{Int,Nothing} = nothing
  overlaying::Union{String,Nothing} = nothing
  layer::Union{String,Nothing} = nothing
  categoryorder::Union{String,Nothing} = nothing
  categoryarray::Union{Vector{Float64},Nothing} = nothing
  calendar::Union{String,Nothing} = nothing
end

function Base.show(io::IO, la::PlotLayoutAxis)
  output = "Layout Axis: \n"
  for f in fieldnames(typeof(la))
    prop = getproperty(la, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(la::PlotLayoutAxis)
  trace = Dict{Symbol,Any}()

  if la.title_text !== nothing
    d = Dict{Symbol,Any}(:text => la.title_text)
    (la.title_font !== nothing) && (d[:font] = la.title_font)
    (la.title_standoff !== nothing) && (d[:standoff] = la.title_standoff)
    trace[:title] = d
  end

  d = optionals!(trace, la, [:visible, :title, :font, :automargin, :ticks, :showline, :zeroline,
                         :linecolor, :linewidth, :mirror, :ticklabelposition, :showgrid,
                         :gridcolor, :gridwidth, :side, :anchor, :position, :domain, :scaleanchor,
                         :scaleratio, :constrain, :constraintoward, :autorange,
                         :rangemode, :range, :fixedrange, :type, :autotypenumbers,
                         :tickmode, :nticks, :tick0, :dtick, :tickvals, :ticktext, :tickformat, :tickfont,
                         :tickangle, :tickprefix, :ticksuffix, :showexponent, :minexponent,
                         :hoverformat, :zerolinecolor, :zerolinewidth, :showdividers, :dividercolor,
                         :dividerwidth, :overlaying, :layer, :categoryorder, :categoryarray, :calendar,
                         :tickson, :ticklabelmode, :ticklen, :tickwidth, :tickcolor, :showticklabels,
                         :showspikes, :spikecolor, :spikethickness, :spikedash, :spikemode, :spikesnap])

  k = Symbol(la.xy * "axis" * ((la.index > 1) ? "$(la.index)" : ""))
  Dict(k => d)
end

function Stipple.render(la::PlotLayoutAxis, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(la)]
end

function Stipple.render(lav::Vector{PlotLayoutAxis}, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(la) for la in lav]
end

#===#

Base.@kwdef mutable struct PlotLayoutTitle
  text::Union{String,Nothing} = nothing # ""
  font::Union{Font,Nothing} = nothing # Font()
  xref::Union{String,Nothing} = nothing # LAYOUT_TITLE_REF_CONTAINER
  yref::Union{String,Nothing} = nothing # LAYOUT_TITLE_REF_CONTAINER
  x::Union{Float64,String,Nothing} = nothing # 0.5
  y::Union{Float64,String,Nothing} = nothing # LAYOUT_AUTO
  xanchor::Union{String,Nothing} = nothing # LAYOUT_AUTO
  yanchor::Union{String,Nothing} = nothing # LAYOUT_AUTO
  pad_t::Union{Int,Nothing} = nothing # 0
  pad_r::Union{Int,Nothing} = nothing # 0
  pad_b::Union{Int,Nothing} = nothing # 0
  pad_l::Union{Int,Nothing} = nothing # 0
end

function Base.show(io::IO, plt::PlotLayoutTitle)
  output = "Layout Title: \n"
  for f in fieldnames(typeof(plt))
    prop = getproperty(plt, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(plt::PlotLayoutTitle)
  trace = Dict{Symbol, Any}()

  d = Dict{Symbol, Any}()
  (plt.pad_t !== nothing) && (d[:t] = plt.pad_t)
  (plt.pad_r !== nothing) && (d[:r] = plt.pad_r)
  (plt.pad_b !== nothing) && (d[:b] = plt.pad_b)
  (plt.pad_l !== nothing) && (d[:l] = plt.pad_l)
  (length(d) > 0) && (trace[:pad] = d)

  optionals!(trace, plt, [:text, :font, :xref, :yref, :x, :y, :xanchor, :yanchor])
end

function Stipple.render(plt::PlotLayoutTitle, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(plt)
end

#===#

Base.@kwdef mutable struct PlotLayoutLegend
  bgcolor::Union{String,Nothing} = nothing
  bordercolor::Union{String,Nothing} = nothing # "#444"
  borderwidth::Union{Int,Nothing} = nothing # 0
  font::Union{Font,Nothing} = nothing # Font()
  orientation::Union{String,Nothing} = nothing # LAYOUT_ORIENTATION_VERTICAL
  traceorder::Union{String,Nothing} = nothing # "normal"
  tracegroupgap::Union{Int,Nothing} = nothing # 10
  itemsizing::Union{String,Nothing} = nothing # LAYOUT_ITEMSIZING_TRACE
  itemwidth::Union{Int,Nothing} = nothing # 30
  itemclick::Union{String,Bool,Nothing} = nothing # LAYOUT_CLICK_TOGGLE
  itemdoubleclick::Union{String,Bool,Nothing} = nothing #  LAYOUT_CLICK_TOGGLEOTHERS
  x::Union{Int,Float64,Nothing} = nothing # 1.02
  xanchor::Union{String,Nothing} = nothing # LAYOUT_LEFT
  y::Union{Int,Float64,Nothing} = nothing # 1
  yanchor::Union{String,Nothing} = nothing # LAYOUT_AUTO
  # TODO: uirevision::Union{Int,String} = ""
  valign::Union{String,Nothing} = nothing # LAYOUT_MIDDLE
  title_text::Union{String,Nothing} = nothing # ""
  title_font::Union{Font,Nothing} = nothing # Font()
  title_side::Union{String,Nothing} = nothing # LAYOUT_LEFT
end

function Base.show(io::IO, pll::PlotLayoutLegend)
  output = "Layout Legend: \n"
  for f in fieldnames(typeof(pll))
    prop = getproperty(pll, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(pll::PlotLayoutLegend)
  trace = Dict{Symbol, Any}()

  d = Dict{Symbol, Any}()
  (pll.title_text !== nothing) && (d[:text] = pll.title_text)
  (pll.title_font !== nothing) && (d[:font] = pll.title_font)
  (pll.title_side !== nothing) && (d[:side] = pll.title_side)
  (length(d) > 0) && (trace[:title] = d)

  optionals!(trace, pll, [:bgcolor, :bordercolor, :borderwidth, :font, :orientation, :traceorder, :tracegroupgap, :itemsizing, :itemwidth, :itemclick, :itemdoubleclick, :x, :xanchor, :y, :yanchor, :valign])
end

function Stipple.render(pll::PlotLayoutLegend, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pll)
end

#===#

Base.@kwdef mutable struct PlotLayoutGrid
  rows::Union{Int,Nothing} = nothing # >= 1
  roworder::Union{String,Nothing} = nothing # "top to bottom" | "bottom to top"
  columns::Union{Int,Nothing} = nothing # >= 1
  subplots::Union{Matrix{String},Nothing} = nothing
  xaxes::Union{Vector{String},Nothing} = nothing
  yaxes::Union{Vector{String},Nothing} = nothing
  pattern::Union{String,Nothing} = nothing # "independent" | "coupled"
  xgap::Union{Float64,Nothing} = nothing # [0.0, 1.0]
  ygap::Union{Float64,Nothing} = nothing # [0.0, 1.0]
  domain_x::Union{Vector{Float64},Nothing} = nothing # fraction, e.g [0, 1]
  domain_y::Union{Vector{Float64},Nothing} = nothing # fraction, e.g [0, 1]
  xside::Union{String,Nothing} = nothing # "bottom" | "bottom plot" | "top plot" | "top"
  yside::Union{String,Nothing} = nothing # "bottom" | "bottom plot" | "top plot" | "top"
end

function Base.show(io::IO, lg::PlotLayoutGrid)
  output = "Layout Grid: \n"
  for f in fieldnames(typeof(lg))
    prop = getproperty(lg, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(lg::PlotLayoutGrid)
  trace = Dict{Symbol,Any}()

  if (lg.domain_x !== nothing) & (lg.domain_y !== nothing)
    trace[:domain] = Dict(
      :x => lg.domain_x,
      :y => lg.domain_y
    )
  elseif lg.domain_x !== nothing
    trace[:domain] = Dict(
      :x => lg.domain_x
    )
  elseif lg.domain_y !== nothing
    trace[:domain] = Dict(
      :y => lg.domain_y
    )
  end

  optionals!(trace, lg, [:rows, :roworder, :columns, :subplots, :xaxes, :yaxes,
                         :pattern, :xgap, :ygap, :xside, :yside])

end

#===#

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

#===#

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
  lataxis::Union{PlotLayoutAxis,Nothing} = nothing
  lonaxis::Union{PlotLayoutAxis,Nothing} = nothing
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

#===#

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

#===#

Base.@kwdef mutable struct PlotLayout
  title::Union{PlotLayoutTitle,Nothing} = nothing
  xaxis::Union{Vector{PlotLayoutAxis},Nothing} = nothing
  yaxis::Union{Vector{PlotLayoutAxis},Nothing} = nothing

  showlegend::Union{Bool,Nothing} = nothing # true
  legend::Union{PlotLayoutLegend,Nothing} = nothing
  annotations::Union{Vector{PlotAnnotation},Nothing} = nothing
  geo::Union{PlotLayoutGeo,Nothing} = nothing
  grid::Union{PlotLayoutGrid,Nothing} = nothing
  mapbox::Union{PlotLayoutMapbox,Nothing} = nothing
  margin_l::Union{Int,Nothing} = nothing # 80
  margin_r::Union{Int,Nothing} = nothing # 80
  margin_t::Union{Int,Nothing} = nothing # 100
  margin_b::Union{Int,Nothing} = nothing # 80
  margin_pad::Union{Int,Nothing} = nothing # 0
  margin_autoexpand::Union{Bool,Nothing} = nothing # true
  autosize::Union{Bool,Nothing} = nothing # true
  width::Union{Int,String,Nothing} = nothing # 700
  height::Union{Int,String,Nothing} = nothing # 450
  font::Union{Font,Nothing} = nothing
  uniformtext_mode::Union{String,Bool,Nothing} = nothing # false
  uniformtext_minsize::Union{Int,Nothing} = nothing # 0
  separators::Union{String,Nothing} = nothing # ".,"
  paper_bgcolor::Union{String,Nothing} = nothing # "#fff"
  plot_bgcolor::Union{String,Nothing} = nothing # "#fff"

  # TODO: implement the following fields in function Stipple.render(pl::PlotLayout...
  autotypenumbers::String = "convert types"
  # TODO: colorscale settings
  colorway::Vector{String} = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
                              "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"]
  modebar_orientation::String = LAYOUT_ORIENTATION_HORIZONTAL
  modebar_bgcolor::String = "transparent"
  modebar_color::String = ""
  modebar_activecolor::String = ""
  # TODO: modebar_uirevision::String = ""
  hovermode::Union{String,Bool} = "closest"
  clickmode::String = "event"
  dragmode::String = "zoom"
  selectdirection::String = "any"
  hoverdistance::Int = 20
  spikedistance::Int = 20
  hoverlabel_bgcolor::String = ""
  hoverlabel_bordercolor::String = ""
  hoverlabel_font::Font = Font()
  hoverlabel_align::String = LAYOUT_AUTO
  hoverlabel_namelength::Int = 15
  transition_duration::Int = 500
  transition_easing::String = "cubic-in-out"
  transition_ordering::String = "layout first"
  # TODO: datarevision
  # TODO: editrevision
  # TODO: selectionrevision
  # TODO: template
  # TODO: meta
  # TODO: computed

  calendar::String = "gregorian"
  newshape_line_color::String = ""
  newshape_line_width::Int = 4
  newshape_line_dash::String = "solid"
  newshape_fillcolor::String = "rgba(0,0,0,0)"
  newshape_fillrule::String = "evenodd"
  newshape_opacity::Float64 = 1.0
  newshape_layer::String = LAYOUT_ABOVE
  newshape_drawdirection::String = "diagonal"
  activeshape_fillcolor::String = "rgb(255,0,255)"
  activeshape_opacity::Float64 = 0.5
  # TODO: hidesources
  barmode::Union{String,Nothing} = nothing # LAYOUT_GROUP
  barnorm::Union{String,Nothing} = nothing
  bargap::Union{Float64,Nothing} = nothing # 0.5
  bargroupgap::Union{Float64,Nothing} = nothing # 0
  # TODO: hiddenlabels
  # TODO: piecolorway
  extendpiecolors::Bool = true
  boxmode::String = LAYOUT_OVERLAY
  boxgap::Float64 = 0.3
  boxgroupgap::Float64 = 0.3
  violinmode::String = LAYOUT_OVERLAY
  violingap::Float64 = 0.3
  violingroupgap::Float64 = 0.3
  waterfallmode::String = LAYOUT_GROUP
  waterfallgap::Float64 = 0.3
  waterfallgroupgap::Float64 = 0.0
  funnelmode::String = LAYOUT_STACK
  funnelgap::Float64 = 0.0
  funnelgroupgap::Float64 = 0.0
  # TODO: funnelareacolorway
  extendfunnelareacolors::Bool = true
  # TODO: sunburstcolorway
  extendsunburstcolors::Bool = true
  # TODO: treemapcolorway
  extendtreemapcolors::Bool = true
end

function Base.show(io::IO, l::PlotLayout)
  default = PlotLayout()
  output = "layout: \n"
  for f in fieldnames(typeof(l))
    prop = getproperty(l, f)
    if prop != getproperty(default, f)
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

end
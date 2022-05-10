module Charts

using Genie, Stipple
import Genie.Renderer.Html: HTMLString, normal_element, register_normal_element

export PlotLayout, PlotData, PlotAnnotation, Trace, plot, ErrorBar, Font, ColorBar
export PlotLayoutGrid, PlotLayoutAxis
export PlotConfig, PlotLayoutTitle, PlotLayoutLegend, PlotlyLine, PlotDataMarker

const PLOT_TYPE_LINE = "scatter"
const PLOT_TYPE_SCATTER = "scatter"
const PLOT_TYPE_SCATTERGL = "scattergl"
const PLOT_TYPE_BAR = "bar"
const PLOT_TYPE_PIE = "pie"
const PLOT_TYPE_HEATMAP = "heatmap"
const PLOT_TYPE_HEATMAPGL = "heatmapgl"
const PLOT_TYPE_IMAGE = "image"
const PLOT_TYPE_CONTOUR = "contour"
const PLOT_TYPE_TABLE = "table"
const PLOT_TYPE_BOX = "box"
const PLOT_TYPE_VIOLIN = "violin"
const PLOT_TYPE_HISTOGRAM = "histogram"
const PLOT_TYPE_HISTOGRAM2D = "histogram2d"
const PLOT_TYPE_HISTOGRAM2DCONTOUR = "histogram2dcontour"
const PLOT_TYPE_OHLC = "ohlc"
const PLOT_TYPE_CANDLESTICK = "candlestick"
const PLOT_TYPE_WATERFALL = "waterfall"
const PLOT_TYPE_FUNNEL = "funnel"
const PLOT_TYPE_FUNNELAREA = "funnelarea"
const PLOT_TYPE_INDICATOR = "indicator"
const PLOT_TYPE_SCATTER3D = "scatter3d"
const PLOT_TYPE_SURFACE = "surface"
const PLOT_TYPE_MESH3D = "mesh3d"
const PLOT_TYPE_CONE = "cone"
const PLOT_TYPE_STREAMTUBE = "streamtube"
const PLOT_TYPE_VOLUME = "volume"
const PLOT_TYPE_ISOSURFACE = "isosurface"

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

register_normal_element("plotly", context = @__MODULE__)

    
    """
    `function plotly(p::Symbol; layout = R"$p.layout", config = R"$p.config", kwargs...)`

    Render a PlotlyBase.Plot or a struct with fields data, layout and config

    # Example
    ```julia
    julia> plotly(:plot)
    "<plotly :data=\"plot.data\" :layout=\"plot.layout\" :config=\"plot.config\"></plotly>"
    ```
    """
    function plotly(p::Symbol; layout = Symbol(p, ".layout"), config = Symbol(p, ".config"), kwargs...)
      plot("$p.data"; layout, config, kwargs...)
    end

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
    :thicknessmode, :thickness, :lenmode, :len, :x, :xanchor, :xpad, :yanchor, :ypad, :outlinecolor, :bordercolor, :borderwidth, :bgcolor, :tickmode, :nticks, :tick0, :dtick, :tickvals, :ticktext, :ticks, :ticklabelposition, :ticklen, :tickwidth, :tickcolor, :showticklabels, :tickfont, :tickangle, :tickformat, :tickformatstops, :tickprefix, :showtickprefix, :ticksuffix, :showticksuffix, :separatethousands, :exponentformat, :minexponent, :showexponent
  ])
end

function optionals!(d::Dict, cb::ColorBar, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(cb, o) !== nothing
      d[o] = getproperty(cb, o)
    end
  end

  d
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
    :visible, :type, :symmetric, :array, :arrayminus, :value, :valueminus, :traceref, :tracerefminus, :copy_ystyle, :color, :thickness, :width
  ])
end

function optionals!(d::Dict, eb::ErrorBar, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(eb, o) !== nothing
      d[o] = getproperty(eb, o)
    end
  end

  d
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

function optionals!(d::Dict, an::PlotAnnotation, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(an, o) !== nothing
      d[o] = getproperty(an, o)
    end
  end

  d
end

function Stipple.render(anv::Vector{PlotAnnotation}, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(an) for an in anv]
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

function optionals!(d::Dict, lg::PlotLayoutGrid, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(lg, o) !== nothing
      d[o] = getproperty(lg, o)
    end
  end

  d
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

function optionals!(d::Dict, la::PlotLayoutAxis, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(la, o) !== nothing
      d[o] = getproperty(la, o)
    end
  end

  d
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

function optionals!(d::Dict, plt::PlotLayoutTitle, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(plt, o) !== nothing
      d[o] = getproperty(plt, o)
    end
  end

  d
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

function optionals!(d::Dict, pll::PlotLayoutLegend, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(pll, o) !== nothing
      d[o] = getproperty(pll, o)
    end
  end

  d
end

function Stipple.render(pll::PlotLayoutLegend, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pll)
end

#===#

Base.@kwdef mutable struct PlotLayout
  title::Union{PlotLayoutTitle,Nothing} = nothing
  xaxis::Union{Vector{PlotLayoutAxis},Nothing} = nothing
  yaxis::Union{Vector{PlotLayoutAxis},Nothing} = nothing

  showlegend::Union{Bool,Nothing} = nothing # true
  legend::Union{PlotLayoutLegend,Nothing} = nothing
  annotations::Union{Vector{PlotAnnotation},Nothing} = nothing
  grid::Union{PlotLayoutGrid,Nothing} = nothing

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

#===#

Base.@kwdef mutable struct PlotlyLine
  # for all Plotly lines:
  color::Union{String,Nothing} = nothing
  width::Union{Int,Nothing} = nothing # 2
  # Scatter - line:
  shape::Union{String,Nothing} = nothing # "linear" | "spline" | "hv" | "vh" | "hvh" | "vhv"
  smoothing::Union{Float64,String,Nothing} = nothing
  dash::Union{String,Nothing} = nothing # "solid", "dot", "dash", "longdash", "dashdot", "longdashdot" or "5px,10px,2px,2px"
  simplify::Union{Bool,Nothing} = nothing
  # Scatter - marker - line:
  cauto::Union{Bool,Nothing} = nothing
  cmin::Union{Float64,Nothing} = nothing
  cmax::Union{Float64,Nothing} = nothing
  cmid::Union{Float64,Nothing} = nothing
  colorscale::Union{Matrix,String,Nothing} = nothing
  autocolorscale::Union{Bool,Nothing} = nothing
  reversescale::Union{Bool,Nothing} = nothing
  # Box - marker - line
  outliercolor::Union{String,Nothing} = nothing
  outlierwidth::Union{Int,Nothing} = nothing # 1
end

function Base.show(io::IO, pdl::PlotlyLine)
  output = "Layout Legend: \n"
  for f in fieldnames(typeof(pdl))
    prop = getproperty(pdl, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(pdl::PlotlyLine)
  trace = Dict{Symbol, Any}()

  optionals!(trace, pdl, [:color, :width, :shape, :smoothing, :dash, :simplify, :cauto, :cmin, :cmax, :cmid, :colorscale, :autocolorscale, :reversescale, :outliercolor, :outlierwidth])
end

function optionals!(d::Dict, pdl::PlotlyLine, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(pdl, o) !== nothing
      d[o] = getproperty(pdl, o)
    end
  end

  d
end

function Stipple.render(pdl::PlotlyLine, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pdl)
end

#===#

Base.@kwdef mutable struct PlotDataMarker
  symbol::Union{String, Vector{String},Nothing} = nothing
  opacity::Union{Float64,Vector{Float64},Nothing} = nothing
  size::Union{Int,Vector{Int},Nothing} = nothing
  maxdisplayed::Union{Int,Nothing} = nothing
  sizeref::Union{Float64,Nothing} = nothing
  sizemin::Union{Float64,Nothing} = nothing
  sizemode::Union{String,Nothing} = nothing
  line::Union{PlotlyLine,Nothing} = nothing
  # TODO: gradient
  color::Union{String,Vector{Float64},Nothing} = nothing # color= [2.34, 4.3, 34.5, 52.2]
  cauto::Union{Bool,Nothing} = nothing
  cmin::Union{Float64,Nothing} = nothing
  cmax::Union{Float64,Nothing} = nothing
  cmid::Union{Float64,Nothing} = nothing
  colorscale::Union{Matrix,String,Nothing} = nothing
  autocolorscale::Union{Bool,Nothing} = nothing
  reversescale::Union{Bool,Nothing} = nothing
  showscale::Union{Bool,Nothing} = nothing
  colorbar::Union{ColorBar,Nothing} = nothing
  coloraxis::Union{String,Nothing} = nothing
  # Specific for Pie charts:
  colors::Union{Vector{String},Nothing} = nothing
end

function Base.show(io::IO, pdm::PlotDataMarker)
  output = "Layout Legend: \n"
  for f in fieldnames(typeof(pdm))
    prop = getproperty(pdm, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(pdm::PlotDataMarker)
  trace = Dict{Symbol, Any}()
  (pdm.line !== nothing) && (trace[:line] = Dict(pdm.line))
  (pdm.colorbar !== nothing) && (trace[:colorbar] = Dict(pdm.colorbar))

  optionals!(trace, pdm, [:symbol, :opacity, :size, :maxdisplayed, :sizeref, :sizemin,
      :sizemode, :color, :cauto, :cmin, :cmax, :cmid, :colorscale, :autocolorscale,
      :reversescale, :showscale, :coloraxis, :colors])
end

function optionals!(d::Dict, pdm::PlotDataMarker, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(pdm, o) !== nothing
      d[o] = getproperty(pdm, o)
    end
  end

  d
end

function Stipple.render(pdm::PlotDataMarker, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pdm)
end

#===#

Base.@kwdef mutable struct PlotData
  plot::String = PLOT_TYPE_SCATTER

  align::Union{String,Nothing} = nothing
  alignmentgroup::Union{String,Nothing} = nothing
  alphahull::Union{Int,Float64,Nothing} = nothing
  anchor::Union{String,Nothing} = nothing
  aspectratio::Union{Float64,Int,Nothing} = nothing
  autobinx::Union{Bool,Nothing} = nothing
  autobiny::Union{Bool,Nothing} = nothing
  autocolorscale::Union{Bool,Nothing} = nothing
  autocontour::Union{Bool,Nothing} = nothing
  automargin::Union{Bool,Nothing} = nothing
  bandwidth::Union{Float64,Int,Nothing} = nothing
  base::Union{Float64,Int,String,Nothing} = nothing
  baseratio::Union{Float64,Int,Nothing} = nothing
  bingroup::Union{String,Nothing} = nothing
  box::Union{Dict,Nothing} = nothing
  boxmean::Union{Bool,String,Nothing} = nothing
  boxpoints::Union{Bool,String,Nothing} = nothing
  caps::Union{Dict,Nothing} = nothing
  cauto::Union{Bool,Nothing} = nothing
  cells::Union{Dict,Nothing} = nothing
  cliponaxis::Union{Bool,Nothing} = nothing
  close::Union{Vector,Nothing} = nothing
  cmax::Union{Float64,Int,Nothing} = nothing
  cmid::Union{Float64,Int,Nothing} = nothing
  cmin::Union{Float64,Int,Nothing} = nothing
  color::Union{String,Nothing} = nothing
  coloraxis::Union{String,Nothing} = nothing
  colorbar::Union{Dict,ColorBar,Nothing} = nothing
  colorscale::Union{Matrix,String,Nothing} = nothing
  columnorder::Union{Vector,Nothing} = nothing
  columnwidth::Union{Float64,Int,Vector,Nothing} = nothing
  connectgaps::Union{Bool,Nothing} = nothing
  connector::Union{Dict,Nothing} = nothing
  constraintext::Union{String,Nothing} = nothing
  contour::Union{Dict,Nothing} = nothing
  contours::Union{Dict,Nothing} = nothing
  cumulative::Union{Dict,Nothing} = nothing
  customdata::Union{Vector,Nothing} = nothing
  decreasing::Union{Dict,Nothing} = nothing
  delaunayaxis::Union{Char,String,Nothing} = nothing
  delta::Union{Dict,Nothing} = nothing
  direction::Union{String,Nothing} = nothing
  dlabel::Union{Int,Nothing} = nothing
  domain::Union{Dict,Nothing} = nothing
  dx::Union{Int,Nothing} = nothing
  dy::Union{Int,Nothing} = nothing
  error_x::Union{Dict,ErrorBar,Nothing} = nothing
  error_y::Union{Dict,ErrorBar,Nothing} = nothing
  error_z::Union{Dict,ErrorBar,Nothing} = nothing
  facecolor::Union{Vector,Nothing} = nothing
  fill::Union{String,Nothing} = nothing
  fillcolor::Union{String,Nothing} = nothing
  flatshading::Union{Bool,Nothing} = nothing
  gauge::Union{Dict,Nothing} = nothing
  groupnorm::Union{String,Nothing} = nothing
  header::Union{Dict,Nothing} = nothing
  hidesurface::Union{Bool,Nothing} = nothing
  high::Union{Dict,Nothing} = nothing
  histfunc::Union{String,Nothing} = nothing
  histnorm::Union{String,Nothing} = nothing
  hole::Union{Float64,Nothing} = nothing
  hovertext::Union{Vector{String},String,Nothing} = nothing
  hoverinfo::Union{String,Nothing} = nothing
  hoverlabel::Union{Dict,Nothing} = nothing
  hoveron::Union{String,Nothing} = nothing
  hoverongaps::Union{Bool,Nothing} = nothing
  hovertemplate::Union{Vector{String},String,Nothing} = nothing
  i::Union{Vector,Nothing} = nothing
  intensity::Union{Vector,Nothing} = nothing
  intensitymode::Union{String,Nothing} = nothing
  j::Union{Vector,Nothing} = nothing
  k::Union{Vector,Nothing} = nothing
  ids::Union{Vector{String},Nothing} = nothing
  increasing::Union{Dict,Nothing} = nothing
  insidetextanchor::Union{String,Nothing} = nothing
  insidetextfont::Union{Font,Nothing} = nothing
  insidetextorientation::Union{String,Nothing} = nothing
  isomax::Union{Float64,Int,Nothing} = nothing
  isomin::Union{Float64,Int,Nothing} = nothing
  jitter::Union{Float64,Nothing} = nothing
  labels::Union{Vector,Nothing} = nothing
  label0::Union{Int,Nothing} = nothing
  legendgroup::Union{String,Nothing} = nothing
  lighting::Union{Dict,Nothing} = nothing
  lightposition::Union{Dict,Nothing} = nothing
  line::Union{Dict,PlotlyLine,Nothing} = nothing
  low::Union{Vector,Nothing} = nothing
  lowerfence::Union{Vector,Nothing} = nothing
  marker::Union{Dict,PlotDataMarker,Nothing} = nothing
  maxdisplayed::Union{Int,Nothing} = nothing
  mean::Union{Vector,Nothing} = nothing
  measure::Union{Vector,Nothing} = nothing
  meanline::Union{Dict,Nothing} = nothing
  median::Union{Vector,Nothing} = nothing
  meta::Union{Float64,Int,String,Nothing} = nothing
  mode::Union{String,Nothing} = nothing
  name::Union{String,Nothing} = nothing
  nbinsx::Union{Int,Nothing} = nothing
  nbinsy::Union{Int,Nothing} = nothing
  ncontours::Union{Int,Nothing} = nothing
  notched::Union{Bool,Nothing} = nothing
  notchwidth::Union{Float64,Nothing} = nothing
  notchspan::Union{Vector,Nothing} = nothing
  number::Union{Dict,Nothing} = nothing
  offset::Union{Float64,Int,Vector,Nothing} = nothing
  offsetgroup::Union{String,Nothing} = nothing
  opacity::Union{Float64,Nothing} = nothing
  opacityscale::Union{Float64,Int,Vector,String,Nothing} = nothing
  colormodel::Union{String,Nothing} = nothing # image trace color models: "rgb" | "rgba" | "rgba256" | "hsl" | "hsla"
  open::Union{Vector,Nothing} = nothing
  orientation::Union{String,Nothing} = nothing
  outsidetextfont::Union{Font,Nothing} = nothing
  points::Union{Bool,String,Nothing} = nothing
  pointpos::Union{Float64,Nothing} = nothing
  projection::Union{Dict,Nothing} = nothing
  pull::Union{Float64,Vector,Nothing} = nothing
  q1::Union{Vector,Nothing} = nothing
  q3::Union{Vector,Nothing} = nothing
  quartilemethod::Union{String,Nothing} = nothing
  reversescale::Union{Bool,Nothing} = nothing
  rotation::Union{Int,Nothing} = nothing
  scalegroup::Union{String,Nothing} = nothing
  scalemode::Union{String,Nothing} = nothing
  scene::Union{String,Nothing} = nothing
  sd::Union{Vector,Nothing} = nothing
  selected::Union{Dict,Nothing} = nothing
  selectedpoints::Union{Float64,Int,String,Nothing} = nothing
  showlegend::Union{Bool,Nothing} = nothing
  showscale::Union{Bool,Nothing} = nothing
  side::Union{String,Nothing} = nothing
  sizemode::Union{String,Nothing} = nothing
  sizeref::Union{Float64,Int,Nothing} = nothing
  slices::Union{Dict,Nothing} = nothing
  sort::Union{Bool,Nothing} = nothing
  source::Union{String,Nothing} = nothing
  spaceframe::Union{Dict,Nothing} = nothing
  span::Union{Vector,Nothing} = nothing
  spanmode::Union{String,Nothing} = nothing
  stackgaps::Union{String,Nothing} = nothing
  stackgroup::Union{String,Nothing} = nothing
  starts::Union{Dict,Nothing} = nothing
  surface::Union{Dict,Nothing} = nothing
  surfaceaxis::Union{Int,String,Nothing} = nothing
  surfacecolor::Union{String,Nothing} = nothing
  text::Union{Vector{String},String,Nothing} = nothing
  textangle::Union{String,Nothing} = nothing
  textfont::Union{Font,Nothing} = nothing
  textinfo::Union{String,Nothing} = nothing
  textposition::Union{String,Nothing} = nothing
  texttemplate::Union{Vector{String},String,Nothing} = nothing
  tickwidth::Union{Float64,Nothing} = nothing
  totals::Union{Dict,Nothing} = nothing
  transpose::Union{Bool,Nothing} = nothing
  u::Union{Vector,Nothing} = nothing
  uirevision::Union{Float64,Int,String,Nothing} = nothing
  unselected::Union{Dict,Nothing} = nothing
  upperfence::Union{Vector,Nothing} = nothing
  v::Union{Vector,Nothing} = nothing
  values::Union{Vector,Nothing} = nothing
  vertexcolor::Union{Vector,Nothing} = nothing
  visible::Union{String,Bool,Nothing} = nothing
  w::Union{Vector,Nothing} = nothing
  whiskerwidth::Union{Float64,Nothing} = nothing
  width::Union{Int,Vector{Int},Nothing} = nothing
  # x::Union{Vector,Matrix,Nothing} = nothing
  x::Union{Vector,Nothing} = nothing
  x0::Union{Int,String,Nothing} = nothing
  xaxis::Union{String,Nothing} = nothing
  xbingroup::Union{String,Nothing} = nothing
  xbins::Union{Dict,Nothing} = nothing
  xcalendar::Union{String,Nothing} = nothing
  xgap::Union{Int,Nothing} = nothing
  xperiod::Union{Float64,Int,String,Nothing} = nothing
  xperiodalignment::Union{String,Nothing} = nothing
  xperiod0::Union{Float64,Int,String,Nothing} = nothing
  xtype::Union{String,Nothing} = nothing
  # y::Union{Vector,Matrix,Nothing} = nothing
  y::Union{Vector,Nothing} = nothing
  y0::Union{Int,String,Nothing} = nothing
  yaxis::Union{String,Nothing} = nothing
  ybingroup::Union{String,Nothing} = nothing
  ybins::Union{Dict,Nothing} = nothing
  ycalendar::Union{String,Nothing} = nothing
  ygap::Union{Int,Nothing} = nothing
  yperiod::Union{Float64,Int,String,Nothing} = nothing
  yperiodalignment::Union{String,Nothing} = nothing
  yperiod0::Union{Float64,Int,String,Nothing} = nothing
  ytype::Union{String,Nothing} = nothing
  # z::Union{Vector,Matrix,Nothing} = nothing
  z::Union{Vector,Nothing} = nothing
  zauto::Union{Bool,Nothing} = nothing
  zcalendar::Union{String,Nothing} = nothing
  zhoverformat::Union{String,Nothing} = nothing
  zmax::Union{Int,Nothing} = nothing
  zmid::Union{Int,Nothing} = nothing
  zmin::Union{Int,Nothing} = nothing
  zsmooth::Union{String,Nothing} = nothing
end

const Trace = PlotData

# =============

# Reference: https://github.com/plotly/plotly.js/blob/master/src/plot_api/plot_config.js?package=plotly&version=3.6.0

Base.@kwdef mutable struct PlotConfig
  responsive::Union{Bool,Nothing} = nothing # default: false
  editable::Union{Bool,Nothing} = nothing # default: false
  scrollzoom::Union{Bool,String,Nothing} = nothing  # ['cartesian', 'gl3d', 'geo', 'mapbox'], [true, false]; default: gl3d+geo+mapbox'
  staticplot::Union{Bool,Nothing} = nothing # default: false
  displaymodebar::Union{Bool,String,Nothing} = nothing # ['hover', true, false], default: "hover"
  displaylogo::Union{Bool,Nothing} = false # default: true
  toimage_format::Union{String,Nothing} = nothing # one of ["png", "svg", "jpeg", "webp"]
  toimage_filename::Union{String,Nothing} = nothing # "newplot"
  toimage_height::Union{Int,Nothing} = nothing # 500
  toimage_width::Union{Int,Nothing} = nothing # 700
  toimage_scale::Union{Int,Float64,Nothing} = nothing # 1
end

function Base.show(io::IO, pc::PlotConfig)
  output = "configuration: \n"
  for f in fieldnames(typeof(pc))
    prop = getproperty(pc, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end

function Base.Dict(pc::PlotConfig)
  trace = Dict{Symbol, Any}()

  if (pc.toimage_format in ["png", "svg", "jpeg", "webp"])
    d = Dict{Symbol, Any}(:format => pc.toimage_format)
    d[:filename] = (pc.toimage_filename === nothing) ? "newplot" : pc.toimage_filename
    d[:height] = (pc.toimage_height === nothing) ? 500 : pc.toimage_height
    d[:width] = (pc.toimage_width === nothing) ? 700 : pc.toimage_width
    d[:scale] = (pc.toimage_scale === nothing) ? 1 : pc.toimage_scale
    trace[:toImageButtonOptions] = d
  end

  optionals!(trace, pc, [:responsive, :editable, :scrollzoom, :staticplot, :displaymodebar, :displaylogo])
end

function optionals!(d::Dict, pc::PlotConfig, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(pc, o) !== nothing
      d[o] = getproperty(pc, o)
    end
  end

  d
end

function Stipple.render(pc::PlotConfig, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pc)
end

# =============

function attributes(kwargs::Union{Vector{<:Pair}, Base.Iterators.Pairs, Dict},
                    mappings::Dict{String,String} = Dict{String,String}())::NamedTuple

  attrs = Pair{Symbol, Any}[]
  mapped = false

  for (k,v) in kwargs
    v === nothing && continue
    mapped = false

    if haskey(mappings, string(k))
      k = mappings[string(k)]
    end

    attr_key = string((isa(v, Symbol) && ! startswith(string(k), ":") &&
      ! ( startswith(string(k), "v-") || startswith(string(k), "v" * Genie.config.html_parser_char_dash) ) ? ":" : ""), "$k") |> Symbol
    attr_val = isa(v, Symbol) && ! startswith(string(k), ":") ? Stipple.julia_to_vue(v) : v

    push!(attrs, attr_key => attr_val)
  end

  NamedTuple(attrs)
end

function plot(data::Union{Symbol,AbstractString};
  layout::Union{Symbol,AbstractString,LayoutType} = Charts.PlotLayout(),
  config::Union{Symbol,AbstractString,Nothing,ConfigType} = nothing, configtype = Charts.PlotConfig,
  args...) :: String  where {LayoutType, ConfigType}

  plotconfig = render(isnothing(config) ? configtype() : config)
  plotconfig isa Union{Symbol,AbstractString,Nothing} || (configtype = typeof(plotconfig))

  plotlayout = if layout isa AbstractString
    Symbol(layout)
  elseif layout isa Symbol
    layout
  else
    render(layout)
  end
  k = plotconfig isa AbstractDict ? keys(plotconfig) : collect(fieldnames(configtype))
  v = if plotconfig isa Union{AbstractString, Symbol}
      Symbol.(string.(plotconfig, ".", k))
  else
      v = plotconfig isa AbstractDict ? collect(values(plotconfig)) : Any[getfield(plotconfig, f) for f in k]
      # force display of false value
      n = findfirst(:displaylogo .== k)
      isnothing(n) || v[n] == true || (v[n] = js"false")
      v
  end
  plotly(; attributes([:data => Symbol(data), :layout => plotlayout, args..., (k .=> v)...])...)
end

# =============

function Base.show(io::IO, pd::PlotData)
  output = "$(pd.plot): \n"
  for f in fieldnames(typeof(pd))
    prop = getproperty(pd, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(io, output)
end


#===#

function Base.Dict(pd::PlotData)
  trace = Dict{Symbol,Any}(
    :type => pd.plot
  )

  if pd.textfont !== nothing
    trace[:textfont] = Dict(
      :family => pd.textfont.family,
      :size => pd.textfont.size,
      :color => pd.textfont.color
    )
  end

  if pd.insidetextfont !== nothing
    trace[:insidetextfont] = Dict(
      :family => pd.insidetextfont.family,
      :size => pd.insidetextfont.size,
      :color => pd.insidetextfont.color
    )
  end

  if pd.outsidetextfont !== nothing
    trace[:outsidetextfont] = Dict(
      :family => pd.outsidetextfont.family,
      :size => pd.outsidetextfont.size,
      :color => pd.outsidetextfont.color
    )
  end

  (pd.line !== nothing) && (trace[:line] = Dict(pd.line))
  (pd.marker !== nothing) && (trace[:marker] = Dict(pd.marker))
  (pd.error_x !== nothing) && (trace[:error_x] = Dict(pd.error_x))
  (pd.error_y !== nothing) && (trace[:error_y] = Dict(pd.error_y))
  (pd.error_z !== nothing) && (trace[:error_z] = Dict(pd.error_z))
  (pd.colorbar !== nothing) && (trace[:colorbar] = Dict(pd.colorbar))

  optionals!(trace, pd, [:align, :alignmentgroup, :alphahull, :anchor, :aspectratio, :autobinx, :autobiny,
                        :autocolorscale, :autocontour, :automargin,
                        :bandwidth, :base, :baseratio, :bingroup, :box, :boxmean, :boxpoints,
                        :cauto, :cells, :cliponaxis, :close, :color, :cmax, :cmid, :cmin,
                        :coloraxis, :colorscale, :columnorder, :columnwidth,
                        :connectgaps, :connector, :constraintext, :contour, :contours, :cumulative, :customdata,
                        :decreasing, :delta, :delaunayaxis, :direction, :dlabel, :domain, :dx, :dy,
                        :facecolor, :fill, :fillcolor, :flatshading,
                        :gauge, :groupnorm,
                        :header, :hidesurface, :high, :histfunc, :histnorm,
                        :hole, :hovertext, :hoverinfo, :hovertemplate, :hoverlabel, :hoveron, :hoverongaps,
                        :i, :intensity, :intensitymode, :ids, :increasing, :insidetextanchor, :insidetextorientation, :isomax, :isomin,
                        :j, :jitter, :k,
                        :labels, :label0, :legendgroup, :lighting, :lightposition, :low, :lowerfence,
                        :maxdisplayed, :meanline, :measure, :median, :meta,
                        :mode,
                        :name, :nbinsx, :nbinsy, :ncontours, :notched, :notchwidth, :notchspan, :number,
                        :offset, :offsetgroup, :opacity, :opacityscale, :colormodel, :open, :orientation,
                        :points, :pointpos, :projection, :pull,
                        :q1, :q3, :quartilemethod,
                        :reversescale, :rotation,
                        :scalegroup, :scalemode, :scene, :sd,
                        :selected, :selectedpoints, :showlegend,
                        :showscale, :side, :sizemode, :sizeref, :slices, :sort, :source, :spaceframe, :span, :spanmode,
                        :stackgaps, :stackgroup, :starts, :surface, :surfaceaxis, :surfacecolor,
                        :text, :textangle, :textinfo,
                        :textposition, :texttemplate, :tickwidth, :totals, :transpose,
                        :uirevision, :upperfence, :unselected,
                        :values, :vertexcolor, :visible,
                        :whiskerwidth, :width,
                        :x, :x0, :xaxis, :xbingroup, :xbins, :xcalendar, :xgap, :xperiod, :xperiodalignment, :xperiod0, :xtype,
                        :y, :y0, :yaxis, :ybingroup, :ybins, :ycalendar, :ygap, :yperiod, :yperiodalignment, :yperiod0, :ytype,
                        :z, :zauto, :zcalendar, :zhoverformat, :zmax, :zmid, :zmin, :zsmooth])
end

function optionals!(d::Dict, pd::PlotData, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(pd, o) !== nothing
      d[o] = getproperty(pd, o)
    end
  end

  d
end

function Stipple.render(pd::PlotData, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(pd)]
end

function Stipple.render(pdv::Vector{PlotData}, fieldname::Union{Symbol,Nothing} = nothing)
  [Dict(pd) for pd in pdv]
end

function Stipple.render(pdvv::Vector{Vector{PlotData}}, fieldname::Union{Symbol,Nothing} = nothing)
  [[Dict(pd) for pd in pdv] for pdv in pdvv]
end

#===#

function Base.Dict(pl::PlotLayout, fieldname::Union{Symbol,Nothing} = nothing)
  layout = Dict{Symbol, Any}()

  if pl.font !== nothing
    layout[:font] = Dict{Symbol, Any}(
      :family => pl.font.family,
      :size => pl.font.size,
      :color => pl.font.color
    )
  end

  d1 = Dict{Symbol, Any}()
  (pl.margin_l !== nothing) && (d1[:l] = pl.margin_l)
  (pl.margin_r !== nothing) && (d1[:r] = pl.margin_r)
  (pl.margin_t !== nothing) && (d1[:t] = pl.margin_t)
  (pl.margin_b !== nothing) && (d1[:b] = pl.margin_b)
  (pl.margin_pad !== nothing) && (d1[:pad] = pl.margin_pad)
  (pl.margin_autoexpand !== nothing) && (d1[:autoexpand] = pl.margin_autoexpand)
  (length(d1) > 0) && (layout[:margin] = d1)

  d2 = Dict{Symbol, Any}()
  (pl.uniformtext_mode !== nothing) && (d2[:mode] = pl.uniformtext_mode)
  (pl.uniformtext_minsize !== nothing) && (d2[:minsize] = pl.uniformtext_minsize)
  (length(d2) > 0) && (layout[:uniformtext] = d2)

  (pl.title !== nothing) && (layout[:title] = Dict(pl.title))
  (pl.legend !== nothing) && (layout[:legend] = Dict(pl.legend))
  (pl.annotations !== nothing) && (layout[:annotations] = Dict.(pl.annotations))
  (pl.grid !== nothing) && (layout[:grid] = Dict(pl.grid))

  optionals!(layout, pl, [ :showlegend, :autosize, :separators, :paper_bgcolor, :plot_bgcolor,
    :width, :height, :barmode, :barnorm, :bargap, :bargroupgap
  ])


  if pl.xaxis !== nothing
    for d in Dict.(pl.xaxis)
      merge!(layout, d)
    end
  end

  if pl.yaxis !== nothing
    for d in Dict.(pl.yaxis)
      merge!(layout, d)
    end
  end

  layout
end

function optionals!(d::Dict, pl::PlotLayout, opts::Vector{Symbol}) :: Dict
  for o in opts
    if getproperty(pl, o) !== nothing
      d[o] = getproperty(pl, o)
    end
  end

  d
end

function Stipple.render(pl::PlotLayout, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pl)
end

function Stipple.render(pl::Vector{PlotLayout}, fieldname::Union{Symbol,Nothing} = nothing)
  Dict.(pl)
end

Base.print(io::IO, a::Union{PlotLayout, PlotConfig}) = print(io, Stipple.json(a))

# #===#

end

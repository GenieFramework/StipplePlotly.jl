module Charts

using Genie, Stipple, StipplePlotly
using Stipple.Reexport, Stipple.ParsingTools

import StipplePlotly._symbol_dict
import DataFrames

include("Layouts.jl")
using .Layouts

@reexport using PlotlyBase
@reexport using .Layouts:PlotLayoutMapbox, MCenter, GeoProjection, PRotation,
                        PlotLayoutGeo, PlotLayout, PlotAnnotation, ErrorBar, Font,
                        ColorBar, PlotLayoutGrid, PlotLayoutAxis, PlotLayoutTitle, PlotLayoutLegend

using .Layouts:optionals!

import Genie.Renderer.Html: HTMLString, normal_element, register_normal_element

export PlotLayout, PlotData, PlotAnnotation, Trace, plot, ErrorBar, Font, ColorBar, watchplot, watchplots
export PlotLayoutGrid, PlotLayoutAxis
export PlotConfig, PlotLayoutTitle, PlotLayoutLegend, PlotlyLine, PlotDataMarker
export PlotlyEvents, PlotWithEvents, PBPlotWithEvents, PlotWithEventsReadOnly, PBPlotWithEventsReadOnly
export plotdata

const PLOT_TYPE_LINE = "scatter"
const PLOT_TYPE_SCATTER = "scatter"
const PLOT_TYPE_SCATTERGL = "scattergl"
const PLOT_TYPE_SCATTERGEO = "scattergeo"
const PLOT_TYPE_SCATTERMAPBOX = "scattermapbox"
const PLOT_TYPE_BAR = "bar"
const PLOT_TYPE_PIE = "pie"
const PLOT_TYPE_HEATMAP = "heatmap"
const PLOT_TYPE_HEATMAPGL = "heatmapgl"
const PLOT_TYPE_IMAGE = "image"
const PLOT_TYPE_CONTOUR = "contour"
const PLOT_TYPE_CHOROPLETH = "choropleth"
# const PLOT_TYPE_CHOROPLETHMAPBOX = "choroplethmapbox"
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

kebapcase(s::String) = lowercase(replace(s, r"([A-Z])" => s"-\1"))
kebapcase(s::Symbol) = Symbol(kebapcase(String(s)))

register_normal_element("plotly", context = @__MODULE__)

"""
    function plotly(p::Symbol; layout = Symbol(p, ".layout"), config = Symbol(p, ".config"), configtype = DEFAULT_CONFIG_TYPE[], kwargs...)

This is a convenience function for rendering a PlotlyBase.Plot or a struct with fields data, layout and config
# Example
```julia
julia> plotly(:plot)
"<plotly :data=\"plot.data\" :layout=\"plot.layout\" :config=\"plot.config\"></plotly>"
```
For multiple plots with a common config or layout a typical usage is
```julia
julia> plotly(:plot, config = :config)
"<plotly :data=\"plot.data\" :layout=\"plot.layout\" :config=\"config\"></plotly>"
```

"""
function plotly(p::Symbol, args...; layout = Symbol(p, ".layout"), config = Symbol(p, ".config"), configtype = PlotlyBase.PlotConfig, kwargs...)
  plot(p, args...; layout, config, configtype, kwargs...)
end

"""
    function watchplot(selector::AbstractString)

Generates a js script that forwards plotly events of a DOM element to its respective model fields,
e.g. `plot_selected`, `plot_hover`, etc...
If no prefix is given, it is taken from the class list which needs to contain at least one entry `'sync_[prefix]'`, e.g `sync_plot`.
This function acts on plots that are already present in the UI. It is meant for the rare case of
plot-specific event-binding, e.g. in a backend listener.

The normal way forwarding plot events is to call `watchplots()` in `js_mounted()`.
"""
function watchplot(selector::AbstractString)
  "window.watchPlot(document.querySelector('$selector'), this, $prefix)\n"
end

function watchplot(selector::AbstractString, prefix)
  "window.watchGraphDiv(document.querySelector('$selector'), this, $prefix)\n"
end

"""
    function watchplot(id::Symbol)

Call watchplot with an 'id' instead of a CSS selector string.
"""
function watchplot(id::Symbol)
  "window.watchPlot(document.getElementById('$id'), this)\n"
end

"""
    function watchplots(model = "this"; observe = true, parentSelector::Union{Nothing, AbstractString} = nothing)

Generates a js script that forwards plotly events, e.g. point selection or hovering, to their respective model fields.
`model` can be a string, a model or a model type. Dynamically added plots are also covered.

The recommended usage is to called it on the mounted event. In that case the model argument can be omitted.
`Stipple.js_mounted(::Example) = watchplots()`

Plots to be covered by this approach must contain at least one class entry `'sync_[prefix]'`, e.g `sync_plot`.
You can use the keyword arguments `syncevents` or `syncprefix` of `plot()` to generate the UI plot nodes:
```
julia> plot("plot.data", syncevents = true)
"<plotly :data=\"plot.data\" :layout=\"{}\" class=\"sync_plot\"></plotly>"

julia> plot("plot.data", syncprefix = "plot1")
"<plotly :data=\"plot.data\" :layout=\"{}\" class=\"sync_plot1\"></plotly>"
```

# Example
```julia
@reactive! mutable struct Example <: ReactiveModel
    plot::R{Plot} = Plot()
    plot_selected::R{Dict{String, Any}} = Dict{String, Any}()
    plot_hover::R{Dict{String, Any}} = Dict{String, Any}()
    plot1_selected::R{Dict{String, Any}} = Dict{String, Any}()
end

function ui(model::Example)
    page(model, class = "container",
    row(cell(class = "st-module", id = "plotcontainer", [
      # syncs plotly events to field plot_selected, plot_hover, etc...
      plotly(:plot, syncevents = true),

      # syncs plotly events to field plot1_selected, plot1_hover, etc...
      plotly(:plot, syncprefix = "plot1", @iif(length(model.plot.data) > 0)),
    ])))
end

Stipple.js_mounted(::Example) = watchplots()

function handlers(model)
  on(model.isready) do isready
      isready || return
      push!(model)
  end

  on(model.plot_selected) do data
      haskey(data, "points") && @info "Selection: \$(getindex.(data["points"], "pointIndex"))"
  end

  return model
end
```
"""
function watchplots(model::Union{Symbol, AbstractString} = "this"; observe = true, parentSelector::Union{Nothing, AbstractString} = nothing)
  """watchPlots($model, $observe, $(isnothing(parentSelector) ? "''" : parentSelector))"""
end

function watchplots(model::Union{M, Type{M}}; observe = true,
                    parentSelector::Union{Nothing, AbstractString} = nothing) where M <: ReactiveModel
  watchplots(vm(model); observe, parentSelector)
end

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

function Stipple.render(pdl::PlotlyLine, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(pdl)
end

#===#

"""
    PlotDataMarker()

----------
# Examples
----------

```
julia> marker = PlotDataMarker(
  size = [20, 30, 15, 10],
  color = [10.0, 20.0, 40.0, 50.0],
  cmin = 0.0,
  cmax = 50.0,
  colorscale = "Greens",
  colorbar = ColorBar(title_text = "Some rate", ticksuffix = "%", showticksuffix = "last"),
  line = PlotlyLine(color = "black")
)
```

-----------
# Properties
-----------
* `autocolorscale::Bool` - Determines whether the colorscale is a default palette (`autocolorscale: true`) or the palette determined by `marker.colorscale`. Has an effect only if in `marker.color` is set to a numerical array. In case `colorscale` is unspecified or `autocolorscale` is true, the default palette will be chosen according to whether numbers in the `color` array are all positive, all negative or mixed. Default: `true`
* `cauto::Bool` - Determines whether or not the color domain is computed with respect to the input data (here in `marker.color`) or the bounds set in `marker.cmin` and `marker.cmax` Has an effect only if in `marker.color` is set to a numerical array. Defaults to `false` when `marker.cmin` and `marker.cmax` are set by the user.
* `cmax::Float64,Nothing` - Sets the upper bound of the color domain. Has an effect only if in `marker.color` is set to a numerical array. Value should have the same units as in `marker.color` and if set, `marker.cmin` must be set as well.
* `cmin::Float64` - Sets the mid-point of the color domain by scaling `marker.cmin` and/or `marker.cmax` to be equidistant to this point. Has an effect only if in `marker.color` is set to a numerical array. Value should have the same units as in `marker.color`. Has no effect when `marker.cauto` is `false`.
* `color::Union{String,Vector{Float64}}` - Sets the marker color. It accepts either a specific color or an array of numbers that are mapped to the colorscale relative to the max and min values of the array or relative to `marker.cmin` and `marker.cmax` if set.
* `coloraxis::String` - Sets a reference to a shared color axis. References to these shared color axes are "coloraxis", "coloraxis2", "coloraxis3", etc. Settings for these shared color axes are set in the layout, under `layout.coloraxis`, `layout.coloraxis2`, etc. Note that multiple color scales can be linked to the same color axis.
* `colorbar::ColorBar` - ColorBar object contains multiple keys. Check correspoing API docs for each key. ex. `ColorBar(title_text = "Some rate", ticksuffix = "%", showticksuffix = "last")`
* `colorscale::Union{Matrix,String}` - Sets the colorscale. Has an effect only if in `marker.color` is set to a numerical array. The colorscale must be an array containing arrays mapping a normalized value to an rgb, rgba, hex, hsl, hsv, or named color string. At minimum, a mapping for the lowest (0) and highest (1) values are required. For example, `[[0, 'rgb(0,0,255)'], [1, 'rgb(255,0,0)']]`. To control the bounds of the colorscale in color space, use `marker.cmin` and `marker.cmax`. Alternatively, `colorscale` may be a palette name string of the following list: Blackbody,Bluered,Blues,Cividis,Earth,Electric,Greens,Greys,Hot,Jet,Picnic,Portland,Rainbow,RdBu,Reds,Viridis,YlGnBu,YlOrRd.
* `line::PlotlyLine` - object contains multiple keys. Check correspoing API docs for each key. ex. `PlotlyLine(color = "black", width = 2)`
* `opacity::Union{Float64, Vector{Float64}}` - Sets the marker opacity. Type. number or array of numbers between or equal to 0 and 1
* `reversescale::Bool` - Reverses the color mapping if true. Has an effect only if in `marker.color` is set to a numerical array. If true, `marker.cmin` will correspond to the last color in the array and `marker.cmax` will correspond to the first color.
* `showscale::Bool` - Determines whether or not a colorbar is displayed for this trace. Has an effect only if in `marker.color` is set to a numerical array.
* `size::Union{Int,Vector{Int}}` - Sets the marker size (in px).
* `sizemin::Float64` - Has an effect only if `marker.size` is set to a numerical array. Sets the minimum size (in px) of the rendered marker points.
* `sizemode::String` - Has an effect only if `marker.size` is set to a numerical array. Sets the rule for which the data in `size` is converted to pixels.
* `sizeref::Float64` - Has an effect only if `marker.size` is set to a numerical array. Sets the scale factor used to determine the rendered size of marker points. Use with `sizemin` and `sizemode`.
* `symbol::Union{String, Vector{String}}` - Sets the marker symbol type. Adding 100 is equivalent to appending "-open" to a symbol name. Adding 200 is equivalent to appending "-dot" to a symbol name. Adding 300 is equivalent to appending "-open-dot" or "dot-open" to a symbol name. Ex.  Default: "circle"

"""
Base.@kwdef mutable struct PlotDataMarker
  autocolorscale::Union{Bool,Nothing} = nothing
  cauto::Union{Bool,Nothing} = nothing
  cmax::Union{Float64,Nothing} = nothing
  cmid::Union{Float64,Nothing} = nothing
  cmin::Union{Float64,Nothing} = nothing
  # TODO: gradient
  color::Union{String,Vector{Float64},Nothing} = nothing # color= [2.34, 4.3, 34.5, 52.2]
  # Specific for Pie charts:
  colors::Union{Vector{String},Nothing} = nothing
  coloraxis::Union{String,Nothing} = nothing
  colorbar::Union{ColorBar,Nothing} = nothing
  colorscale::Union{Matrix,String,Nothing} = nothing
  line::Union{PlotlyLine,Nothing} = nothing
  maxdisplayed::Union{Int,Nothing} = nothing
  opacity::Union{Float64,Vector{Float64},Nothing} = nothing
  reversescale::Union{Bool,Nothing} = nothing
  showscale::Union{Bool,Nothing} = nothing
  size::Union{Int,Vector{Int},Nothing} = nothing
  sizemin::Union{Float64,Nothing} = nothing
  sizemode::Union{String,Nothing} = nothing
  sizeref::Union{Float64,Nothing} = nothing
  symbol::Union{String,Vector{String},Nothing} = nothing
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

  optionals!(trace, pdm, [
    :autocolorscale, :cauto, :cmax, :cmid, :cmin, :color, :colors, :coloraxis,
    :colorbar, :colorscale, :line, :maxdisplayed, :opacity, :reversescale,
    :showscale, :size, :sizemin, :sizemode, :sizeref, :symbol])
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
  geojson::Union{String,Nothing} = nothing
  groupnorm::Union{String,Nothing} = nothing
  header::Union{Dict,Nothing} = nothing
  hidesurface::Union{Bool,Nothing} = nothing
  high::Union{Vector,Nothing} = nothing
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
  lat::Union{Vector,Nothing} = nothing
  legendgroup::Union{String,Nothing} = nothing
  lighting::Union{Dict,Nothing} = nothing
  lightposition::Union{Dict,Nothing} = nothing
  line::Union{Dict,PlotlyLine,Nothing} = nothing
  locations::Union{Vector,Nothing} = nothing
  locationmode::Union{String,Nothing} = nothing
  lon::Union{Vector,Nothing} = nothing
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
  selectedpoints::Union{Vector{<:Integer},Float64,Int,String,Nothing} = nothing
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

const CONFIG_MAPPINGS = Dict(
  :scrollzoom => :scrollZoom,
  :staticplot => :staticPlot,
  :displaymodebar => :displayModeBar,
  :showlink => :showLink,
)

const CONGIG_DEFAULTS = Dict{Symbol, Any}(
  :scrollZoom => false,
  :staticPlot => false,
  :showLink => false,
  :editable => false,
  :responsive => true,
  :displayModeBar => true,
  :modeBarButtonsToRemove => String[],
  :modeBarButtonsToAdd => String[],
  :toImageButtonOptions => Dict(
    :format => "png",
    :filename => "newplot",
    :height => 500,
    :width => 700,
    :scale => 1,
  )
)

const PARSER_MAPPINGS = Dict(
  :type => :plot
)

const Trace = PlotData


function plotdata(data::DataFrames.DataFrame, xfeature::Symbol, yfeature::Symbol; groupfeature::Symbol, text::Union{Vector{String}, Nothing} = nothing,
                  mode = "markers", plottype = StipplePlotly.Charts.PLOT_TYPE_SCATTER, kwargs...) :: Vector{PlotData}
  plot_collection = Vector{PlotData}()

  for gf in Array(data[:, groupfeature]) |> unique!
    x_feature_collection, y_feature_collection = Vector{Float64}(), Vector{Float64}()
    text_collection = Vector{String}()
    group_indices = data[!, groupfeature] .== gf
    grouptext = text isa Vector{String} ? text[group_indices] : nothing
    for (index,r) in enumerate(eachrow(data[group_indices, :]))
      push!(x_feature_collection, (r[xfeature]))
      push!(y_feature_collection, (r[yfeature]))
      text isa Vector{String} ? push!(text_collection, (grouptext[index])) : nothing
    end
    plot = PlotData(;
            x = x_feature_collection,
            y = y_feature_collection,
            mode = mode,
            name = string(gf),
            plot = plottype,
            text = isnothing(text) ? text : text_collection,
            kwargs...)
    push!(plot_collection, plot)
  end

  plot_collection
end


function Stipple.stipple_parse(::Type{PlotData}, d::Dict{String, Any})
  sd = _symbol_dict(d)
  sd[:text] isa String || (sd[:text] = Vector{String}(sd[:text]))
  sd[:selectedpoints] = [sd[:selectedpoints]...]
  sd = Dict{Symbol, Any}(replace(collect(keys(sd)), PARSER_MAPPINGS...) .=> values(sd))

  PlotData(;sd...)
end

function Stipple.stipple_parse(T::Type{Vector{<:PlotData}}, d::Vector)
  [stipple_parse(T, x) for x in d]
end

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
                        :z, :zauto, :zcalendar, :zhoverformat, :zmax, :zmid, :zmin, :zsmooth,
                        :geojson, :lat, :locations, :lon, :locationmode])
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

  Dict{Symbol, Any}(replace(collect(keys(trace)), CONFIG_MAPPINGS...) .=> values(trace))
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

function jsonrender(x)
  replace(Stipple.json(render(x)), "'" => raw"\'", '"' => ''')
end

function plot(data::Union{Symbol,AbstractString}, args...;
  layout::Union{Symbol,AbstractString,LayoutType} = Charts.PlotLayout(),
  config::Union{Symbol,AbstractString,Nothing,ConfigType} = nothing, configtype = Charts.PlotConfig,
  syncevents::Bool = false, syncprefix = "", class = "", kwargs...) :: String  where {LayoutType, ConfigType}

  plotlayout = if layout isa AbstractString
    Symbol(layout)
  elseif layout isa Symbol
    layout
  else
    Symbol(jsonrender(layout))
  end

  plotconfig = render(isnothing(config) ? configtype() : config)
  plotconfig isa Union{Symbol,AbstractString,Nothing} || (configtype = typeof(plotconfig))

  k = if plotconfig isa AbstractDict
    collect(keys(plotconfig))
  else
    kk = collect(fieldnames(configtype))
    if configtype == StipplePlotly.PlotConfig
      # remove fields with underscore and add respective rendering field (StipplePlotly)
      kk = kk[.! occursin.("_", string.(kk))]
      push!(kk, :toImageButtonOptions)
    end
    kk
  end
  v = if plotconfig isa Union{AbstractString, Symbol}
    config_defaults = jsonrender.(get.(Ref(CONGIG_DEFAULTS), replace(k, CONFIG_MAPPINGS...), ""))
    v = Symbol.("typeof ", plotconfig, ".", string.(k), " == 'undefined' ? " , config_defaults, " : ", plotconfig, ".", string.(k))
  else
    v = plotconfig isa AbstractDict ? collect(values(plotconfig)) : Any[getfield(plotconfig, f) for f in k]
    # force display of false value for displaylogo
    n = findfirst(:displaylogo .== k)
    isnothing(n) || v[n] != false || (v[n] = js"false")
    v = Symbol.(jsonrender.(v))
  end
  pp = kebapcase.(replace(k, CONFIG_MAPPINGS...)) .=> v
  plotconfig isa Union{Symbol,AbstractString} || filter!(x -> x[2] != :null, pp)
  if syncevents || ! isempty(syncprefix)
    if isempty(syncprefix)
      datastr = String(data)
      syncprefix = endswith(datastr, "data") && length(datastr) > 4 ? datastr[1:end-4] : datastr
      syncprefix = split(syncprefix, ['_', '.'])[1]
    end
    class = isempty(class) ? "sync_$syncprefix" : "sync_$syncprefix $class"
  end
  sync = Pair{Symbol, String}[]
  isempty(class) || push!(sync, :class => class)

  plotly("", args...; attributes([:data => Symbol(data), :layout => plotlayout, kwargs..., pp..., sync...])...)
end

Base.print(io::IO, a::Union{PlotLayout, PlotConfig}) = print(io, Stipple.json(a))

# =============

Base.print(io::IO, a::Union{PlotlyBase.PlotConfig}) = print(io, Stipple.json(a))
StructTypes.StructType(::Type{<:PlotlyBase.HasFields}) = JSON3.RawType()
StructTypes.StructType(::Type{PlotlyBase.PlotConfig}) = JSON3.RawType()
JSON3.rawbytes(x::Union{PlotlyBase.HasFields,PlotlyBase.PlotConfig}) = codeunits(PlotlyBase.JSON.json(x))

function Base.Dict(p::PlotlyBase.Plot)
  Dict(
    :data => p.data,
    :layout => p.layout,
    :frames => p.frames,
    :config => p.config
  )
end

const PlotlyEvent = Dict{String, Any}

Base.@kwdef struct PBPlotWithEvents
  var""::R{PlotlyBase.Plot} = PlotlyBase.Plot()
  _selected::R{PlotlyEvent} = PlotlyEvent()
  _hover::R{PlotlyEvent} = PlotlyEvent()
  _click::R{PlotlyEvent} = PlotlyEvent()
  _relayout::R{PlotlyEvent} = PlotlyEvent()
end

Base.@kwdef struct PBPlotWithEventsReadOnly
  var""::R{PlotlyBase.Plot} = PlotlyBase.Plot(), READONLY
  _selected::R{PlotlyEvent} = PlotlyEvent()
  _hover::R{PlotlyEvent} = PlotlyEvent()
  _click::R{PlotlyEvent} = PlotlyEvent()
  _relayout::R{PlotlyEvent} = PlotlyEvent()
end

function PlotlyBase.Plot(d::AbstractDict)
    sd = symbol_dict(d)
    data = haskey(sd, :data) && ! isempty(sd[:data]) ? PlotlyBase.GenericTrace.(sd[:data]) : PlotlyBase.GenericTrace[]
    layout = haskey(sd, :layout) ? PlotlyBase.Layout(sd[:layout]) : PlotlyBase.Layout()
    frames = haskey(sd, :frames) && ! isempty(sd[:frames]) ? PlotlyBase.PlotlyFrame.(sd[:frames]) : PlotlyBase.PlotlyFrame[]
    config = haskey(sd, :config) ? PlotlyBase.PlotConfig(; sd[:config]...) : PlotlyBase.PlotConfig()
  
    PlotlyBase.Plot(data, layout, frames; config)
end
  
Stipple.stipple_parse(::Type{PlotlyBase.Plot}, d::AbstractDict) = PlotlyBase.Plot(d)

Base.@kwdef struct PlotlyEvents
  _selected::R{PlotlyEvent} = PlotlyEvent()
  _hover::R{PlotlyEvent} = PlotlyEvent()
  _click::R{PlotlyEvent} = PlotlyEvent()
  _relayout::R{PlotlyEvent} = PlotlyEvent()
end

Base.@kwdef struct PlotWithEvents
  _data::R{Vector{PlotData}} = PlotData[]
  _layout::R{PlotLayout} = PlotLayout()
  _selected::R{PlotlyEvent} = PlotlyEvent()
  _hover::R{PlotlyEvent} = PlotlyEvent()
  _click::R{PlotlyEvent} = PlotlyEvent()
  _relayout::R{PlotlyEvent} = PlotlyEvent()
end

Base.@kwdef struct PlotWithEventsReadOnly
  _data::R{Vector{PlotData}} = PlotData[], READONLY
  _layout::R{PlotLayout} = PlotLayout()
  _selected::R{PlotlyEvent} = PlotlyEvent()
  _hover::R{PlotlyEvent} = PlotlyEvent()
  _click::R{PlotlyEvent} = PlotlyEvent()
  _relayout::R{PlotlyEvent} = PlotlyEvent()
end

# #===#

# Parsers

function Base.convert(::Type{PlotData}, d::Dict{String, Any})
  sd = symbol_dict(d)
  sd[:text] isa String || (sd[:text] = Vector{String}(sd[:text]))
  sd[:selectedpoints] = [sd[:selectedpoints]...]
  sd = Dict{Symbol, Any}(replace(collect(keys(sd)), PARSER_MAPPINGS...) .=> values(sd))

  typify(PlotData, sd)
end

function Base.convert(::Type{T}, d::Dict{Symbol, Any}) where T <: Union{Font, PlotLayout, PlotLayoutAxis, PlotLayoutGeo, PlotLayoutGrid, PlotLayoutLegend, PlotLayoutMapbox, PlotLayoutTitle}
  typify(T, d)
end

function Base.convert(::Type{T}, d::Dict{String, Any}) where T <: Union{Font, PlotLayoutAxis, PlotLayoutGeo, PlotLayoutGrid, PlotLayoutLegend, PlotLayoutMapbox, PlotLayoutTitle}
  convert(T, symbol_dict(d))
end

function Base.convert(::Type{PlotLayout}, d::Dict{String, Any})
  d = symbol_dict(d)

  haskey(d, :title) && (d[:title] = d[:title] isa String ? PlotLayoutTitle(; text = d[a][:title]) : PlotLayoutTitle(; d[a][:title]...))
  haskey(d, :xaxis) && (d[:xaxis] = [convert(PlotLayoutAxis, d[:xaxis])])

  kk = collect(keys(d))

  axes = kk[startswith.(string.(kk), r"xaxis\d")]
  for a in axes
      push!(get!(Dict{Symbol, Any}, d, :xaxis), PlotLayoutAxis(; d[a]...))
      delete!(d, a)
  end

  axes = kk[startswith.(string.(kk), r"yaxis\d")]
  for a in axes
      push!(get!(Dict{Symbol, Any}, d, :xaxis), PlotLayoutAxis(; d[a]...))
  end

  convert(PlotLayout, d)
end

Base.convert(::Type{Vector{<:PlotData}}, dd::Vector) = PlotData[convert(PlotData, d) for d in dd]

# enhance precompilation

pl = PlotLayout(
    xaxis = [
        PlotLayoutAxis(index = 1, title = "1"),
        PlotLayoutAxis(xy = "x", index = 2, title = "2")
    ],
    margin_r = 10,
    margin_t = 20
)

d = JSON3.read(Stipple.json(render(pl)), Dict{String, Any})
convert(PlotLayout, d)

end

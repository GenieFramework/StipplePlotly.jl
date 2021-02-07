module Charts

import Genie, Stipple
import Genie.Renderer.Html: HTMLString, normal_element

using Stipple

export PlotLayout, PlotData, Trace, plot

const DEFAULT_WRAPPER = Genie.Renderer.Html.template

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


Genie.Renderer.Html.register_normal_element("plotly", context = @__MODULE__)

Base.@kwdef mutable struct Font
  family::String = "\"Open Sans\", verdana, arial, sans-serif"
  size::Union{Int,Float64} = 12
  color::String = "#444"
end

Base.@kwdef mutable struct PlotLayout
  title_text::String = ""
  title_font::Font = Font()
  title_xref::String = LAYOUT_TITLE_REF_CONTAINER
  title_yref::String = LAYOUT_TITLE_REF_CONTAINER
  title_x::Union{Float64,String} = 0.5
  title_y::Union{Float64,String} = LAYOUT_AUTO
  title_xanchor::String = LAYOUT_AUTO
  title_yanchor::String = LAYOUT_AUTO
  title_pad_t::Int = 0
  title_pad_r::Int = 0
  title_pad_b::Int = 0
  title_pad_l::Int = 0
  showlegend::Bool = true
  legend_bgcolor::Union{String,Nothing} = nothing
  legend_bordercolor::String = "#444"
  legend_borderwidth::Int = 0
  legend_font::Font = Font()
  legend_orientation::String = LAYOUT_ORIENTATION_VERTICAL
  legend_traceorder::String = "normal"
  legend_tracegroupgap::Int = 10
  legend_itemsizing::String = LAYOUT_ITEMSIZING_TRACE
  legend_itemwidth::Int = 30
  legend_itemclick::Union{String,Bool} = LAYOUT_CLICK_TOGGLE
  legend_itemdoubleclick::Union{String,Bool} = LAYOUT_CLICK_TOGGLEOTHERS
  legend_x::Union{Int,Float64} = 1.02
  legend_xanchor::String = LAYOUT_LEFT
  legend_y::Union{Int,Float64} = 1
  legend_yanchor::String = LAYOUT_AUTO
  # TODO: legend_uirevision::Union{Int,String} = ""
  legend_valign::String = LAYOUT_MIDDLE
  legend_title_text::String = ""
  legend_title_font::Font = Font()
  legend_title_side::String = LAYOUT_LEFT
  margin_l::Int = 80
  margin_r::Int = 80
  margin_t::Int = 100
  margin_b::Int = 80
  margin_pad::Int = 0
  margin_autoexpand::Bool = true
  autosize::Bool = true
  width::Int = 700
  height::Int = 450
  font::Font = Font()
  uniformtext_mode::Union{String,Bool} = false
  uniformtext_minsize::Int = 0
  separators::String = ".,"
  paper_bgcolor::String = "#fff"
  plot_bgcolor::String = "#fff" # TODO: here

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
  grid_rows::Union{Int,Nothing} = nothing
  grid_roworder::String = "top to bottom"
  grid_columns::Union{Int,Nothing} = nothing
  # TODO: subplots
  # TODO: xaxes
  # TODO: yaxes
  grid_pattern::String = "coupled"
  grid_xgap::Float64 = 0.1
  grid_ygap::Float64 = 0.1
  grid_domain_x::Vector{Float16} = [0.0, 1.0]
  grid_domain_y::Vector{Float16} = [0.0, 1.0]
  grid_xside::String = "bottom plot"
  grid_yside::String = "left plot"
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
  barmode::String = LAYOUT_GROUP
  barnorm::String = ""
  bargap::Float64 = 0.5
  bargroupgap::Float64 = 0
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
  colorbar::Union{Dict,Nothing} = nothing
  colorscale::Union{Vector,Nothing} = nothing
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
  error_x::Union{Dict,Nothing} = nothing
  error_y::Union{Dict,Nothing} = nothing
  error_z::Union{Dict,Nothing} = nothing
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
  line::Union{Dict,Nothing} = nothing
  low::Union{Vector,Nothing} = nothing
  lowerfence::Union{Vector,Nothing} = nothing
  marker::Union{Dict,Nothing} = nothing
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

function plot(fieldname::Symbol;
              layout::Union{Symbol,PlotLayout} = PlotLayout(),
              wrap::Function = DEFAULT_WRAPPER,
              args...) :: String

  k = (Symbol(":data"), Symbol(":layout"))
  v = Any["$fieldname", layout]

  wrap() do
    plotly(; args..., NamedTuple{k}(v)...)
  end
end

function Base.show(io::IO, pd::PlotData)
  output = "$(pd.plot): \n"
  for f in fieldnames(typeof(pd))
    prop = getproperty(pd, f)
    if prop !== nothing
      output *= "$f = $prop \n"
    end
  end

  print(output)
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

  optionals!(trace, pd, [:align, :alignmentgroup, :alphahull, :anchor, :aspectratio, :autobinx, :autobiny,
                        :autocolorscale, :autocontour, :automargin,
                        :bandwidth, :base, :baseratio, :bingroup, :box, :boxmean, :boxpoints,
                        :cauto, :cells, :cliponaxis, :close, :color, :cmax, :cmid, :cmin,
                        :coloraxis, :colorbar, :colorscale, :columnorder, :columnwidth,
                        :connectgaps, :connector, :constraintext, :contour, :contours, :cumulative, :customdata,
                        :decreasing, :delta, :delaunayaxis, :direction, :dlabel, :domain, :dx, :dy,
                        :error_x, :error_y, :error_z,
                        :facecolor, :fill, :fillcolor, :flatshading,
                        :gauge, :groupnorm,
                        :header, :hidesurface, :high, :histfunc, :histnorm,
                        :hole, :hovertext, :hoverinfo, :hovertemplate, :hoverlabel, :hoveron, :hoverongaps,
                        :i, :intensity, :intensitymode, :ids, :increasing, :insidetextanchor, :insidetextorientation, :isomax, :isomin,
                        :j, :jitter, :k,
                        :labels, :label0, :legendgroup, :lighting, :lightposition, :line, :low, :lowerfence,
                        :marker, :maxdisplayed, :meanline, :measure, :median, :meta,
                        :mode,
                        :name, :nbinsx, :nbinsy, :ncontours, :notched, :notchwidth, :notchspan, :number,
                        :offset, :offsetgroup, :opacity, :opacityscale, :open, :orientation,
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

function Stipple.render(pl::PlotLayout, fieldname::Union{Symbol,Nothing} = nothing)
  layout = Dict(
    :title => Dict(
      :text => pl.title_text,
      :font => Dict(
        :family => pl.title_font.family,
        :size => pl.title_font.size,
        :color => pl.title_font.color
      ),
      :xref => pl.title_xref,
      :yref => pl.title_yref,
      :x => pl.title_x,
      :y => pl.title_y,
      :xanchor => pl.title_xanchor,
      :yanchor => pl.title_yanchor,
      :pad_t => pl.title_pad_t,
      :pad_r => pl.title_pad_r,
      :pad_b => pl.title_pad_b,
      :pad_l => pl.title_pad_l
    ),
    :showlegend => pl.showlegend,
    :legend => Dict(
      :bordercolor => pl.legend_bordercolor,
      :font => Dict(
        :family => pl.legend_font.family,
        :size => pl.legend_font.size,
        :color => pl.legend_font.color
      ),
      :orientation => pl.legend_orientation,
      :traceorder => pl.legend_traceorder,
      :tracegroupgrap => pl.legend_tracegroupgap,
      :itemsizing => pl.legend_itemsizing,
      :itemwidth => pl.legend_itemwidth,
      :itemclick => pl.legend_itemclick,
      :itemdoubleclick => pl.legend_itemdoubleclick,
      :x => pl.legend_x,
      :xanchor => pl.legend_xanchor,
      :y => pl.legend_y,
      :yanchor => pl.legend_yanchor,
      :valign => pl.legend_valign,
      :title => Dict(
        :text => pl.legend_title_text,
        :font => Dict(
          :family => pl.legend_title_font.family,
          :size => pl.legend_title_font.size,
          :color => pl.legend_title_font.color
        ),
        :side => pl.legend_title_side,
      )
    ),
    :margin => Dict(
      :l => pl.margin_l,
      :r => pl.margin_r,
      :t => pl.margin_t,
      :b => pl.margin_b,
      :pad => pl.margin_pad,
      :autoexpand => pl.margin_autoexpand
    ),
    :autosize => pl.autosize,
    :width => pl.width,
    :height => pl.height,
    :font => Dict(
      :family => pl.font.family,
      :size => pl.font.size,
      :color => pl.font.color
    ),
    :uniformtext => Dict(
      :mode => pl.uniformtext_mode,
      :minsize => pl.uniformtext_minsize
    ),
    :separators => pl.separators,
    :paper_bgcolor => pl.paper_bgcolor,
    :plot_bgcolor => pl.plot_bgcolor
  )

  pl.legend_bgcolor !== nothing && (layout[:legend_bgcolor] = pl.legend_bgcolor)

  layout
end

# #===#


end
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
* `bgcolor::String` - Sets the color of padded area.
* `bordercolor::String` - Sets the axis line color. Default = `"#444"`
* `borderwidth::Int` - Sets the width (in px) or the border enclosing this color bar. Default = `0`
* `dtick::Union{Float64,Int,String}` - Sets the step in-between ticks on this axis. Use with `tick0`. Must be a positive number, or special strings available to "log" and "date" axes. If the axis `type` is "log", then ticks are set every 10^(n"dtick) where n is the tick number. For example, to set a tick mark at 1, 10, 100, 1000, ... set dtick to 1. To set tick marks at 1, 100, 10000, ... set dtick to 2. To set tick marks at 1, 5, 25, 125, 625, 3125, ... set dtick to log_10(5), or 0.69897000433. "log" has several special values; "L<f>", where `f` is a positive number, gives ticks linearly spaced in value (but not position). For example `tick0` = 0.1, `dtick` = "L0.5" will put ticks at 0.1, 0.6, 1.1, 1.6 etc. To show powers of 10 plus small digits between, use "D1" (all digits) or "D2" (only 2 and 5). `tick0` is ignored for "D1" and "D2". If the axis `type` is "date", then you must convert the time to milliseconds. For example, to set the interval between ticks to one day, set `dtick` to 86400000.0. "date" also has special values "M<n>" gives ticks spaced by a number of months. `n` must be a positive integer. To set ticks on the 15th of every third month, set `tick0` to "2000-01-15" and `dtick` to "M3". To set ticks every 4 years, set `dtick` to "M48"
* `exponentformat::String` - Determines a formatting rule for the tick exponents. For example, consider the number 1,000,000,000. If "none", it appears as 1,000,000,000. If "e", 1e+9. If "E", 1E+9. If "power", 1x10^9 (with 9 in a super script). If "SI", 1G. If "B", 1B. Default - `"B"`
* `len::Union{Float64,Int}` - Sets the length of the color bar This measure excludes the padding of both ends. That is, the color bar length is this length minus the padding on both ends.
* `lenmode::String` - Determines whether the length of the color bar is set in units of plot "fraction" or in "pixels". Use `len` to set the value.
* `minexponent::Int` - Hide SI prefix for 10^n if |n| is below this number. This only has an effect when `tickformat` is "SI" or "B". Default - `0`
* `nticks::Int` - Specifies the maximum number of ticks for the particular axis. The actual number of ticks will be chosen automatically to be less than or equal to `nticks`. Has an effect only if `tickmode` is set to "auto". Default - `0`
* `outlinecolor::String` - Sets the axis line color.
* `outlinewidth::Int` - Sets the width (in px) of the axis line.
* `separatethousands::Bool` - If "true", even 4-digit integers are separated
* `showexponent::Bool` - If "all", all exponents are shown besides their significands. If "first", only the exponent of the first tick is shown. If "last", only the exponent of the last tick is shown. If "none", no exponents appear.
* `showticklabels::Bool` - Determines whether or not the tick labels are drawn.
* `showtickprefix::Bool` - If "all", all tick labels are displayed with a prefix. If "first", only the first tick is displayed with a prefix. If "last", only the last tick is displayed with a suffix. If "none", tick prefixes are hidden.
* `showticksuffix::Bool` - Same as `showtickprefix` but for tick suffixes.
* `thickness::Int` - Sets the thickness of the color bar This measure excludes the size of the padding, ticks and labels.
* `thicknessmode::String` - Determines whether the thickness of the color bar is set in units of plot "fraction" or in "pixels". Use `thickness` to set the value.
* `tick0::Union{Float64,Int,String}` - Sets the placement of the first tick on this axis. Use with `dtick`. If the axis `type` is "log", then you must take the log of your starting tick (e.g. to set the starting tick to 100, set the `tick0` to 2) except when `dtick`=*L<f>* (see `dtick` for more info), where the axis starts at zero. If the axis `type` is "date", it should be a date string, like date data. If the axis `type` is "category", it should be a number, using the scale where each category is assigned a serial number from zero in the order it appears.
* `tickangle::Union{String,Int,Float64}` - Sets the angle of the tick labels with respect to the horizontal. For example, a `tickangle` of -90 draws the tick labels vertically.
* `tickcolor::String` - Sets the tick color.
* `tickformat::String` - Sets the tick label formatting rule using d3 formatting mini-languages which are very similar to those in Python. For numbers, see: https://github.com/d3/d3-format/tree/v1.4.5#d3-format. And for dates see: https://github.com/d3/d3-time-format/tree/v2.2.3#locale_format. We add two items to d3's date formatter: "%h" for half of the year as a decimal number as well as "%{n}f" for fractional seconds with n digits. For example, "2016-10-13 09:15:23.456" with tickformat "%H~%M~%S.%2f" would display "09~15~23.46"
* `tickformatstops::Dict` - Array of object where each object has one or more of the keys - "dtickrange", "value", "enabled", "name", "templateitemname"
* `ticklabeloverflow::String` - Determines how we handle tick labels that would overflow either the graph div or the domain of the axis. The default value for inside tick labels is "hide past domain". In other cases the default is "hide past div".
* `ticklabelposition::String` - Determines where tick labels are drawn relative to the ticks. Left and right options are used when `orientation` is "h", top and bottom when `orientation` is "v". Type: enumerated , one of ( "outside" | "inside" | "outside top" | "inside top" | "outside left" | "inside left" | "outside right" | "inside right" | "outside bottom" | "inside bottom" ) Default: "outside"
* `ticklabelstep::String` - Sets the spacing between tick labels as compared to the spacing between ticks. A value of 1 (default) means each tick gets a label. A value of 2 means shows every 2nd label. A larger value n means only every nth tick is labeled. `tick0` determines which labels are shown. Not implemented for axes with `type` "log" or "multicategory", or when `tickmode` is "array".
* `ticklen::Int` - Sets the tick length (in px). Type: number greater than or equal to 0 | Default: 5
* `tickmode::String` - Sets the tick mode for this axis. If "auto", the number of ticks is set via `nticks`. If "linear", the placement of the ticks is determined by a starting position `tick0` and a tick step `dtick` ("linear" is the default value if `tick0` and `dtick` are provided). If "array", the placement of the ticks is set via `tickvals` and the tick text is `ticktext`. ("array" is the default value if `tickvals` is provided). Type: enumerated , one of ( "auto" | "linear" | "array" ) Default: "array"
* `tickprefix::String` - Sets a tick label prefix. Type: string Default: ""
* `ticks::String` - Determines whether ticks are drawn or not. If "", this axis' ticks are not drawn. If "outside" ("inside"), this axis' are drawn outside (inside) the axis lines. Type: enumerated , one of ( "outside" | "inside" | "" ) Default: ""
* `ticksuffix::String` - Sets a tick label suffix. Type: string Default: ""
* `ticktext::Vector{String}` - Sets the text displayed at the ticks position via `tickvals`. Only has an effect if `tickmode` is set to "array". Used with `tickvals`. Type: vector of strings
* `tickvals::Vector{Float64}` - Sets the values at which ticks on this axis appear. Only has an effect if `tickmode` is set to "array". Type: vector of numbers
* `tickwidth::Int` - Sets the tick width (in px). Type: number greater than or equal to 0 | Default: 1
* `title_font::Font` - Sets this color bar's title font.
* `title_side::String` - Determines the location of the colorbar title with respect to the color bar. Defaults to "top" when `orientation` if "v" and defaults to "right" when `orientation` if "h".
* `title_text::String` - Sets the title of the color bar.
* `x::Float64` - Sets the x position of the color bar (in plot fraction). Defaults to 1.02 when `orientation` is "v" and 0.5 when `orientation` is "h". Type: number between or equal to -2 and 3
* `xanchor::String` - Sets this color bar's horizontal position anchor. This anchor binds the `x` position to the "left", "center" or "right" of the color bar. Defaults to "left" when `orientation` is "v" and "center" when `orientation` is "h". Type: enumerated , one of ( "auto" | "left" | "center" | "right" )
* `xpad::Int` - Sets the amount of padding (in px) along the x direction. Type: number greater than or equal to 0 | Default: 0
* `y::Float64` - Sets the y position of the color bar (in plot fraction). Defaults to 0.98 when `orientation` is "v" and 0.5 when `orientation` is "h". Type: number between or equal to -2 and 3
* `yanchor::String` - Sets this color bar's vertical position anchor This anchor binds the `y` position to the "top", "middle" or "bottom" of the color bar. Defaults to "middle" when `orientation` is "v" and "bottom" when `orientation` is "h". Type: enumerated , one of ("top" | "middle" | "bottom" )
* `ypad::Int` - Sets the amount of padding (in px) along the y direction. Type: number greater than or equal to 0 | Default: 10
"""
Base.@kwdef mutable struct ColorBar
  bgcolor::Union{String,Nothing} = nothing # "rgba(0,0,0,0)"
  bordercolor::Union{String,Nothing} = nothing # "#444"
  borderwidth::Union{Int,Nothing} = nothing # 0
  dtick::Union{Float64,Int,String,Nothing} = nothing
  exponentformat::Union{String,Nothing} = nothing # none" | "e" | "E" | "power" | "SI" | "B", default is B
  len::Union{Float64,Int,Nothing} = nothing # number greater than or equal to 0
  lenmode::Union{String,Nothing} = nothing # "fraction" | "pixels", default is fraction | Default: "fraction"
  minexponent::Union{Int,Nothing} = nothing # number greater than or equal to 0 | Default: 3
  nticks::Union{Int,Nothing} = nothing # number greater than or equal to 0 | Default: 0
  orientation::Union{String,Nothing} = nothing # "v" | "h", default is "v"
  outlinecolor::Union{String,Nothing} = nothing # "#444"
  outlinewidth::Union{Int,Nothing} = nothing # number greater than or equal to 0 | Default: 1
  separatethousands::Union{Bool,Nothing} = nothing # true | false, default is false
  showexponent::Union{String,Nothing} = nothing # "all" | "first" | "last" | "none", default is "all"
  showticklabels::Union{Bool,Nothing} = nothing # true | false, default is true
  showtickprefix::Union{String,Nothing} = nothing # "all" | "first" | "last" | "none", default is all
  showticksuffix::Union{String,Nothing} = nothing # "all" | "first" | "last" | "none", default is "all"
  thickness::Union{Int,Nothing} = nothing # number greater than or equal to 0 | Default: 30
  thicknessmode::Union{String,Nothing} = nothing # "fraction" | "pixels", default is fraction | Default: "pixels"
  tick0::Union{Float64,Int,String,Nothing} = nothing # number or categorical coordinate string
  tickangle::Union{String,Int,Float64,Nothing} = nothing # Default: "auto"
  tickcolor::Union{String,Nothing} = nothing # Default: "#444"
  tickfont::Union{Font,Nothing} = nothing # Font Struct
  tickformat::Union{String,Nothing} = nothing # string, default is ""
  tickformatstops::Union{Dict,Nothing} = nothing # Dict containing properties
  ticklabeloverflow::Union{String,Nothing} = nothing # "allow" | "hide past div" | "hide past domain"
  ticklabelposition::Union{String,Nothing} = nothing # "outside" | "inside" | "outside top" | "inside top" | "outside bottom" | "inside bottom", default is "outside"
  ticklabelstep::Union{Int,Nothing} = nothing # number greater than or equal to 1 | Default: 1
  ticklen::Union{Int,Nothing} = nothing # number greater than or equal to 0 | Default: 5
  tickmode::Union{String,Nothing} = nothing # "auto" | "linear" | "array", default is "array"
  tickprefix::Union{String,Nothing} = nothing # string, default is ""
  ticks::Union{String,Nothing} = nothing # "outside" | "inside" | "" | Default: ""
  ticksuffix::Union{String,Nothing} = nothing # string, default is ""
  ticktext::Union{Vector{String},Nothing} = nothing # Vector of strings
  tickvals::Union{Vector{Float64},Vector{Int},Nothing} = nothing
  tickwidth::Union{Int,Nothing} = nothing # number greater than or equal to 0 | Default: 1
  x::Union{Float64,Nothing} = nothing # 1.02
  xanchor::Union{String,Nothing} = nothing # "left" | "center" | "right", default is left
  xpad::Union{Int,Nothing} = nothing # 10
  yanchor::Union{String,Nothing} = nothing # "top" | "middle" | "bottom", default is middle
  ypad::Union{Int,Nothing} = nothing # 10
  # needs special treatment:
  title_font::Union{Font,Nothing} = nothing # Font()
  title_side::Union{String,Nothing} = nothing # LAYOUT_LEFT
  title_text::Union{String,Nothing} = nothing # ""
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
    :bgcolor, :bordercolor, :borderwidth, :dtick, :exponentformat, :len, :lenmode, :minexponent, :nticks, :orientation,
    :outlinecolor, :outlinewidth, :separatethousands, :showexponent, :showticklabels, :showtickprefix, :showticksuffix,
    :thickness, :thicknessmode, :tick0, :tickangle, :tickcolor, :tickfont, :tickformat, :tickformatstops, :ticklabeloverflow,
    :ticklabelposition, :ticklabelstep, :ticklen, :tickmode, :tickprefix, :ticks, :ticksuffix, :ticktext, :tickvals, :tickwidth,
    :x, :xanchor, :xpad, :yanchor, :ypad
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
"""
    ErrorBar()

----------
# Examples
----------

```
julia> error_x = ErrorBar(
    array = [1.2, 2.6, 3.1],
    type = "data"
)
```

-----------
# Properties
-----------
* `array::Vector{Float64}` - Sets the data corresponding the length of each error bar. Values are plotted relative to the underlying data.
* `arrayminus::Vector{Float64}` - Sets the data corresponding the length of each error bar in the bottom (left) direction for vertical (horizontal) bars Values are plotted relative to the underlying data.
* `color::String` - Sets the stoke color of the error bars.
* `symmetric::Bool` - Determines whether or not the error bars have the same length in both direction (top/bottom for vertical bars, left/right for horizontal bars.
* `thickness::Int` - Sets the thickness (in px) of the error bars. Type: greater than or equal to 0. Default: 2
* `traceref::Int` - Type: Integer greater than or equal to 0. Default: 0
* `tracerefminus::Int` - Type: Integer greater than or equal to 0. Default: 0
* `type::String` - Determines the rule used to generate the error bars. If "constant`, the bar lengths are of a constant value. Set this constant in `value`. If "percent", the bar lengths correspond to a percentage of underlying data. Set this percentage in `value`. If "sqrt", the bar lengths correspond to the square of the underlying data. If "data", the bar lengths are set with data set `array`. Type: enumerated , one of ( "percent" | "constant" | "sqrt" | "data" )
* `value::Float64` - Sets the value of either the percentage (if `type` is set to "percent") or the constant (if `type` is set to "constant") in the case of "constant" `type`. Type: greater than or equal to 0. Default: 10
* `valueminus::Float64` - Sets the value of either the percentage (if `type` is set to "percent") or the constant (if `type` is set to "constant") corresponding to the lengths of the error bars in the bottom (left) direction for vertical (horizontal) bars. Type: number greater than or equal to 0 | Default: 10
* `visible::Bool` - Determines whether or not this set of error bars is visible.
* `width::Int` - Sets the width (in px) of the cross-bar at both ends of the error bars. Type: greater than or equal to 0
"""
Base.@kwdef mutable struct ErrorBar
  array::Union{Vector{Float64},Nothing} = nothing # Vector of numbers
  arrayminus::Union{Vector{Float64},Nothing} = nothing # Vector of numbers
  color::Union{String,Nothing} = nothing # Color string
  copy_ystyle::Union{Bool,Nothing} = nothing # true | false
  symmetric::Union{Bool,Nothing} = nothing
  thickness::Union{Int,Nothing} = nothing # 2
  traceref::Union{Int,Nothing} = nothing # 0
  tracerefminus::Union{Int,Nothing} = nothing # 0
  type::Union{String,Nothing} = nothing # "percent" | "constant" | "sqrt" | "data"
  value::Union{Float64,Nothing} = nothing # 10
  valueminus::Union{Float64,Nothing} = nothing # 10
  visible::Union{Bool,Nothing} = nothing
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
    :array, :arrayminus, :color, :copy_ystyle, :symmetric, :thickness,
    :traceref, :tracerefminus, :type, :value, :valueminus, :visible, :width
  ])
end

function Stipple.render(eb::ErrorBar, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(eb)
end

#===#
"""
    PlotAnnotation()

----------
# Examples
----------

```
julia>
```

-----------
# Properties
-----------
* `align::String` -Sets the horizontal alignment of the `text` within the box. Has an effect only if `text` spans two or more lines (i.e. `text` contains one or more <br> HTML tags) or if an explicit width is set to override the text width. Type: enumerated , one of ( `"left"` | `"center"` | `"right"` ) | Default: `"center"`
* `arrowcolor::String` -Sets the color of the annotation arrow.
* `arrowhead::Int` - Sets the end annotation arrow head style.  Type: integer between or equal to `0` and `8` | Default: `1`
* `arrowside::String` - Sets the annotation arrow head position. Type: flaglist string. Any combination of `"end"`, `"start"` joined with a `"+"` OR `"none"` | Default: `"end"`
* `arrowsize::Float64` - Sets the size of the end annotation arrow head, relative to `arrowwidth`. A value of 1 (default) gives a head about 3x as wide as the line. Type: number greater than or equal to `0.3` | Default: `1`
* `arrowwidth::Float64` - Sets the width (in px) of annotation arrow line. Type: number greater than or equal to `0.1`
* `ax::Union{String,Int,Float64}` - Sets the x component of the arrow tail about the arrow head. If `axref` is `pixel`, a positive (negative) component corresponds to an arrow pointing from right to left (left to right). If `axref` is not `pixel` and is exactly the same as `xref`, this is an absolute value on that axis, like `x`, specified in the same coordinates as `xref`. Type: number or categorical coordinate string
* `axref::String` - Indicates in what coordinates the tail of the annotation (ax,ay) is specified. If set to a ax axis id (e.g. "ax" or "ax2"), the `ax` position refers to a ax coordinate. If set to "paper", the `ax` position refers to the distance from the left of the plotting area in normalized coordinates where "0" ("1") corresponds to the left (right). If set to a ax axis ID followed by "domain" (separated by a space), the position behaves like for "paper", but refers to the distance in fractions of the domain length from the left of the domain of that axis: e.g., "ax2 domain" refers to the domain of the second ax axis and a ax position of 0.5 refers to the point between the left and the right of the domain of the second ax axis. In order for absolute positioning of the arrow to work, "axref" must be exactly the same as "xref", otherwise "axref" will revert to "pixel" (explained next). For relative positioning, "axref" can be set to "pixel", in which case the "ax" value is specified in pixels relative to "x". Absolute positioning is useful for trendline annotations which should continue to indicate the correct trend when zoomed. Relative positioning is useful for specifying the text offset for an annotated point. Type: enumerated , one of ( `"pixel"` | `"/^x([2-9]|[1-9][0-9]+)?( domain)?$/"`) | Default: `"pixel"`
* `ay::Union{String,Int,Float64}` - Sets the y component of the arrow tail about the arrow head. If `ayref` is `pixel`, a positive (negative) component corresponds to an arrow pointing from bottom to top (top to bottom). If `ayref` is not `pixel` and is exactly the same as `yref`, this is an absolute value on that axis, like `y`, specified in the same coordinates as `yref`. Type: number or categorical coordinate string
* `ayref::String` - Indicates in what coordinates the tail of the annotation (ax,ay) is specified. If set to a ay axis id (e.g. "ay" or "ay2"), the `ay` position refers to a ay coordinate. If set to "paper", the `ay` position refers to the distance from the bottom of the plotting area in normalized coordinates where "0" ("1") corresponds to the bottom (top). If set to a ay axis ID followed by "domain" (separated by a space), the position behaves like for "paper", but refers to the distance in fractions of the domain length from the bottom of the domain of that axis: e.g., "ay2 domain" refers to the domain of the second ay axis and a ay position of 0.5 refers to the point between the bottom and the top of the domain of the second ay axis. In order for absolute positioning of the arrow to work, "ayref" must be exactly the same as "yref", otherwise "ayref" will revert to "pixel" (explained next). For relative positioning, "ayref" can be set to "pixel", in which case the "ay" value is specified in pixels relative to "y". Absolute positioning is useful for trendline annotations which should continue to indicate the correct trend when zoomed. Relative positioning is useful for specifying the text offset for an annotated point. Type: enumerated , one of ( `"pixel"` | `"/^x([2-9]|[1-9][0-9]+)?( domain)?$/"`) | Default: `"pixel"`
* `bgcolor::String` -Sets the background color of the annotation. Default: `"rgba(0,0,0,0)"`
* `bordercolor::String` - Sets the color of the border enclosing the annotation `text`. Default: `"rgba(0,0,0,0)"`
* `borderpad::Int` - Sets the padding (in px) between the `text` and the enclosing border. Default: `1`
* `borderwidth::Int` - Sets the width (in px) of the border enclosing the annotation `text`. Type: number greater than or equal to 0 | Default: `1`
* `captureevents::Bool` - Determines whether the annotation text box captures mouse move and click events, or allows those events to pass through to data points in the plot that may be behind the annotation. By default `captureevents` is "false" unless `hovertext` is provided. If you use the event `plotly_clickannotation` without `hovertext` you must explicitly enable `captureevents`.
* `font::Font` - Sets the annotation text font.
* `height::Int` - Sets an explicit height for the text box. null (default) lets the text set the box height. Taller text will be clipped. Type: number greater than or equal to `1`
* `hoverlabel::Dict` -  object containing one or more of the keys listed: `bgcolor` `bordercolor` `font`
* `name::String` - When used in a template, named items are created in the output figure in addition to any items the figure already has in this array. You can modify these items in the output figure by making your own item with `templateitemname` matching this `name` alongside your modifications (including `visible: false` or `enabled: false` to hide it). Has no effect outside of a template.
* `opacity::Float64` - Sets the opacity of the annotation (text + arrow). Type: number between or equal to `0` and `1` | Default: `1`
* `showarrow::Bool` - Determines whether or not the annotation is drawn with an arrow. If "true", `text` is placed near the arrow's tail. If "false", `text` lines up with the `x` and `y` provided. Default: `true`
* `standoff::Int` - Sets a distance, in pixels, to move the end arrowhead away from the position it is pointing at, for example to point at the edge of a marker independent of zoom. Note that this shortens the arrow from the `ax` / `ay` vector, in contrast to `xshift` / `yshift` which moves everything by this amount.  Type: number greater than or equal to `0` | Default: `0`
* `startarrowhead::Int` -  Sets the start annotation arrow head style.  Type: integer between or equal to `0` and `8` | Default: `1`
* `startarrowsize::Int` - Sets the size of the start annotation arrow head, relative to `arrowwidth`. A value of 1 (default) gives a head about 3x as wide as the line.  Type: number greater than or equal to `0.3` | Default: `1`
* `startstandoff::Int` - Sets a distance, in pixels, to move the start arrowhead away from the position it is pointing at, for example to point at the edge of a marker independent of zoom. Note that this shortens the arrow from the `ax` / `ay` vector, in contrast to `xshift` / `yshift` which moves everything by this amount.  Type: number greater than or equal to `0` | Default: `0`
* `templateitemname::String` - Used to refer to a named item in this array in the template. Named items from the template will be created even without a matching item in the input figure, but you can modify one by making an item with `templateitemname` matching its `name`, alongside your modifications (including `visible: false` or `enabled: false` to hide it). If there is no template or no matching item, this item will be hidden unless you explicitly show it with `visible: true`.
* `text::String` - Sets the text associated with the annotation. Plotly uses a subset of HTML tags to do things like newline (<br>), bold (<b></b>), italics (<i></i>), hyperlinks (<a href='...'></a>). Tags <em>, <sup>, <sub> <span> are also supported. Type: string
* `textangle::Union{Int,Float64}` - Sets the angle at which the `text` is drawn with respect to the horizontal. Type: `angle` | Default: `0`
* `valign::String` - Sets the vertical alignment of the `text` within the box. Has an effect only if an explicit height is set to override the text height. Type: enumerated , one of ( `"top"` | `"middle"` | `"bottom"`) | Default: `"middle"`
* `visible::Bool` `visible` - Determines whether or not this annotation is visible. Type: boolean | Default: `true`
* `width::Int` - Sets an explicit width for the text box. null (default) lets the text set the box width. Wider text will be clipped. Type: number greater than or equal to `1`
* `x::Union{String,Int,Float64}` - Sets the annotation's x position. If the axis `type` is "log", then you must take the log of your desired range. If the axis `type` is "date", it should be date strings, like date data, though Date objects and unix milliseconds will be accepted and converted to strings. If the axis `type` is "category", it should be numbers, using the scale where each category is assigned a serial number from zero in the order it appears.
* `xanchor::String` - Sets the text box's horizontal position anchor This anchor binds the `x` position to the "left", "center" or "right" of the annotation. For example, if `x` is set to 1, `xref` to "paper" and `xanchor` to "right" then the right-most portion of the annotation lines up with the right-most edge of the plotting area. If "auto", the anchor is equivalent to "center" for data-referenced annotations or if there is an arrow, whereas for paper-referenced with no arrow, the anchor picked corresponds to the closest side. Type: enumerated , one of ( `"auto"` | `"left"` | `"center"` | `"right"`) | Default: `"auto"`
* `xref::Union{String,Int,Float64}` - Sets the annotation's x coordinate axis. If set to a x axis id (e.g. "x" or "x2"), the `x` position refers to a x coordinate. If set to "paper", the `x` position refers to the distance from the left of the plotting area in normalized coordinates where "0" ("1") corresponds to the left (right). If set to a x axis ID followed by "domain" (separated by a space), the position behaves like for "paper", but refers to the distance in fractions of the domain length from the left of the domain of that axis: e.g., "x2 domain" refers to the domain of the second x axis and a x position of 0.5 refers to the point between the left and the right of the domain of the second x axis.  Type: enumerated , one of ( `"paper"` | `"/^x([2-9]|[1-9][0-9]+)?( domain)?$/"` )
* `xshift::Union{Int,Float64}` - Shifts the position of the whole annotation and arrow to the right (positive) or left (negative) by this many pixels. Default: `0`
* `y::Union{String,Int,Float64}` - Sets the annotation's y position. If the axis `type` is "log", then you must take the log of your desired range. If the axis `type` is "date", it should be date strings, like date data, though Date objects and unix milliseconds will be accepted and converted to strings. If the axis `type` is "category", it should be numbers, using the scale where each category is assigned a serial number from zero in the order it appears.
* `yanchor::Union{String}` - Sets the text box's vertical position anchor This anchor binds the `y` position to the "top", "middle" or "bottom" of the annotation. For example, if `y` is set to 1, `yref` to "paper" and `yanchor` to "top" then the top-most portion of the annotation lines up with the top-most edge of the plotting area. If "auto", the anchor is equivalent to "middle" for data-referenced annotations or if there is an arrow, whereas for paper-referenced with no arrow, the anchor picked corresponds to the closest side. Type: enumerated , one of ( `"auto"` | `"top"` | `"middle"` | `"bottom"`) | Default: `"auto"`
* `yref::Union{String,Int,Float64}` - Sets the annotation's y coordinate axis. If set to a y axis id (e.g. "y" or "y2"), the `y` position refers to a y coordinate. If set to "paper", the `y` position refers to the distance from the bottom of the plotting area in normalized coordinates where "0" ("1") corresponds to the bottom (top). If set to a y axis ID followed by "domain" (separated by a space), the position behaves like for "paper", but refers to the distance in fractions of the domain length from the bottom of the domain of that axis: e.g., "y2 domain" refers to the domain of the second y axis and a y position of 0.5 refers to the point between the bottom and the top of the domain of the second y axis. Type: enumerated , one of ( `"paper"` | `"/^x([2-9]|[1-9][0-9]+)?( domain)?$/"` )
* `yshift::Union{Int,Float64}` - Shifts the position of the whole annotation and arrow up (positive) or down (negative) by this many pixels. Default: `0`
"""
Base.@kwdef mutable struct PlotAnnotation
  align::Union{String,Nothing} = nothing
  arrowcolor::Union{String,Nothing} = nothing
  arrowhead::Union{Int,Nothing} = nothing
  arrowside::Union{String,Nothing} = nothing
  arrowsize::Union{Float64,Nothing} = nothing
  arrowwidth::Union{Float64,Nothing} = nothing
  ax::Union{String,Int,Float64,Nothing} = nothing
  axref::Union{String,Nothing} = nothing
  ay::Union{String,Int,Float64,Nothing} = nothing
  ayref::Union{String,Nothing} = nothing
  bgcolor::Union{String,Nothing} = nothing
  bordercolor::Union{String,Nothing} = nothing
  borderpad::Union{Int,Nothing} = nothing
  borderwidth::Union{Int,Nothing} = nothing
  captureevents::Union{Bool,Nothing} = nothing
  # TODO: clicktoshow
  # TODO: xclick
  # TODO: yclick
  font::Union{Font,Nothing} = nothing
  height::Union{Float64,Int,Nothing} = nothing
  hoverlabel::Union{Dict,Nothing} = nothing
  name::Union{String,Nothing} = nothing
  opacity::Union{Float64,Nothing} = nothing
  showarrow::Union{Bool,Nothing} = nothing
  standoff::Union{Int,Nothing} = nothing
  startarrowhead::Union{Int,Nothing} = nothing
  startarrowsize::Union{Float64,Nothing} = nothing
  startstandoff::Union{Int,Nothing} = nothing
  templateitemname::Union{String,Nothing} = nothing
  text::Union{String,Nothing} = nothing
  textangle::Union{Float64,Int,Nothing} = nothing
  valign::Union{String,Nothing} = nothing
  visible::Union{Bool,Nothing} = nothing
  width::Union{Float64,Int,Nothing} = nothing
  x::Union{String,Int,Float64,Nothing} = nothing
  xanchor::Union{String,Nothing} = nothing
  xref::Union{String,Int,Float64,Nothing} = nothing
  xshift::Union{Int,Float64,Nothing} = nothing
  y::Union{String,Int,Float64,Nothing} = nothing
  yanchor::Union{String,Nothing} = nothing
  yref::Union{String,Int,Float64,Nothing} = nothing
  yshift::Union{Int,Float64,Nothing} = nothing
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

  optionals!(trace, an, [:align, :arrowcolor, :arrowhead, :arrowside, :arrowsize, :arrowwidth,
         :ax, :axref, :ay, :ayref, :bgcolor, :bordercolor, :borderpad, :borderwidth, :captureevents,
         :height, :hoverlabel, :name, :opacity, :showarrow, :standoff, :startarrowhead, :startarrowsize,
         :startstandoff, :templateitemname, :text, :textangle, :valign, :visible, :width, :x, :xanchor,
          :xref, :xshift, :y, :yanchor, :yref, :yshift])
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
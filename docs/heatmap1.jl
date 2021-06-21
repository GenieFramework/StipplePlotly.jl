using Genie, Genie.Renderer.Html, Stipple, StipplePlotly, Colors, ColorSchemes

Genie.config.log_requests = false

plotly_palette = ["Greys", "YlGnBu", "Greens", "YlOrRd", "Bluered", "RdBu", "Reds", "Blues", "Picnic", "Rainbow", "Portland", "Jet", "Hot", "Blackbody", "Earth", "Electric", "Viridis", "Cividis"]

"""
Plotly:
  Map missing, nothing, NaN, -Inf and Inf in a string "null".
  JSON.json maps those on null without quoutes. Call-back error occors on front-end when you write new data (as in model[].z)
  Strings are interpreted as numbers.

  Colorscale:
    rgb triplets are strings on front-end side.
    rgb(r,g,b) triplets: r, g and b are integers from 0 to 255, or floats from 0.0 to 1.0.
    Floats must have a decimal for correct interpretation by Plotly.
"""

function rgb(pix::RGB{Float64})
  R = round(Int, 255 * clamp(pix.r, 0.0, 1.0))
  G = round(Int, 255 * clamp(pix.g, 0.0, 1.0))
  B = round(Int, 255 * clamp(pix.b, 0.0, 1.0))
  return "rgb($R,$G,$B)"
end

# See: https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/
function ColorScale(scheme::Symbol, N = 101)
  x = permutedims(0.0:(1.0/(N - 1)):1.0)
  cs = get(colorschemes[scheme], x, :clamp)
  cs_rgb = rgb.(cs)
  return vcat(x, cs_rgb)
end

function to_plotly_standard(x)
  if isnothing(x)
    m = "null"
  elseif ismissing(x)
    m = "null"
  elseif isa(x, AbstractString)
    m = x
  elseif isinf(x)
    m = "null"
  elseif isnan(x)
    m = "null"
  else
    m = x
  end
  return m
end

pd(name) = PlotData(
  z =  to_plotly_standard.(round.([100.0 0.0  missing;
       30.30235455584154  94.9495352852204 0.7150792978758869;
       63.172349721957175 37 -72.02122607433563;
       51.19876097916769  18.676411380287483 314.15;
       87.03992589163836  88.74217734803698 62.122844059857215]; sigdigits=3)),
  zmin = 0.0,
  zmax = 100.0,
  x = ["L0", "L63", "L128", "L191", "L255"],
  y = ["L255", "L128", "L0"],
  plot = StipplePlotly.Charts.PLOT_TYPE_HEATMAP,
  name = name,
  colorscale = ColorScale(:algae),
  colorbar = ColorBar("Z-data", 18, "right"),
  hoverongaps = false,
  hoverinfo = "x+y+z"
)

pl(title) = PlotLayout(
  plot_bgcolor = "#FFFFFF",
  title_text = title,
  margin_b = 25,
  margin_t = 80,
  margin_l = 40,
  margin_r = 40,
  xaxis_text = "From",
  xaxis_font = Font(18),
  xaxis_ticks = "outside top",
  xaxis_side = "top",
  xaxis_position = 1.0,
  xaxis_showline = true,
  xaxis_showgrid = false,
  xaxis_zeroline = false,
  xaxis_mirror = "all",
  xaxis_ticklabelposition = "outside top",
  yaxis_showline = true,
  yaxis_zeroline = false,
  yaxis_mirror = "all",
  yaxis_showgrid = false,
  yaxis_text = "To",
  yaxis_font = Font(18),
  yaxis_ticks = "outside",
  yaxis_scaleanchor = "x",
  yaxis_scaleratio = 1,
  yaxis_constrain = "domain",
  yaxis_constraintoward = "top"
)

Base.@kwdef mutable struct Model <: ReactiveModel
  data::R{Vector{PlotData}} = [pd("Random 1")], READONLY
  layout::R{PlotLayout} = pl(""), READONLY
end

model = Stipple.init(Model())

function ui()
  page(
    vm(model), class="container", [
      plot(:data, layout = :layout)
    ]
  ) |> html
end

route("/", ui)

up()

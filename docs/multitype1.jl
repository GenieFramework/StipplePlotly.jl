using Genie, Genie.Renderer.Html, Stipple, StipplePlotly

Genie.config.log_requests = false

xrange = 0.0:(2π/1000):2π

dxmeasured = 0.05
dymeasured = 0.1

xexperiment = (0.0:(2π/10):2π) .+ 3 .* dxmeasured .* (rand(Float64,11) .- 0.5)
dx = dxmeasured .* ones(Float64, size(xexperiment))
yexperiment = sin.(xexperiment) .+ 3 .* dymeasured .* (rand(Float64,size(xexperiment)) .- 0.5)
dy = dymeasured .* ones(Float64, size(yexperiment))

pd_line(name, xar) = PlotData(
  x = xar,
  y = sin.(xar),
  plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
  mode = "lines",
  name = name
)

pd_scatter(name, xar, dx, yar, dy) = PlotData(
  x = xar,
  error_x = ErrorBar(dx),
  y = yar,
  error_y = ErrorBar(dy),
  plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
  mode = "markers",
  name = name
)

pl() = PlotLayout(
  plot_bgcolor = "#FFFFFF",
  title_text = "Wave",
  hovermode = "closest",
  showlegend = true,
  xaxis_text = "time (s)",
  yaxis_text = "displacement (mm)",
  yaxis_ticks = "outside",
  xaxis_ticks = "outside",
  xaxis_showline = true,
  yaxis_showline = true,
  yaxis_zeroline = false,
  xaxis_zeroline = false,
  xaxis_mirror = "all",
  yaxis_mirror = "all"
  # height = nothing,
  # width = nothing
)

Base.@kwdef mutable struct Model <: ReactiveModel
  data::R{Vector{PlotData}} = [pd_line("Sinus", xrange), pd_scatter("Experiment", xexperiment, dx, yexperiment, dy)]
  layout::R{PlotLayout} = pl()
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

module StipplePlotly

import Genie
import Stipple
using Stipple.Reexport

#===#

function deps() :: String
  Genie.Router.route("/js/stipple/plotly.min.js") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", "plotly.min.js"), String),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route("/js/stipple/resizesensor.min.js") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", "resizesensor.min.js"), String),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route("/js/stipple/loadash.min.js") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", "lodash.min.js"), String),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route("/js/stipple/vueresize.min.js") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", "vueresize.min.js"), String),
      :javascript) |> Genie.Renderer.respond
  end

  vueplotly = Genie.Configuration.isprod() ? "vueplotly.min.js" : "vueplotly.js"
  Genie.Router.route("/js/stipple/$vueplotly") do
    Genie.Renderer.WebRenderable(
      read(joinpath(@__DIR__, "..", "files", "js", vueplotly), String),
      :javascript) |> Genie.Renderer.respond
  end

  string(
    Genie.Renderer.Html.script(src="/js/stipple/plotly.min.js"),
    Genie.Renderer.Html.script(src="/js/stipple/resizesensor.min.js"),
    Genie.Renderer.Html.script(src="/js/stipple/lodash.min.js"),
    Genie.Renderer.Html.script(src="/js/stipple/vueresize.min.js"),
    Genie.Renderer.Html.script(src="/js/stipple/vueplotly.min.js"),
  )
end

#===#

include("Charts.jl")
@reexport using .Charts

function __init__()
  push!(Stipple.DEPS, deps)
end

end # module

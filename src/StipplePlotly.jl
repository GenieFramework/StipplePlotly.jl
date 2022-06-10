module StipplePlotly

using Genie, Stipple, Stipple.Reexport

#===#

const assets_config = Genie.Assets.AssetsConfig(package = "StipplePlotly.jl")

#===#

function deps_routes() :: Nothing
  Genie.Assets.external_assets(Stipple.assets_config) && return nothing

  Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="plotly2.min"), named = :get_plotly2js) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="plotly2.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="resizesensor.min"), named = :get_resizesensorjs) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="resizesensor.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="lodash.min"), named = :get_lodashjs) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="lodash.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="vueresize.min"), named = :get_vueresizejs) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="vueresize.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  Genie.Router.route(Genie.Assets.asset_route(assets_config, :js, file="vueplotly.min"), named = :get_vueplotlyjs) do
    Genie.Renderer.WebRenderable(
      Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="vueplotly.min.js")),
      :javascript) |> Genie.Renderer.respond
  end

  nothing
end

function deps() :: Vector{String}
  [
    Genie.Renderer.Html.script(src=Genie.Assets.asset_path(assets_config, :js, file="plotly2.min")),
    Genie.Renderer.Html.script(src=Genie.Assets.asset_path(assets_config, :js, file="resizesensor.min")),
    Genie.Renderer.Html.script(src=Genie.Assets.asset_path(assets_config, :js, file="lodash.min")),
    Genie.Renderer.Html.script(src=Genie.Assets.asset_path(assets_config, :js, file="vueresize.min")),
    Genie.Renderer.Html.script(src=Genie.Assets.asset_path(assets_config, :js, file="vueplotly.min"))
  ]
end

#===#

include("Charts.jl")
@reexport using .Charts

function __init__()
  deps_routes()
  Stipple.deps!(@__MODULE__, deps)
end

end # module

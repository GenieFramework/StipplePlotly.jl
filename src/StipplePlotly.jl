module StipplePlotly

using Genie, Stipple, Stipple.Reexport

#===#

const assets_config = Genie.Assets.AssetsConfig(package = "StipplePlotly.jl")

#===#

function deps() :: Vector{String}
  if ! Genie.Assets.external_assets(Stipple.assets_config)

    Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="plotly2.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="plotly2.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

    Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="resizesensor.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="resizesensor.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

    Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="lodash.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="lodash.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

    Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="vueresize.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="vueresize.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

    Genie.Router.route(Genie.Assets.asset_path(assets_config, :js, file="vueplotly.min")) do
      Genie.Renderer.WebRenderable(
        Genie.Assets.embedded(Genie.Assets.asset_file(cwd=normpath(joinpath(@__DIR__, "..")), file="vueplotly.min.js")),
        :javascript) |> Genie.Renderer.respond
    end

  end

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
  Stipple.DEPS[@__MODULE__] = deps
end

end # module

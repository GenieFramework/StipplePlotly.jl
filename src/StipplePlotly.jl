module StipplePlotly

using Genie, Stipple, Stipple.Reexport
using Requires

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

  @require PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5" begin
    function Charts.plot(fieldname::Union{Symbol,AbstractString};
      layout::Union{Symbol,PlotLayout,AbstractString,PlotlyBase.Layout} = PlotLayout(),
      config::Union{Symbol,PlotConfig,AbstractString,PlotlyBase.PlotConfig} = StipplePlotly.PlotConfig(),
      args...) :: String

      k = (Symbol(":data"), Symbol(":layout"), Symbol(":config"))
      v = Any["$fieldname", layout, config]

      Charts.plotly(; args..., NamedTuple{k}(v)...)
    end
    
    function plotly(p::Symbol; layout = "p.layout", config = "p.config", kwargs...)
      plot("p.data"; layout, config, kwargs...)
    end

    Base.print(io::IO, a::Union{PlotlyBase.PlotConfig}) = print(io, Stipple.json(a))
    StructTypes.StructType(::Type{<:PlotlyBase.HasFields}) = JSON3.RawType()
    StructTypes.StructType(::Type{PlotlyBase.PlotConfig}) = JSON3.RawType()

    JSON3.rawbytes(x::Union{PlotlyBase.HasFields,PlotlyBase.PlotConfig}) = codeunits(PlotlyBase.JSON.json(x))
  end
end

end # module

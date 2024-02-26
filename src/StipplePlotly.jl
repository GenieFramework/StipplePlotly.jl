module StipplePlotly

using Genie, Stipple, Stipple.Reexport, Stipple.ParsingTools
using Requires

import Genie: Assets.add_fileroute, Assets.asset_path

#===#

const assets_config = Genie.Assets.AssetsConfig(package = "StipplePlotly.jl")

_symbol_dict(x) = x
_symbol_dict(d::AbstractDict) =
    Dict{Symbol,Any}([(Symbol(k), _symbol_dict(v)) for (k, v) in d])

#===#

function deps_routes() :: Nothing
  Genie.Assets.external_assets(Stipple.assets_config) && return nothing
  
  basedir = dirname(@__DIR__)
  add_fileroute(assets_config, "plotly.min.js"; basedir, named = :get_plotlyjs) 
  add_fileroute(assets_config, "ResizeSensor.js"; basedir, named = :get_resizesensorjs) 
  add_fileroute(assets_config, "lodash.min.js"; basedir, named = :get_lodashjs) 
  add_fileroute(assets_config, "vueresize.min.js"; basedir, named = :get_vueresizejs)
  add_fileroute(assets_config, "vueplotly.min.js"; basedir, named = :get_vueplotlyjs)
  add_fileroute(assets_config, "sentinel.min.js"; basedir, named = :get_sentineljs)
  add_fileroute(assets_config, "syncplot.js"; basedir, named = :get_syncplotjs)

  nothing
end

function deps() :: Vector{String}
  [
    script(src = asset_path(assets_config, :js, file="plotly.min")),
    script(src = asset_path(assets_config, :js, file="ResizeSensor")),
    script(src = asset_path(assets_config, :js, file="lodash.min")),
    script(src = asset_path(assets_config, :js, file="vueresize.min")),
    script(src = asset_path(assets_config, :js, file="vueplotly.min")),
    script(src = asset_path(assets_config, :js, file="sentinel.min")),
    script(src = asset_path(assets_config, :js, file="syncplot"))
  ]
end

#===#

include("Charts.jl")
@reexport using .Charts

include("Layouts.jl")
@reexport using .Layouts

function __init__()
  deps_routes()
  Stipple.deps!(@__MODULE__, deps)
  isdefined(Stipple, :register_global_components) && Stipple.register_global_components("plotly", legacy = true)

  @require PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5" begin
    @static if !isdefined(Base, :get_extension)
      include("../ext/StipplePlotlyPlotlyBaseExt.jl")
    end

    export PBPlotWithEvents, PBPlotWithEventsReadOnly
    Base.@kwdef struct PBPlotWithEvents
      var""::R{PlotlyBase.Plot} = PlotlyBase.Plot()
      _selected::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
      _hover::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
      _click::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
      _relayout::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
    end

    Base.@kwdef struct PBPlotWithEventsReadOnly
      var""::R{PlotlyBase.Plot} = PlotlyBase.Plot(), READONLY
      _selected::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
      _hover::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
      _click::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
      _relayout::R{Charts.PlotlyEvent} = Charts.PlotlyEvent()
    end
  end
end

end # module

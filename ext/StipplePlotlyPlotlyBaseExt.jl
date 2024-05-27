module StipplePlotlyPlotlyBaseExt

using StipplePlotly
using StipplePlotly.Stipple
using StipplePlotly.Charts
import Stipple.stipple_parse

isdefined(Base, :get_extension) ? (using PlotlyBase) : (using ..PlotlyBase)

function Base.Dict(p::PlotlyBase.Plot)
    Dict(
    :data => p.data,
    :layout => p.layout,
    :frames => p.frames,
    :config => p.config
    )
end

function PlotlyBase.Plot(d::AbstractDict)
    sd = symbol_dict(d)
    data = haskey(sd, :data) && ! isempty(sd[:data]) ? PlotlyBase.GenericTrace.(sd[:data]) : PlotlyBase.GenericTrace[]
    layout = haskey(sd, :layout) ? PlotlyBase.Layout(sd[:layout]) : PlotlyBase.Layout()
    frames = haskey(sd, :frames) && ! isempty(sd[:frames]) ? PlotlyBase.PlotlyFrame.(sd[:frames]) : PlotlyBase.PlotlyFrame[]
    config = haskey(sd, :config) ? PlotlyBase.PlotConfig(; sd[:config]...) : PlotlyBase.PlotConfig()

    PlotlyBase.Plot(data, layout, frames; config)
end

function Stipple.stipple_parse(::Type{PlotlyBase.Plot}, d::AbstractDict)
    PlotlyBase.Plot(d)
end

function Stipple.stipple_parse(::Type{T}, d::AbstractDict) where T <: PlotlyBase.AbstractTrace
    T(d)
end

function Stipple.stipple_parse(::Type{PlotlyBase.Layout}, d::AbstractDict)
    PlotlyBase.Layout(d)
end

end
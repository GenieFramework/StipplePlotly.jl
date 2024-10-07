module StipplePlotlyPlotsExt

using StipplePlotly
using StipplePlotly.Stipple
using StipplePlotly.Charts
import Stipple: render, stipple_parse

if isdefined(Base, :get_extension)
    using Plots
    using PlotlyBase
else
    using ..Plots
    using ..PlotlyBase
end

function Stipple.render(pl::Plots.Plot)
    pl = Plots.plotlybase_syncplot(pl)
    delete!(pl.layout.fields, :height)
    delete!(pl.layout.fields, :width)
    pl.layout.fields[:margin] = Dict(:l => 50, :b => 50, :r => 50, :t => 60)

    return pl
end

function __init__()
    current_backend = Plots.backend()
    if current_backend !== :plotly
        Plots.plotly()
        Plots.backend(current_backend)
    end
end

end
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
    # make sure the PlotlyBase backend is loaded and that the current backend is not changed
    already_initialized = true
    if !isdefined(Plots, :plotlybase_syncplot)
        current_backend = Plots.backend()
        Plots.plotly() === current_backend || Plots.backend(current_backend)
        already_initialized = false
    end

    pl = already_initialized ? Plots.plotlybase_syncplot(pl) : Base.invokelatest(Plots.plotlybase_syncplot, pl)
    pop!(pl.layout, :height)
    pop!(pl.layout, :width)
    pl.layout.fields[:margin] = Dict(:l => 50, :b => 50, :r => 50, :t => 60)

    return pl
end

end
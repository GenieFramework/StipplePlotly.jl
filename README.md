# StipplePlotly

Embedding Plotly Charts in Stipple.

### News: The standard API is now PlotlyBase, the StipplePlotly API is considered legacy.
### Example with forwarding of plotly events

See the docstrings of `watchplots()` and `watchplot()` for more details!

```julia
using Stipple, Stipple.ReactiveTools
using StipplePlotly
using PlotlyBase

@app Example begin
    @mixin plot::PBPlotWithEvents
    @in plot_cursor = Dict{String, Any}()

    @onchange isready begin
        isready || return
        p = Plot(scatter(y=1:10))
        plot.layout = p.layout
        plot.data = p.data
    end

    @onchange plot_selected begin
        haskey(plot_selected, "points") && @info "Selection: $(getindex.(plot_selected["points"], "pointIndex"))"
    end

    @onchange plot_click begin
        @info "$plot_click"
    end

    @onchange plot_hover begin
        @info "hovered over $(plot_hover["points"][1]["x"]):$(plot_hover["points"][1]["y"])"
        # @info "$plot_hover"
    end

    @onchange plot_cursor begin
        @info "cursor moved to $(plot_cursor["cursor"]["x"]):$(plot_cursor["cursor"]["y"])"
        # @info "$plot_cursor"
    end
end

# commented lines below: manual definition of plot_events
# @app Example begin
#     @in plot = Plot()
#     @in plot_selected = Dict{String, Any}()
#     @in plot_click = Dict{String, Any}()
#     @in plot_hover = Dict{String, Any}()
#     @in plot_cursor = Dict{String, Any}()
# end

@mounted Example watchplots()

# the keyword argument 'keepselection' (default = false) controls whether the selection outline shall be removed after selection
function ui()
    cell(class = "st-module", [
        plotly(:plot, syncevents = true, keepselection = false),
    ])
end

@page("/", ui, model = Example)
```

Possible forwarded events are

- '_selected' (Selection changed)
- '_hover' (hovered over data point)
- '_click' (click event on plot area)
- '_relayout' (plot layout changed)
- '_cursor' (current mouse position, not covered in PBPlotWithEvents in order to reduce data traffic)

For more Stipple Plotly Demos please check: [Stipple Demos Repo](https://github.com/GenieFramework/StippleDemos)

## Acknowledgement

Handling of Plotly Events was highly inspired by the [PlotlyJS](https://github.com/JuliaPlots/PlotlyJS.jl) package by [Spencer Lyon](https://github.com/sglyon)

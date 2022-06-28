# StipplePlotly

Embedding Plotly Charts in Stipple.

Both a StipplePlotly-API and the PlotlyBase API are supported.

#### Latest example with forwarding of plotly events
##### Note: Syntax for event forwarding has changed!
See the docstrings of `watchplots()` and `watchplot()` for more details!

```julia
@reactive! mutable struct Example <: ReactiveModel
    @mixin plot::PBPlotWithEvents
end

# commented lines below: manual definition of plot_events
# @reactive! mutable struct Example <: ReactiveModel
#     plot::R{Plot} = Plot()
#     plot_selected::R{Dict{String, Any}} = Dict{String, Any}()
#     plot_hover::R{Dict{String, Any}} = Dict{String, Any}()
# end

function ui(model::Example)
    page(model, class = "container", 
    row(class = "st-module", [
        plotly(:plot, syncevents = true),
    ]))
end

# The following line will watch all plots that have `syncevents` enabled
# or that have set `syncprefix` explicitly.
Stipple.js_mounted(::Example) = watchplots(:Example)

function handlers(model)
  on(model.isready) do isready
      isready || return
      push!(model)
  end

  on(model.plot_selected) do data
      haskey(data, "points") && @info "Selection: $(getindex.(data["points"], "pointIndex"))"
  end

  return model
end
```
For more Stipple Plotly Demos please check: [Stipple Demos Repo](https://github.com/GenieFramework/StippleDemos)

## Acknowledgement
Handling of Plotly Events was highly inspired by the [PlotlyJS](https://github.com/JuliaPlots/PlotlyJS.jl) package by [Spencer Lyon](https://github.com/sglyon)
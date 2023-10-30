using Documenter

push!(LOAD_PATH,  "../../src")

using StipplePlotly, StipplePlotly.Charts

makedocs(
    sitename = "StipplePlotly - plotting library for Stipple",
    format = Documenter.HTML(prettyurls = false),
    warnonly = true,
    pages = [
        "Home" => "index.md",
        "StipplePlotly API" => [
          "Charts" => "API/charts.md",
          "Layouts" => "API/layouts.md",
          "StipplePlotly" => "API/stippleplotly.md",
        ]
    ],
)

deploydocs(
  repo = "github.com/GenieFramework/StipplePlotly.jl.git",
)

using Documenter

push!(LOAD_PATH,  "../../src")

using StipplePlotly, StipplePlotly.Charts

makedocs(
    sitename = "StipplePlotly - plotting library for Stipple",
    format = Documenter.HTML(prettyurls = false),
    pages = [
        "Home" => "index.md",
        "StipplePlotly API" => [
          "Charts" => "api/charts.md",
          "Layouts" => "api/layouts.md",
          "StipplePlotly" => "api/stippleplotly.md",
        ]
    ],
)

deploydocs(
  repo = "github.com/GenieFramework/StipplePlotly.jl.git",
)

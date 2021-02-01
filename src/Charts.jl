module Charts

import DataFrames
import Genie, Stipple
import Genie.Renderer.Html: HTMLString, normal_element

const DEFAULT_WRAPPER = Genie.Renderer.Html.template

using Stipple

export PlotLayout, PlotData, plot

Genie.Renderer.Html.register_normal_element("plotly", context = @__MODULE__)

Base.@kwdef mutable struct PlotLayout
  title_text::String = ""
  title_font_family = "Helvetica, sans"
  title_font_size::Union{Int,Float64} = 1
  title_font_color::String = ""
end

Base.@kwdef mutable struct PlotData{T<:Vector, V<:Vector}
  x::T = T[]
  y::V = V[]
end

function plot(fieldname::Symbol;
              layout::Union{Symbol,PlotLayout} = PlotLayout(),
              wrap::Function = DEFAULT_WRAPPER,
              args...) :: String

  k = (Symbol(":data"), Symbol(":layout"))
  v = Any["$fieldname", layout]

  wrap() do
    plotly(; args..., NamedTuple{k}(v)...)
  end
end

#===#

# function Stipple.watch(vue_app_name::String, fieldtype::R{PlotData}, fieldname::Symbol, channel::String, model::M)::String where {M<:ReactiveModel}
#   string(vue_app_name, raw".\$watch('", fieldname, "', function(newVal, oldVal){

#   });\n\n")
# end

# function Stipple.watch(vue_app_name::String, fieldtype::R{PlotLayout}, fieldname::Symbol, channel::String, model::M)::String where {M<:ReactiveModel}
#   string(vue_app_name, raw".\$watch('", fieldname, "', function(newVal, oldVal){

#   });\n\n")
# end

#===#

function Stipple.render(pd::PlotData{T, V}, fieldname::Union{Symbol,Nothing} = nothing) where {T<:Vector, V<:Vector}
  [pd]
end

function Stipple.render(pl::PlotLayout, fieldname::Union{Symbol,Nothing} = nothing)
  Dict(
    :title => Dict(
      :text => pl.title_text,
      :font => Dict(
        :family => pl.title_font_family,
        :size => pl.title_font_size,
        :color => pl.title_font_color
      )
    )
  )
end

# #===#


end
@testset "PlotlyBase extension" begin

    @testset "Stipple.JSONText" begin
        @test ! @isdefined(PBPlotWithEvents) || @isdefined(PlotlyBase)
        using PlotlyBase, PlotlyBase.JSON
        @test @isdefined PBPlotWithEvents

        sc = scatter(x = StipplePlotly.JSONText("jsontext"), more_of_this = "a")
        pl = Plot(sc)
        @test JSON.json(sc) == "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":jsontext}"
        @test contains(JSON.json(pl), "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":jsontext}")

        @test Stipple.json(sc) == "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":jsontext}"
        @test contains(Stipple.json(pl), "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":jsontext}")
    end

    @testset "Parsing" begin
        using Stipple
        import Stipple.stipple_parse

        @testset "Layout" begin
            pl = PlotlyBase.Layout(xaxis_range = [1, 2])
            pl_d = JSON3.read(Stipple.json(render(pl)), Dict)

            pl_in = stipple_parse(PlotlyBase.Layout, pl_d)
            @test pl_in[:xaxis_range] == [1, 2]

            pl_in = stipple_parse(PlotlyBase.Layout{Dict{Symbol, Any}}, pl_d)
            pl_in[:xaxis_range] == [1, 2]

            @static if VersionNumber(Genie.Assets.package_version(Stipple)) >= v"0.30.6"
                pl_in = stipple_parse(PlotlyBase.Layout{OrderedDict{Symbol, Any}}, pl_d)
                @test pl_in[:xaxis_range] == [1, 2]
            end
        end

        @testset "GenericTrace" begin
            tr = scatter(x = [1, 2, 3], y = [3, 4, 5])
            tr_d = JSON3.read(Stipple.json(render(tr)), Dict)

            tr_in = stipple_parse(GenericTrace, tr_d)
            @test tr_in.x == [1, 2, 3]
            @test tr_in.y == [3, 4, 5]
        end

        @testset "Plot" begin
            pl = PlotlyBase.Plot([scatter(x = [1, 2, 3], y = [3, 4, 5])], PlotlyBase.Layout(xaxis_range = [1, 2]))
            pl_d = JSON3.read(Stipple.json(render(pl)), Dict)

            pl_in = stipple_parse(PlotlyBase.Plot, pl_d)
            @test length(pl_in.data) == 1
            @test pl_in.layout[:xaxis_range] == [1, 2]

            PlotType = typeof(Plot())
            pl_in = stipple_parse(PlotType, pl_d)
            
            @test length(pl_in.data) == 1
            @test pl_in.data[1][:x] == [1, 2, 3]
            @test pl_in.layout[:xaxis_range] == [1, 2]
        end
    end

end

pl = PlotlyBase.Layout(xaxis_range = [1, 2])
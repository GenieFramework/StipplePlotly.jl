function create_example_dataframe()
    xs = [1.0, 2.0, 3.0, 4.0]
    ys = [10.0, 20.0, 30.0, 40.0]
    groups = [1, 2, 1, 2]
    labels = ["A", "C", "B", "D"]
    return DataFrame(X = xs, Y = ys, Group = groups, Label = labels)
end

@testset "Scatter Plots" begin
    @testset "Multiple Groups without Tooltips" begin
        df = create_example_dataframe()
        pd = plotdata(df, :X, :Y; groupfeature = :Group)
        @test length(pd) == 2
        @test length(pd[1].x) ==  length(pd[2].x)
        @test length(pd[1].y) ==  length(pd[2].y)
        @test isnothing(pd[1].text) 
        @test isnothing(pd[2].text) 
    end
    
    @testset "Multiple Groups with Tooltips" begin
        df = create_example_dataframe()
        pd = plotdata(df, :X, :Y; groupfeature = :Group, text = df.Label)
        @test length(pd) == 2
        @test length(pd[1].x) ==  length(pd[2].x) == 2
        @test length(pd[1].y) ==  length(pd[2].y) == 2
        @test !isnothing(pd[1].text) 
        @test !isnothing(pd[2].text) 
        if !isnothing(pd[1].text) && !isnothing(pd[2].text) 
            @test length(pd[1].text) == length(pd[1].x) == length(pd[1].y) == 2
            @test length(pd[2].text) == length(pd[2].x) == length(pd[2].x) == 2 
            @test pd[1].text[1] == "A"
            @test pd[1].text[2] == "B"
            @test pd[2].text[1] == "C"
            @test pd[2].text[2] == "D"
        end
    end
end

@testset "JSONText from PlotlyBase extension" begin
    
    using Stipple
    @testset "Stipple.JSONText" begin
        @test ! @isdefined PBPlotWithEvents
        using PlotlyBase, PlotlyBase.JSON
        @test @isdefined PBPlotWithEvents

        sc = scatter(x = StipplePlotly.JSONText("jsontext"), more_of_this = "a")
        pl = Plot(sc)
        @test JSON.json(sc) == "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":\"jsontext\"}"
        @test contains(JSON.json(pl), "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":\"jsontext\"}")

        @test Stipple.json(sc) == "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":\"jsontext\"}"
        @test contains(Stipple.json(pl), "{\"type\":\"scatter\",\"more\":{\"of\":{\"this\":\"a\"}},\"x\":\"jsontext\"}")
    end

end
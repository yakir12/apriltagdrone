using LinearAlgebra
using AprilTags, CairoMakie, CoordinateTransformations, Rotations
using CSV
# using GLMakie

# GLMakie.activate!()


inch = 96
pt = 4/3
mm = inch / 2.54 / 10
size = (210mm, 297mm)

buff = 0.15

square = Point2f[(0,0), (1, 0), (1, 1), (0, 1), (0, 0)]

cs = [(Point2f(x, y) .+ randn(Point2f)/50) .* size for x in (buff, 1 - buff) for y in (buff, 1 - buff)]
θs = 2π*rand(4)


fig = Figure(; size, figure_padding = 0)
ax = Axis(fig[1,1], limits = (0, size[1], 0, size[2]), aspect = DataAspect())#, backgroundcolor = :gray80)
hidespines!(ax)
hidedecorations!(ax)
x = range(0.2size[1], 0.8size[1], step = 10mm)
y = range(0.2size[2], 0.8size[2], step = 10mm)'
scatter!(ax, vec(Point2f.(x, y)), color = :black)
square_width = 25mm
for k in 1:4
    at = getAprilTagImage(k)
    for i in 1:10, j in 1:10
        trans = Translation(cs[k]) ∘ LinearMap(square_width * I(2)) ∘ LinearMap(Angle2d(θs[k])) ∘ Translation(-0.5, -0.5) ∘ LinearMap(I(2)/10) ∘ Translation(i - 1, j - 1)
        poly!(ax, trans.(square), color = at[i, j], strokewidth = 0)
    end
end
text!(ax, [c + Point2f(0, 0.75square_width) for c in cs], text = string.([round.(Int, c) for c in cs], " at ", round.(Int, rad2deg.(θs)), "°"), align = (:center, :center))

save("toprint.pdf", fig)
CSV.write("data.csv", [(; x = first(c), y = last(c), θ) for (c, θ) in zip(cs, θs)])

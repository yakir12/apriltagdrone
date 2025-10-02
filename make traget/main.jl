using LinearAlgebra
using AprilTags, CairoMakie, CoordinateTransformations, Rotations
using CSV
using CairoMakie.Makie.GeometryBasics
using GLMakie

GLMakie.activate!()

square = Point2[(0,0), (1, 0), (1, 1), (0, 1), (0, 0)]

w, h = (1920, 1080)
buff = 0.1
n = 10

sz = (w, h)
Δ = buff*h
radius = h/2 - Δ

cs = map(range(0, 2π, n + 1)[2:end]) do θ
    Point2(sz ./ 2) + (radius + Δ) * Point2(reverse(sincos(θ)))
end

# x1 = w/2 + radius + Δ
# cs1 = Point2.(x1, range(Δ, h - Δ, n ÷ 2))
# x2 = w/2 - (radius + Δ)
# cs2 = Point2.(x2, range(Δ, h - Δ, n ÷ 2))
# cs = [cs1; cs2]

θs = 2π*rand(n)


fig = Figure(; size = sz, figure_padding = 0)
ax = Axis(fig[1,1], limits = (0, w, 0, h), aspect = DataAspect())#, backgroundcolor = :gray80)
hidespines!(ax)
hidedecorations!(ax)
x = range(0, w, step = 50)
y = range(0, h, step = 50)'
xy = vec(Point2.(x, y))
filter!(p -> norm(p - Point2(sz ./2)) < radius, xy)
scatter!(ax, xy, color = :black)
square_width = 50radius/500
for k in 1:n
    at = getAprilTagImage(k)
    polys = Vector{Polygon{2, Float64}}(undef, 100)
    for i in 1:10, j in 1:10
        trans = Translation(cs[k]) ∘ LinearMap(square_width * I(2)) ∘ LinearMap(Angle2d(θs[k])) ∘ Translation(-0.5, -0.5) ∘ LinearMap(I(2)/10) ∘ Translation(i - 1, j - 1)
        xys = trans.(square)
        polys[LinearIndices((10, 10))[i, j]] = Polygon(xys)
    end
    if all(pol -> all(∈(Rect(0, 0, sz...)), pol.exterior), polys)
        poly!(ax, polys, color = vec(at), strokewidth = 0)
    end
end
# text!(ax, [c + Point2(0, 0.75square_width) for c in cs], text = string.([round.(Int, c) for c in cs], " at ", round.(Int, rad2deg.(θs)), "°"), align = (:center, :center))
lines!(ax, Circle(Point(sz ./ 2), radius), color = :black)

fig
# save("toprint.pdf", fig)
# CSV.write("data.csv", [(; x = first(c), y = last(c), θ) for (c, θ) in zip(cs, θs)])


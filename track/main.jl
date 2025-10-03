using LinearAlgebra, Statistics
using AprilTags, Images, CoordinateTransformations, FileIO, CSV, Rotations
using VideoIO, OpenCV, StaticArrays, ImageTransformations

const RowCol = SVector{2, Float32}

n = 6

detector = AprilTagDetector()

file = "d.mp4"
imgs = load(file; target_format = VideoIO.AV_PIX_FMT_GRAY8)

tags = detector.(collect.(imgs))


@assert all(ts -> issorted(ts, by = t -> t.id), tags)

# @assert all(==(n) ∘ length, tags)

keep = findall(==(n) ∘ length, tags)


tags = tags[keep]
imgs = imgs[keep]

@assert all(==(n) ∘ length, tags)

function get_p(tags)
    RowCol.(reverse.(reshape(stack(getfield.(tags, :p)), 4n)))
end

ps = get_p.(tags)


function quality(tags)
    if all(t -> iszero(t.hamming), tags)
        return mean(t -> t.decision_margin, tags)
    end
    return 0.0
end

_, ref = findmax(quality, tags)


# using ImageView, ImageDraw
#
# img = RGB.(imgs[1])
# for p in ps[1]
#     i, j = round.(Int, p)
#     draw!(img, CirclePointRadius(i, j, 5), colorant"red")
# end
# imshow(img)

# src = ps[ref]
# dst = ps[1]
#
#
# h, mask = OpenCV.findHomography(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 4n, 1)), OpenCV.Mat(reshape(reinterpret(Float32, dst), 2, 4n, 1)))
# count(iszero, mask)
#
# _dst = OpenCV.perspectiveTransform(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 4n, 1)), h)
# dst1 = RowCol.(eachslice(_dst, dims = 2))
# dst .- dst1
#
# m = SMatrix{3,3}(reshape(h, 3 ,3))
# trans = PerspectiveMap() ∘ LinearMap(m') ∘ push1
# dst1 = trans.(src)
# dst .- dst1
#
#
# trans = PerspectiveMap() ∘ LinearMap(inv(m')) ∘ push1
# src1 = trans.(dst)
# src .- src1
#
#
# h = findHomography(src, dst)
# trans = PerspectiveMap() ∘ LinearMap(inv(h)) ∘ push1
# src1 = trans.(dst)
# src .- src1




#
#
# h1, mask = OpenCV.findHomography(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 4n, 1)), OpenCV.Mat(reshape(reinterpret(Float32, dst), 2, 4n, 1)), 0, 5.0, OpenCV.Mat(reshape(reinterpret(UInt8, mask1), 1, 1, 4n)), 2000, 0.995)
#
# h1, mask = OpenCV.findHomography(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 4n, 1)), OpenCV.Mat(reshape(reinterpret(Float32, dst), 2, 4n, 1)), OpenCV.RANSAC, 5.0)
#
# h1, mask = OpenCV.findHomography(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 4n, 1)), OpenCV.Mat(reshape(reinterpret(Float32, dst), 2, 4n, 1)), OpenCV.RANSAC, 5.0, OpenCV.Mat(reshape(reinterpret(UInt8, mask1), 1, 1, 4n)), 2000, 0.995)
# count(iszero, mask)

function findHomography(src, dst)
    # mask = Matrix{Float64}(undef, 3, 3)
    h, mask = OpenCV.findHomography(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 4n, 1)), OpenCV.Mat(reshape(reinterpret(Float32, dst), 2, 4n, 1)))#, OpenCV.Mat(reshape(mask, 1, 3, 3)), 2000, 0.995)
    # h, mask = OpenCV.findHomography(OpenCV.Mat(reshape(reinterpret(Float32, src), 2, 1, 4n)), OpenCV.Mat(reshape(reinterpret(Float32, dst), 2, 1, 4n)), OpenCV.RANSAC, 5.0, OpenCV.Mat(reshape(mask, 1, 3, 3)), 2000, 0.995)
    SMatrix{3,3}(reshape(h, 3 ,3))'
end

push1 = Base.Fix2(StaticArrays.push, 1)

dst = ps[ref]

mx, Mx = round.(Int, extrema(first.(dst)))
my, My = round.(Int, extrema(last.(dst)))
if isodd(Mx - mx + 1)
    mx -= 1
end
if isodd(My - my + 1)
    my -= 1
end
ax = (mx:Mx, my:My)


# img = RGB.(imgs[ref])
# for p in ps[ref]
#     j, i = round.(Int, p)
#     draw!(img, CirclePointRadius(i, j, 5), colorant"red")
# end
# imshow(img)



imgws = [Matrix{Gray{N0f8}}(undef, length.(ax)...) for _ in imgs]
for (i, img) in enumerate(imgs)
    if i == ref
        imgw = img[LinearIndices(ax)]
    else
        src = ps[i]
        h = findHomography(src, dst)
        trans = PerspectiveMap() ∘ LinearMap(inv(h)) ∘ push1
        imgw = parent(warp(img, trans, ax))
    end
    imgws[i] .= imgw
end

VideoIO.save("b.mp4", imgws; target_pix_fmt = VideoIO.AV_PIX_FMT_GRAY8)







#
# using Combinatorics
#
# dims = (1, 2, 10)
# src1 = rand(Float32, 2, 10)
# dst1 = rand(Float32, 2, 10)
#
# for d in permutations(dims)
#     src = OpenCV.Mat(reshape(src1, d...))
#     dst = OpenCV.Mat(reshape(dst1, d...))
#     try
#         h, mask = OpenCV.findHomography(src, dst)#, OpenCV.Mat(reshape(mask, 1, 3, 3)), 2000, 0.995)
#         @show d, h
#     catch
#     end
# end
#
#
# d = (2, 10, 1)
# src = OpenCV.Mat(rand(Float32, d...))
# dst = OpenCV.Mat(rand(Float32, d...))
# h, mask = OpenCV.findHomography(src, dst)#, OpenCV.Mat(reshape(mask, 1, 3, 3)), 2000, 0.995)
#




#
#
# for (i, img) in enumerate(imgs)
#
#     img = imgs[1]
#     tags = detector(collect(img))
#     t = tags[1]
#
#
# vid = openvideo("a.mp4")
# for img in vid
# end
# close(vid)
#
# img = FileIO.load("a.jpg")
# xyθ = CSV.File("data.csv")
#
#
# # using ImageView
# # drawTagBox!.(Ref(img), tags)
# # imshow(img)
#
#
#
# function decompose_homography_2d(H::Matrix{Float64})
#     # Normalize so H[3,3] = 1
#     H_norm = H / H[3, 3]
#
#     # Extract translation from last column
#     translation = H_norm[1:2, 3]
#
#     # Extract upper-left 2x2 affine part
#     A = H_norm[1:2, 1:2]
#
#     # Decompose affine part using SVD
#     U, S, Vt = svd(A)
#
#     # Rotation matrix (orthogonal part)
#     R = U * Vt
#
#     # Ensure proper rotation (det = +1, not reflection)
#     if det(R) < 0
#         U[:, 2] *= -1
#         R = U * Vt
#     end
#
#     # Scale and shear (what's left after removing rotation)
#     scale_shear = R' * A
#
#     # Extract rotation angle
#     rotation_angle = atan(R[2, 1], R[1, 1])
#
#     # Projective distortion (bottom row)
#     projective = H_norm[3, :]
#
#     # Reconstruct for verification
#     H_reconstructed = zeros(3, 3)
#     H_reconstructed[1:2, 1:2] = R * scale_shear
#     H_reconstructed[1:2, 3] = translation
#     H_reconstructed[3, :] = projective
#
#     return (
#         translation = translation,
#         rotation = R,
#         rotation_angle = rotation_angle,
#         scale_shear = scale_shear,
#         projective = projective,
#         H_normalized = H_norm,
#         H_reconstructed = H_reconstructed
#     )
# end
#
#
# tag = tags[4]
# h = decompose_homography_2d(tag.H)
# h.H_reconstructed .- tag.H
#
#
# for tag in tags
#
#     x, y, θ = xyθ[tag.id]
#     trans = LinearMap(Angle2d(-θ)) ∘ LinearMap(square_width * I(2)) ∘ Translation(-x, -y)
# end

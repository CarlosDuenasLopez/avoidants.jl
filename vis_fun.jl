using Revise
using GLMakie
using Makie.Colors

function levels(time)
    return time % 3
end


function liner(xs)
    println("liner xs: ", xs)
    ys = sin.(xs[])
    println("ys: ", ys)
    ys
end

function gen_xs(time, framerate)
    xs = collect(1:1/framerate:time+1)
    # println(time)
    println("xs: ", xs)
    xs
end


function f()
    time = Node(0.0)

    # set_theme!(theme_dark())
    points = Node(Point[])

    println(points)
    fig, ax, l = lines(points, axis = (; type = Axis, limits = (-10, 10, -10, 10)))

    framerate = 30
    timestamps = range(0, 20, step=1/framerate)

    record(fig, "my_anim.mp4", timestamps;
            framerate = framerate) do t
        push!(points[], Point(t, sin(t)))
        notify(points)
    end
end
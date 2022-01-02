using GLMakie

Base.@kwdef mutable struct Lorenz
    dt::Float64 = 0.01
    σ::Float64 = 10
    ρ::Float64 = 28
    β::Float64 = 8/3
    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1
end


function lorenz()

    function step!(l::Lorenz)
        dx = l.σ * (l.y - l.x)
        dy = l.x * (l.ρ - l.z) - l.y
        dz = l.x * l.y - l.β * l.z
        l.x += l.dt * dx
        l.y += l.dt * dy
        l.z += l.dt * dz
        Point3f(l.x, l.y, l.z)
    end

    attractor = Lorenz()

    points = Node(Point3f[])
    colors = Node(Int[])

    set_theme!(theme_black())

    fig, ax, l = lines(points,
        axis = (; type = Axis3,
            limits = (-30, 30, -30, 30, 0, 50)))

    record(fig, "lorenz.mp4", 1:120) do frame
        for i in 1:50
            push!(points[], step!(attractor))
            push!(colors[], frame)
        end
        # ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120)
        notify.((points, colors))
        l.colorrange = (0, frame)
    end
end
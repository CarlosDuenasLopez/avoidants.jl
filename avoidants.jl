using Revise: push!
using LinearAlgebra: length
using Base: Float64, NamedTuple
using GLMakie
using Revise
using GeometryTypes
using LinearAlgebra
using Random

mutable struct Agent
    posi::Point2f0
    history::Vector{Point2f0}
    velocity::Point2f0
end
Agent(x, y) = Agent(Point2f0(x, y), [], Point2f0(1, 0))
# Agent(x::Number, y::Number, vx::Number, vy::Number) = Agent(Point2f0(x, y), [], Point2f0(vx, vy))
Point2f0(a::Agent) = a.posi
Agent(x, y, vx, vy)=begin
    speed = 0.1
    v = [vx, vy] ./ (norm([vx, vy]) / speed)
    Agent(Point2f0(x, y), [], Point2f0(v...))
end


function step!(agent::Agent, all_agents)
    if path_ok(agent, all_agents)
        push!(agent.history, agent.posi)
        agent.posi = collect(agent.posi) .+ collect(agent.velocity)
    else
        degrees = shuffle(collect(45:45:315))
        for deg in degrees
            test_agent = change_velocity_by_degs(agent, deg)
            if path_ok(test_agent, all_agents)
                agent.velocity = test_agent.velocity
                push!(agent.history, agent.posi)
                agent.posi = collect(agent.posi) .+ collect(agent.velocity)
                return
            end
        end
        agent.velocity = Point2f0(0, 0)
        push!(agent.history, agent.posi)
    end
end


function path_ok(agent::Agent, all_agents::Vector{Agent})
    # check if current path would intersect one of other paths
    thresh = 0.3
    np = next_point(agent)
    my_line = LineSegment(agent.posi, np)

    #= ... CIRCLE BOARDER
    if dist(Point2f0(0, 0), np) > 30
        return false
    end=#

    field_size = 30
    if np[1] < -field_size || np[1] > field_size || np[2] < -field_size || np[2] > field_size
        return false
    end

    for other in all_agents
        # if agent != other
            for (i, p) in enumerate(other.history)
                if dist(np, p) < thresh
                    return false
                end
                if i > 1
                    other_line = LineSegment(other.history[i-1], p)
                    if intersects(other_line, my_line)[1]
                        return false
                    end
                end
            end
        # end
    end
    return true
end


function change_velocity!(agent::Agent)
    degrees = rand(1:300)
    rotation_matrix = [cosd(degrees) -sind(degrees); sind(degrees) cosd(degrees)]
    result_vector = rotation_matrix * collect(agent.velocity)
    agent.velocity = Point2f0(result_vector...)
end


function change_velocity_by_degs(agent, degrees)
    rotation_matrix = [cosd(degrees) -sind(degrees); sind(degrees) cosd(degrees)]
    result_vector = rotation_matrix * collect(agent.velocity)
    # agent.velocity = Point2f0(result_vector...)
    return Agent(agent.posi, agent.history, Point2f0(result_vector...))
end


function extend_path(agent::Agent)
    extension_length = 1
    pos_vec = [agent.x, agent.y, agent.z]
    v = collect(agent.velocity)
    v = v ./ (norm(v) * extension_length)
    p2 = pos_vec .+ v
    p1 = Point2f0(pos_vec[1], pos_vec[2])
    return LineSegment(p1, Point2f0(p2[1], p2[2]))
end


function next_point(agent::Agent)
    return agent.posi + agent.velocity
end


function run(iterations, all_agents)
    # a1 = Agent(0, 0, 0, 1)
    # a2 = Agent(10, 5, -1, 0)
    # all_agents = [a1, a2]
    for it in 1:iterations
        for a in all_agents
            step!(a, all_agents)
        end
    end
    # return a1.history, a2.history
    return [x.history for x in all_agents]
end


function movie(hists)
    running_points = []
    colors = Node(Int[])
    push!(colors[], 1)
    for h in hists
        push!(running_points, Node(Point2f0[]))
    end

    for (i, r) in enumerate(running_points)
        push!(r[], hists[i][1])
    end


    set_theme!(theme_black())

    fig, ax, l = lines(running_points[1], color = colors, colormap = :magma,
    axis = (;
        viewmode = :fit, limits = (-30, 30, -30, 30)))
    for r in running_points[2:end]
        lines!(r, color = colors, colormap = :magma)
    end

    hidedecorations!(ax)
    hidespines!(ax)

    record(fig, "lines.gif", 1:300) do frame
        for (i, running) in enumerate(running_points)
            push!(running[], hists[i][frame])
            notify(running)
        end
        push!(colors[], frame)
        notify(colors)
    end
end

function circle(num_agents, radius)
    angle_change = 360/num_agents
    angle = 0
    agents = Vector{Agent}()
    for it in 1:num_agents
        println("we")
        x = cosd(angle) * radius
        y = sind(angle) * radius
        v = rand(Int, 2)
        agent = Agent(x, y, v...)
        println(agent.velocity)
        push!(agents, agent)
        angle += angle_change
    end
    agents
end


function dist(p1::Point2f0, p2::Point2f0)
    return √((p2[1] - p1[1])^2 + (p2[2] - p1[2])^2)
end

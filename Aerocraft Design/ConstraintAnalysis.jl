module ConstraintAnalysis

using Symbolics
using NonlinearSolve

export T_W_for_T_O_Ground_Run_Distance, T_W_for_Rate_of_Climb, T_W_for_Maximum_Angle_of_Climb, T_W_for_Cruise_Airspeed, T_W_for_Service_Ceiling

GRAVITY = 32.174 # ft/s²

"""
**T/W for a Desired T-O Ground Run Distance**
- `WS` = W/S: Wing loading
- `C_L_TO`: Lift coefficient during takeoff
- `C_D_TO`: Drag coefficient during takeoff
- `ρ`: Air density (slug/ft³)
- `C_L_max`: Maximum lift coefficient
- `S_G`: Ground run distance
- `μ`: Friction coefficient (typically 0.04)
- `g`: Gravitational acceleration (default: 32.174 ft/s²)
"""
function T_W_for_T_O_Ground_Run_Distance(WS, C_L_TO, C_D_TO, ρ, C_L_max, S_G, μ, g=GRAVITY)
    return (
        (1.21 / (g * ρ * C_L_max * S_G)) .* (WS)
        .+ (0.605 / C_L_max) * (C_D_TO - μ * C_L_TO)
        .+ μ
    )
end

# T/W for a Desired Rate of Climb
function T_W_for_Rate_of_Climb(WS, Vᵥ, V∞, C_D_min, q, k)
    # WS = W/S: Wing loading
    # Vᵥ: Vertical velocity
    # V∞: True airspeed, typically V_Y
    # C_D_min: Minimum drag coefficient
    # q: Dynamic pressure at selected airspeed and altitude
    # k: Oswald efficiency factor
    return (
        (Vᵥ / V∞)
        .+ (q ./ WS) .* C_D_min
        .+ (k / q) .* WS
    )
end

# T/W for a Desired Maximum Angle of Climb
function T_W_for_Maximum_Angle_of_Climb(LD_max, γ)
    # LD_max: Expected maximum lift-to-drag ratio
    # γ: Desired climb angle
    # k: Oswald efficiency factor
    # C_D_min: Minimum drag coefficient
    return (
        sin(γ)
        + 1 / LD_max
    )
    # Also equal to sinγ + √(4⋅k⋅C_D_min)
end

# T/W for a Level Constant Velocity Turn
# ...

# T/W for a Desired Cruise Airspeed
function T_W_for_Cruise_Airspeed(WS, q, C_D_min, k)
    # WS = W/S: Wing loading
    # q: Dynamic pressure
    # C_D_min: Minimum drag coefficient
    # k: Oswald efficiency factor
    return (
        q * C_D_min * (1 ./ WS)
        + k * (1 / q) .* WS
    )
end

# T/W for a Desired Service Ceiling
function T_W_for_Service_Ceiling(WS, q, k, C_D_min)
    # WS = W/S: Wing loading
    # q: Dynamic pressure
    # k: Oswald efficiency factor
    # C_D_min: Minimum drag coefficient
    
    # V_Y: Best rate-of-climb speed (bizjet)
    V_Y = 79.016 .+ 1.2722 .* WS
    return (
        1.667 ./ V_Y
        .+ (q ./ WS) .* C_D_min
        .+ (k ./ q) .* WS
    )
    # 1.667 comes from assuming the best rate of climb of the airplane has
    # dropped to 100 fpm (1.667 ft/s)
end

# W/S for a Target Total Landing Distance
"***DOES NOT WORK***"
function W_S_for_Target_Total_Landing_Distance(S_LDG, h_obst, τ, A, C_L_max, C_D_LDG, μ, T_grW, g=GRAVITY, WS₀=1.0)
    # S_LDG: Total landing distance
    # h_obst: Height of obstacle (ft)
    # τ: Time for free rolls before braking begins (1-5 seconds)
    # A: ρC_L_max (slugs/ft³ or kg/m³)
    # C_L_max: Maximum lift coefficient in landing configuration
    # C_D_LDG: Drag coefficient during ground roll
    # μ: ground friction coefficient (usually 0.3)
    # T_grW: Thrust loading during ground roll, where T is idle or reverse thrust
    # g: Gravitational acceleration
    # WS₀: Initial guess for wing loading

    @variables WS

    # S_LDG = 19.08 * h_obst + (
    #     0.007923
    #     + 1.556 * τ * sqrt(A/WS)
    #     + 1.21
    #         / (g * (
    #             0.605/ C_L_max * (C_D_LDG - μ * C_L_max)
    #             + μ
    #             - T_grW
    #         ))
    # ) * WS/A

    # Define the equation
    equation = S_LDG - (19.08 * h_obst + (
        0.007923
        + 1.556 * τ * sqrt(A/WS)
        + 1.21
            / (g * (
                0.605/ C_L_max * (C_D_LDG - μ * C_L_max)
                + μ
                - T_grW
            ))
    ) * WS/A)

    print(equation)

    # Convert the symbolic equation to a function for the solver
    f(WS) = equation

    # Define a problem and solve it
    prob = NonlinearProblem(f, WS₀)
    sol = solve(prob, NewtonRaphson())  # Choose an appropriate solver

    return sol.root
end

end # module
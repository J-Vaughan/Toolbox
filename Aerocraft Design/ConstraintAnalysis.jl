# T/W for a Desired T-O Ground Run Distance
function T_W_for_T_O_Ground_Run_Distance(WS, C_L_TO, C_D_TO, q, C_L_max, S_G, μ, g)
    # WS = W/S: Wing loading
    # T/W for a Desired T-O Ground Run Distance
    # C_L_TO: Lift coefficient during takeoff
    # C_D_TO: Drag coefficient during takeoff
    # q: Dynamic pressure
    # C_L_max: Maximum lift coefficient
    # S_G: Ground run distance
    # μ: Friction coefficient
    # g: Gravitational acceleration
    return (
        (1.21 / (g * q * C_L_max * S_G)) * (WS)
        + (0.605 / C_L_max) * (C_D_TO - μ * C_L_TO)
        + μ
    )
end

# T/W for a Desired Rate of Climb
function T_W_for_Rate_of_Climb(WS, Vᵥ, V∞, C_D_min, q, k)
    # WS = W/S: Wing loading
    # Vᵥ: Vertical velocity
    # V∞: True airspeed, typically V_Y
    # C_D_min: Minimum drag coefficient
    # q: Dynamic pressure at selected airspeed and altitude
    # k: ?
    return (
        (Vᵥ / V∞)
        + (q / WS) * C_D_min
        + (k / q) * WS
    )
end

# T/W for a Desired Maximum Angle of Climb
function T_W_for_Maximum_Angle_of_Climb(LD_max, γ)
    # LD_max: Expected maximum lift-to-drag ratio
    # γ: Desired climb angle
    # k: ?
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
    # k: ?
    return (
        q * C_D_min * (1 / WS)
        + k * (1 / q) * WS
    )
end

# T/W for a Desired Service Ceiling
function T_W_for_Service_Ceiling(WS, V_Y, q, k, C_D_min)
    # WS = W/S: Wing loading
    # V_Y: Best rate-of-climb speed
    # q: Dynamic pressure
    # k: ?
    # C_D_min: Minimum drag coefficient
    return (
        1.667 / V_Y
        + (q / WS) * C_D_min
        + (k / q) * WS
    )
    # 1.667 comes from assuming the best rate of climb of the airplane has
    # dropped to 100 fpm (1.667 ft/s)
end


@enum Certification begin
    LSA
    FAR_23
    FAR_25
    FAR_27
    FAR_29
end

@enum EngineType begin
    Piston
    Turboprop
    Turbofan
    Turbojet
end

struct Flaps
    Complex::Bool
end

struct Weight
    Airframe::UInt64
    Empty::UInt64
end

struct Production
    Number::UInt64
    Run::UInt64
end

struct Wing
    Taper::Float64
    Sweep::Float64
    AspectRatio::Float64
    Area::Float64
end

abstract type VSC end

struct LandingGear <: VSC
    Retractable::Bool
    Quantity::UInt8
    UnitCost::UInt64
end

struct Power
    BrakeHP::UInt64
    ShaftHP::UInt64
end

struct Engine
    RatedThrust::UInt64
    Power::Power
    Type::EngineType
    Pistons::UInt8
    Weight::UInt64
end

struct Engines <: VSC
    Engine::Engine
    Quantity::UInt8
    UnitCost::UInt64
end

struct Airplane
    Certification::Certification
    Flaps::Flaps
    CompositeFraction::Float64
    Pressurized::Bool
    Weight::Weight
    V_H::UInt64
    Production::Production
    Wings::Wing
    Prototypes::UInt8
    LandingGear::VSC
    Engines::VSC
    SellingPrice::UInt64
end

#const CPI_2012 = 1.3367 # Consumer Price Index in 2023 relative to 2012
const CPI_2012 = 1.1 # Consumer Price Index in 2019 relative to 2012
const CPI_2019 = 1.2186 # Consumer Price Index in 2023 relative to 2019
const R_ENGR = 92.5 # Engineering Rate ($/hr) in 2012
const R_TOOL = 61.5 # Tooling Rate ($/hr) in 2012
const R_MFG = 53.5 # Manufacturing Rate ($/hr) in 2012
const INS_FACTOR = 1.15 # Insurance Factor (of selling price)

const SIMPLE_FLAPS = Flaps(false)
const ALUMINUM = 0
const COMPOSITE = 1
const UNPRESSURIZED = false
const PRESSURIZED = true

# Work Hours
# ----------

# Engineering
function H_ENGR(Plane::Airplane)
    Wₐ = Plane.Weight.Airframe
    Vₕ = Plane.V_H
    F_CERT_1 = Plane.Certification == LSA ? 2/3 : 1
    F_CF_1 = Plane.Flaps.Complex ? 1.03 : 1
    F_COMP_1 = 1 + Plane.CompositeFraction
    F_PRESS_1 = Plane.Pressurized ? 1.03 : 1
    N = 5 * Plane.Production.Number / Plane.Production.Run # Planes produced per 5 years

    H_ENGR = 0.0396 * Wₐ^0.791 * Vₕ^1.526 * N^0.183 * F_CERT_1 * F_CF_1 * F_COMP_1 * F_PRESS_1
end

# Tooling
function H_TOOL(Plane::Airplane)
    Wₐ = Plane.Weight.Airframe
    Vₕ = Plane.V_H
    N = 5 * Plane.Production.Number / Plane.Production.Run # Planes produced per 5 years
    Qₘ = N / (12 * 5) # Planes produced per month
    F_CF_2 = Plane.Flaps.Complex ? 1.02 : 1
    F_COMP_2 = 1 + Plane.CompositeFraction
    F_PRESS_2 = Plane.Pressurized ? 1.01 : 1
    F_TAPER_2 = Plane.Wings.Taper == 1 ? 0.95 : 1

    H_TOOL = 1.0032 * Wₐ^0.764 * Vₕ^0.899 * N^0.178 * Qₘ^0.066 * F_CF_2 * F_COMP_2 * F_PRESS_2 * F_TAPER_2
end

# Manufacturing
function H_MFG(Plane::Airplane)
    Wₐ = Plane.Weight.Airframe
    Vₕ = Plane.V_H
    N = 5 * Plane.Production.Number / Plane.Production.Run # Planes produced per 5 years
    F_CERT_3 = Plane.Certification == LSA ? 0.75 : 1
    F_CF_3 = Plane.Flaps.Complex ? 1.01 : 1
    F_COMP_3 = 1 + 0.25 * Plane.CompositeFraction

    H_MFG = 9.6613 * Wₐ^0.74 * Vₕ^0.543 * N^0.524 * F_CERT_3 * F_CF_3 * F_COMP_3
end

# Cost Estimation
# ---------------

# Total Cost of Engineering
function C_ENGR(Plane::Airplane, R_ENGR = R_ENGR)
    C_ENGR = H_ENGR(Plane) * R_ENGR * CPI_2012
end

# Total Cost of Development Support
function C_DEV(Plane::Airplane)
    Wₐ = Plane.Weight.Airframe
    Vₕ = Plane.V_H
    Nₚ = Plane.Prototypes
    F_CERT_5 = Plane.Certification == LSA ? 0.5 : 1
    F_CF_5 = Plane.Flaps.Complex ? 1.01 : 1
    F_COMP_5 = 1 + 0.5 * Plane.CompositeFraction
    F_PRESS_5 = Plane.Pressurized ? 1.03 : 1

    C_DEV = 0.06458 * Wₐ^0.873 * Vₕ^1.89 * Nₚ^0.346 * CPI_2012 * F_CERT_5 * F_CF_5 * F_COMP_5 * F_PRESS_5
end

# Total Cost of Flight Test Operations
function C_FT(Plane::Airplane)
    Wₐ = Plane.Weight.Airframe
    Vₕ = Plane.V_H
    Nₚ = Plane.Prototypes
    F_CERT_6 = Plane.Certification == LSA ? 10 : 5

    C_FT = 0.009646 * Wₐ^1.16 * Vₕ^1.3718 * Nₚ^1.281 * CPI_2012 * F_CERT_6
end # Alternative expression exists when more information is known

# Total Cost of Tooling
function C_TOOL(Plane::Airplane, R_TOOL = R_TOOL)
    C_TOOL = H_TOOL(Plane) * R_TOOL * CPI_2012
end

# Total Cost of Manufacturing
function C_MFG(Plane::Airplane, R_MFG = R_MFG)
    C_MFG = H_MFG(Plane) * R_MFG * CPI_2012
end

# Total Cost of Quality Control
function C_QC(Plane::Airplane)
    F_CERT_9 = Plane.Certification == LSA ? 0.5 : 1
    F_COMP_9 = 1 + 0.5 * Plane.CompositeFraction

    C_QC = 0.13 * C_MFG(Plane) * F_CERT_9 * F_COMP_9
end

# Total Cost of Materials
function C_MAT(Plane::Airplane)
    Wₐ = Plane.Weight.Airframe
    Vₕ = Plane.V_H
    F_CERT_10 = Plane.Certification == LSA ? 0.75 : 1
    F_CF_10 = Plane.Flaps.Complex ? 1.02 : 1
    F_PRESS_10 = Plane.Pressurized ? 1.01 : 1
    N = 5 * Plane.Production.Number / Plane.Production.Run # Planes produced per 5 years

    C_MAT = 24.896 * Wₐ^0.689 * Vₕ^0.624 * N^0.792 * CPI_2012 * F_CERT_10 * F_CF_10 * F_PRESS_10
end

# Fixed Cost (Total Cost to Certify)
function C_FIX(Plane::Airplane)
    C_FIX = C_ENGR(Plane) + C_DEV(Plane) + C_FT(Plane) + C_TOOL(Plane)
end

# Variable Cost
function C_VAR(Plane::Airplane)
    N = Plane.Production.Number
    C_VSC = mapreduce(x -> x.UnitCost * x.Quantity, +, Plane.VSC)
    C_INS = INS_FACTOR * Plane.SellingPrice

    C_VAR = (C_MFG(Plane) + C_QC(Plane) + C_MAT(Plane)) / N + C_VSC + C_INS
end

# VSCs
# ----

# Fixed vs Retractable Landing Gear
function VSC_GEAR(Plane::Airplane)
    VSC_GEAR = Plane.LandingGear.Retractable  ? 0 : -17500
end

# Avionics
function VSC_AV(Plane::Airplane)
    if Plane.Engines.Quantity == 1
        if Plane.Engines.Engine.Type == Piston
            VSC_AV = (6000 + 35000) / 2
        elseif Plane.Engines.Engine.Type == Turboprop
            VSC_AV = (35000 + 60000) / 2
        end
    elseif Plane.Engines.Quantity >= 2
        if Plane.Engines.Engine.Type == Piston && Plane.Engines.Quantity == 2
            VSC_AV = (35000 + 60000) / 2
        elseif Plane.Engines.Engine.Type == Turboprop
            VSC_AV = (40000 + 100000) / 2
        end
    else
        VSC_AV = 0
    end
end

# Engines
function C_PP(Plane::Airplane)
    if Plane.Engines.Engine.Type == Piston
        N_ENG = Plane.Engines.Quantity
        N_cyl = Plane.Engines.Engine.Pistons * Plane.Engines.Quantity
        P_BHP = Plane.Engines.Engine.Power.BrakeHP

        C_PP = N_eng * CPI_2019 * (1007 * N_cyl ^ 3 - 22620 * N_cyl ^ 2 + 155800 * N_cyl - 0.01447 * P_BHP ^ 3 + 8.654 * P_BHP ^ 2 - 1349 * P_BHP + 203900)
    elseif Plane.Engines.Engine.Type == Turboprop
        N_ENG = Plane.Engines.Quantity
        P_SHP = Plane.Engines.Engine.Power.ShaftHP

        C_PP = 377.4 * N_ENG * P_SHP * CPI_2012
    elseif Plane.Engines.Engine.Type == Turbojet
        N_ENG = Plane.Engines.Quantity
        T₀ = Plane.Engines.Engine.RatedThrust

        C_PP = 868.1 * N_ENG * T₀^0.8356 * CPI_2012
    elseif Plane.Engines.Engine.Type == Turbofan
        N_ENG = Plane.Engines.Quantity
        T₀ = Plane.Engines.Engine.RatedThrust

        C_PP = 1035.9 * N_ENG * T₀^0.8356 * CPI_2012
    else
        C_PP = 0
    end
end

# Miscellaneous
# -------------

# Number of engineers needed given assumptions
function N_ENGR(Plane:: Airplane, H_per_week::Number, N_weeks::Number, Period::Number)
    N_ENGR = round(H_ENGR(Plane) / (H_per_week * N_weeks * Period))
end

# Number of tooling technicians needed given assumptions
function N_TOOL(Plane:: Airplane, H_per_week::Number, N_weeks::Number, Period::Number)
    N_TOOL = round(H_TOOL(Plane) / (H_per_week * N_weeks * Period))
end

# Number of manufacturing technicians needed given assumptions
function N_MFG(Plane:: Airplane, H_per_week::Number, N_weeks::Number, Period::Number)
    N_MFG = round(H_MFG(Plane) / (H_per_week * N_weeks * Period))
end

# Average time to manufacture a single unit
function T_AC(Plane::Airplane)
    T_AC = H_MFG(Plane) / Plane.Production.Number
end

# Example 2-1
# -----------
println("Example 2-1")
Plane₂₁1 = Airplane(FAR_23, SIMPLE_FLAPS, COMPOSITE, UNPRESSURIZED, Weight(1100, 0), 185, Production(1000, 5), Wing(1.1, 0, 0, 0), 0, LandingGear(false, 3, 0), Engines(Engine(0, Power(0, 0), Piston, 0, 0), 1, 0), 0)
println(string(round(H_ENGR(Plane₂₁1))) * " ✓")
println(string(round(H_TOOL(Plane₂₁1))) * " ✓")
println(string(round(H_MFG(Plane₂₁1))) * " ✓")

println(string(N_ENGR(Plane₂₁1, 40, 48, 5)) * " ✓")

println(string(round(T_AC(Plane₂₁1))) * " ✓")
Plane₂₁2 = Airplane(FAR_23, SIMPLE_FLAPS, ALUMINUM, UNPRESSURIZED, Weight(1100, 0), 185, Production(1000, 5), Wing(1.1, 0, 0, 0), 0, LandingGear(false, 3, 0), Engines(Engine(0, Power(0, 0), Piston, 0, 0), 1, 0), 0)
println(string(round(H_ENGR(Plane₂₁2))) * " ✓")
println(string(round(H_TOOL(Plane₂₁2))) * " ✓")
println(string(round(H_MFG(Plane₂₁2))) * " ✓")

println(string(N_ENGR(Plane₂₁2, 40, 48, 5)) * " ✓")

println(string(round(T_AC(Plane₂₁2))) * " ✓")

# Example 2-2
# -----------
println("Example 2-2")
Plane₂₂1 = Airplane(FAR_23, SIMPLE_FLAPS, COMPOSITE, UNPRESSURIZED, Weight(1100, 0), 185, Production(1000, 5), Wing(1.1, 0, 0, 0), 4, LandingGear(false, 3, 0), Engines(Engine(0, Power(0, 0), Piston, 0, 0), 1, 0), 0)
println(string(round(C_ENGR(Plane₂₂1, 92))) * " ✓")
println(string(round(C_DEV(Plane₂₂1))) * " ✓")
println(string(round(C_FT(Plane₂₂1))) * " ✓")
println(string(round(C_TOOL(Plane₂₂1, 61))) * " ✓")
println(string(round(C_MFG(Plane₂₂1, 53))) * " ✓")
println(string(round(C_QC(Plane₂₂1))) * " ✓")
println(string(round(C_MAT(Plane₂₂1))) * " ✓")
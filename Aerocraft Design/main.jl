include("ConstraintAnalysis.jl")
#include("Utilities.jl")
using .ConstraintAnalysis
#using .Utilities

#using DataFrames
using COESA
using Unitful
using Plots

# Define units
module Units
    using Unitful
    @unit nmi "nmi" NauticalMile 1852u"m" false
    @unit tonne "tonne" MetricTon 1000u"kg" true
end
using .Units
Unitful.register(Units)


# Prescribed Constants
CRUISE_ALTITUDE = 65000u"ft"
MIN_CRUISE_MACH = 0.5
MAX_TTC = 1u"hr"
MIN_PAYLOAD_RANGE = 400u"nmi"
MIN_FERRY_RANGE = 3000u"nmi"
MAX_TO_LENGTH = 8000u"ft"
MAX_LANDING_LENGTH = 8000u"ft"
MIN_PAYLOAD_WEIGHT = 30000u"lb"
MIN_FERRY_WEIGHT = 0u"lb"
PAYLOAD_DENSITY = 1797u"kg/m^3"
DISPENSING_TARGET = 3u"Mtonne/yr"
OBSTACLE_HEIGHT = 50u"ft"

# Constants
CRUISE_ATMOSPHERE = atmosphere(ustrip(u"m"(CRUISE_ALTITUDE)))
TO_ATMOSPHERE = atmosphere(ustrip(u"m"(0u"ft")))
# TODO: Consider the other ISA conditions

# Design Variables
WS = (0:1:100)u"lb/ft^2"
MIN_CRUISE_SPEED = MIN_CRUISE_MACH * 968 # ft/s
CRUISE_SPEED = 0.9 * 968 # ft/s
C_D_MIN = 0.02 # TODO: Find a better value
AR = 9.71 # Prelim design value
C_L_MAX = 2.2 # Arbitrary


# Derived Variables
q_MIN_CRUISE = 1//2 * 1.825e-4 * MIN_CRUISE_SPEED^2
q_CRUISE = 1//2 * 1.825e-4 * CRUISE_SPEED^2
ρ_TO = 0.0023769 # slug/ft3
e = 1.78 * (1 - 0.045 * AR^0.68) - 0.64 # Prelim design value, (9-129) span efficiency factor
k = 1 / (π * e * AR) # Lift induced drag constant

# Analysis
Min_Cruise_Airspeed = T_W_for_Cruise_Airspeed(ustrip(WS), q_MIN_CRUISE, C_D_MIN, k)
Cruise_Airspeed = T_W_for_Cruise_Airspeed(ustrip(WS), q_CRUISE, C_D_MIN, k)
Service_Ceiling = T_W_for_Service_Ceiling(ustrip(WS), q_CRUISE, k, C_D_MIN)
Take_Off = T_W_for_T_O_Ground_Run_Distance(ustrip(WS), 0.8, 0.03, ρ_TO, C_L_MAX, 8000, 0.04)


# Plot
plot(WS, Cruise_Airspeed, label="Cruise Airspeed", xlabel="Wing Loading (WS)", ylabel="Cruise Airspeed (Vc)", title="Cruise Airspeed vs. Wing Loading")
plot!(WS, Service_Ceiling, label="Service Ceiling", xlabel="Wing Loading (WS)", ylabel="Service Ceiling (h)", title="Service Ceiling vs. Wing Loading")
plot!(WS, Take_Off, label="Take Off", xlabel="Wing Loading (WS)", ylabel="Take Off (T/W)", title="Take Off vs. Wing Loading")
plot!(WS, Min_Cruise_Airspeed, label="Min Cruise Airspeed", xlabel="Wing Loading (WS)", ylabel="Min Cruise Airspeed (Vc)", title="Min Cruise Airspeed vs. Wing Loading")
ylims!(0, .2)
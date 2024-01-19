# Electromagnetic Constants
# Contains universal electromagnetic constants and fundamental helper functions
# for EM-related calculations and analysis

# Note no conflict with Euler's number ℯ
𝑒 = 1.602_176_634e-19   # [C]   Elementary charge
ℎ = 6.626_070_15e-34    # [J⋅s] Planck constant
𝛼 = 1/137.035_999_084   # []    Fine structure constant \italpha
𝑐 = 299_792_458         # [m/s] Speed of light in vacuum

𝜖 = (𝑒^2)/(2*𝛼*ℎ*𝑐)         # [F/m] Permittivity of free space
𝜇 = 4π*1.000_000_000_55e-7  # [H/m] Permeabilitiy of free space

function ϵ(ϵ_r)
    ϵ_r * 𝜖
end

function μ(μ_r)
    μ_r * 𝜇
end

# Conversions
function 𝑓_from_ω(ω)
    ω/2π
end

function ω_from_𝑓(𝑓)
    2π*𝑓
end
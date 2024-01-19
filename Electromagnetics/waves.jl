# Electromagnetic Waves
# Helper functions for electromagnetic waves

@enum Basis î ĵ k̂

struct Vector
    x
    y
    z
end

function mag(v::Vector)::Number
    √(v.x^2+v.y^2+v.z^2)
end

function arg(v::Vector)::Vector
    magnitude = mag(v)
    Vector((v.x/magnitude), v.y/magnitude, v.z/magnitude)
end

function ×(m::Number, b::Basis)
    if (b == î)
        Vector(m, 0, 0)
    elseif (b == ĵ)
        Vector(0, m, 0)
    elseif (b == k̂)
        Vector(0, 0, m)
    else
        error
    end
end

function ×(a::Vector, b::Vector)

end

function ×(a, b::Vector)
    Vector(a * b.x, a * b.y, a * b.z)
end

function ×(a::Basis, b::Basis)
    if a == b
        0
    elseif a == i && b == j
        k
    elseif a == j && b == k
        i
    elseif a == k && b == i
        j
    elseif a == j && b == i
        -k
    elseif a == k && b == j
        -i
    elseif a == i && b == k
        -j
    end
end

# E = A e^{-αz} sin(ωt-βz+ψ)
struct wave
    A               # Amplitude (E₀ or H₀)
    trig::Function  # sin or cos
    ω
    β
    ψ
end

function E(E₀, α, ω, β, )
    
end

function 𝐄(𝐇)

end

# 𝐇(z,t) given 𝐄(z,t)
function 𝐇(𝐄)
    
end

# 𝐄(z,t) = E₀ℯ^{-αz}cos(ωt-βz)̂𝐱
function α(ω, μ, ϵ, σ)
    ω * √(((μ*ϵ)/2)*(√(1+(σ/(ω*ϵ))^2)-1))
end

function β(ω, μ, ϵ, σ)
    ω * √(((μ*ϵ)/2)*(√(1+(σ/(ω*ϵ))^2)+1))
end

# 𝐇(z,t) = (E₀/|η|)e^{-αz}cos(ωt-βz-θₙ)̂𝐲
function η(μ, ϵ, σ, ω)
    √((im*ω*μ)/(σ+im*ω*ϵ))
end

function tanθ(σ, ω, ϵ)
    σ/(ω*ϵ)
end

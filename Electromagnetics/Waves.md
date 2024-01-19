# Wave Parameters
For waves of the form $\vec E(z,t)=E_0e^{-\alpha z}\cos{(\omega t-\beta z)}\hat{\vec x}$
## `α`
```julia
function α(ω, μ, ϵ, σ)
    ω * √(((μ*ϵ)/2)*(√(1+(σ/(ω*ϵ))^2)-1))
end
```
Finds $\alpha$, a part of $\gamma=\alpha+j\beta$.
## `β`
```julia 
function β(ω, μ, ϵ, σ)
    ω * √(((μ*ϵ)/2)*(√(1+(σ/(ω*ϵ))^2)+1))
end
```
Finds $\beta$, a part of $\gamma=\alpha+j\beta$.

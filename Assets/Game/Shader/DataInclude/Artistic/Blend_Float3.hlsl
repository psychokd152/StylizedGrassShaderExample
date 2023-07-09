//BLEND - ARTISTIC - COMMON SHADER FUNCTIONS

//Burn
float3 Unity_Blend_Burn(float3 Base, float3 Blend, float Opacity)
{
    float3 Out =  1.0 - (1.0 - Blend)/Base;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Darken
float3 Unity_Blend_Darken(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = min(Blend, Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Difference
float3 Unity_Blend_Difference(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = abs(Blend - Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Dodge
float3 Unity_Blend_Dodge(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Base / (1.0 - Blend);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Divide
float3 Unity_Blend_Divide(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Base / (Blend + 0.000000000001);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Exclusion
float3 Unity_Blend_Exclusion(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Blend + Base - (2.0 * Blend * Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// HardLight
float3 Unity_Blend_HardLight(float3 Base, float3 Blend, float Opacity)
{
    float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float3 result2 = 2.0 * Base * Blend;
    float3 zeroOrOne = step(Blend, 0.5);
    float3 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// HardMix
float3 Unity_Blend_HardMix(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = step(1 - Base, Blend);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Lighten
float3 Unity_Blend_Lighten(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = max(Blend, Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearBurn
float3 Unity_Blend_LinearBurn(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Base + Blend - 1.0;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearDodge
float3 Unity_Blend_LinearDodge(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Base + Blend;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearLight
float3 Unity_Blend_LinearLight(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Blend < 0.5 ? max(Base + (2 * Blend) - 1, 0) : min(Base + 2 * (Blend - 0.5), 1);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearLightAddSub
float3 Unity_Blend_LinearLightAddSub(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Blend + 2.0 * Base - 1.0;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Multiply
float3 Unity_Blend_Multiply(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Base * Blend;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Negation
float3 Unity_Blend_Negation(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = 1.0 - abs(1.0 - Blend - Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Overlay
float3 Unity_Blend_Overlay(float3 Base, float3 Blend, float Opacity)
{
    float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float3 result2 = 2.0 * Base * Blend;
    float3 zeroOrOne = step(Base, 0.5);
    float3 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// PinLight
float3 Unity_Blend_PinLight(float3 Base, float3 Blend, float Opacity)
{
    float3 check = step (0.5, Blend);
    float3 result1 = check * max(2.0 * (Base - 0.5), Blend);
    float3 Out = result1 + (1.0 - check) * min(2.0 * Base, Blend);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Screen
float3 Unity_Blend_Screen(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// SoftLight
float3 Unity_Blend_SoftLight(float3 Base, float3 Blend, float Opacity)
{
    float3 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
    float3 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
    float3 zeroOrOne = step(0.5, Blend);
    float3 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Subtract
float3 Unity_Blend_Subtract(float3 Base, float3 Blend, float Opacity)
{
    float3 Out = Base - Blend;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// VividLight
float3 Unity_Blend_VividLight(float3 Base, float3 Blend, float Opacity)
{
    float3 result1 = 1.0 - (1.0 - Blend) / (2.0 * Base);
    float3 result2 = Blend / (2.0 * (1.0 - Base));
    float3 zeroOrOne = step(0.5, Base);
    float3 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Overwrite
float3 Unity_Blend_Overwrite(float3 Base, float3 Blend, float Opacity)
{
    return lerp(Base, Blend, Opacity);
}
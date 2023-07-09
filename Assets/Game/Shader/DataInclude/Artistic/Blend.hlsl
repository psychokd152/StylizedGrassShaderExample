//BLEND - ARTISTIC - COMMON SHADER FUNCTIONS

//Burn
float4 Unity_Blend_Burn(float4 Base, float4 Blend, float Opacity)
{
    float4 Out =  1.0 - (1.0 - Blend)/Base;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Darken
float4 Unity_Blend_Darken(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = min(Blend, Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Difference
float4 Unity_Blend_Difference(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = abs(Blend - Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Dodge
float4 Unity_Blend_Dodge(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base / (1.0 - Blend);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Divide
float4 Unity_Blend_Divide(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base / (Blend + 0.000000000001);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Exclusion
float4 Unity_Blend_Exclusion(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Blend + Base - (2.0 * Blend * Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// HardLight
float4 Unity_Blend_HardLight(float4 Base, float4 Blend, float Opacity)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float4 result2 = 2.0 * Base * Blend;
    float4 zeroOrOne = step(Blend, 0.5);
    float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// HardMix
float4 Unity_Blend_HardMix(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = step(1 - Base, Blend);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Lighten
float4 Unity_Blend_Lighten(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = max(Blend, Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearBurn
float4 Unity_Blend_LinearBurn(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base + Blend - 1.0;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearDodge
float4 Unity_Blend_LinearDodge(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base + Blend;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearLight
float4 Unity_Blend_LinearLight(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Blend < 0.5 ? max(Base + (2 * Blend) - 1, 0) : min(Base + 2 * (Blend - 0.5), 1);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// LinearLightAddSub
float4 Unity_Blend_LinearLightAddSub(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Blend + 2.0 * Base - 1.0;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Multiply
float4 Unity_Blend_Multiply(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base * Blend;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Negation
float4 Unity_Blend_Negation(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = 1.0 - abs(1.0 - Blend - Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Overlay
float4 Unity_Blend_Overlay(float4 Base, float4 Blend, float Opacity)
{
    float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
    float4 result2 = 2.0 * Base * Blend;
    float4 zeroOrOne = step(Base, 0.5);
    float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// PinLight
float4 Unity_Blend_PinLight(float4 Base, float4 Blend, float Opacity)
{
    float4 check = step (0.5, Blend);
    float4 result1 = check * max(2.0 * (Base - 0.5), Blend);
    float4 Out = result1 + (1.0 - check) * min(2.0 * Base, Blend);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Screen
float4 Unity_Blend_Screen(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// SoftLight
float4 Unity_Blend_SoftLight(float4 Base, float4 Blend, float Opacity)
{
    float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
    float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
    float4 zeroOrOne = step(0.5, Blend);
    float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Subtract
float4 Unity_Blend_Subtract(float4 Base, float4 Blend, float Opacity)
{
    float4 Out = Base - Blend;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// VividLight
float4 Unity_Blend_VividLight(float4 Base, float4 Blend, float Opacity)
{
    float4 result1 = 1.0 - (1.0 - Blend) / (2.0 * Base);
    float4 result2 = Blend / (2.0 * (1.0 - Base));
    float4 zeroOrOne = step(0.5, Base);
    float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
    Out = lerp(Base, Out, Opacity);
    return Out;
}

// Overwrite
float4 Unity_Blend_Overwrite(float4 Base, float4 Blend, float Opacity)
{
    return lerp(Base, Blend, Opacity);
}
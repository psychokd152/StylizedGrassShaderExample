//NORMAL - ARTISTIC - COMMON SHADER FUNCTIONS

float3 Unity_NormalBlend(float3 A, float3 B)
{
    return normalize(float3(A.rg + B.rg, A.b * B.b));
}
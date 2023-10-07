//Include this in Vertex Shader 

float3 worldPos00 = mul(unity_ObjectToWorld, v.vertex); //worldPos00 for not conflict with other
float2 uv = v.texcoord;

//Plant Movement
#if _SWAYING_ON
    float noise = Unity_GradientNoise(uv + _Time.y * float2(_WindSpeed, 0), 5);
    noise *= _WindIntensity;

    #if _USEWINDNOISETEX_ON
        float2 uvTexLod = (worldPos00.xz + worldPos00.y)/_WindNoiseTexScale + _Time.x * _NoiseSpeed;
        float windNoise = tex2Dlod(_WindNoiseTex, float4(uvTexLod, 0, 0)).r;
        windNoise = smoothstep(_NoiseContrast.z, _NoiseContrast.w, windNoise);
        windNoise *= -_WindWeight;
    #else
        float windNoise = Unity_SimpleNoise(worldPos00.xz + worldPos00.y + _Time.y * _NoiseSpeed, 0.5);
        windNoise = smoothstep(_NoiseContrast.x, _NoiseContrast.y, windNoise);
        windNoise *= - _WindWeight;
    #endif

    float3 offset = (noise + windNoise) * float3(1,0,1) * tex2Dlod(_WindMask, float4(uv, 0, 0)).r;

    offset = mul(unity_WorldToObject, offset); //convert offset to object space

    v.vertex.xyz += offset;

#endif


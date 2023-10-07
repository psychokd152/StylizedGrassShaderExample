Shader "BIRP/Nature/TerrainShade" {
    Properties 
    {
        [HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
        [HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)

        [Header(Lighting)] [Space(10)]
        [Ramp] _Ramp ("Light Ramp", 2D) = "white" {} [Space(10)]
        [Toggle] _Shading ("Shading", Float) = 1

        [Header(Grass Layer)] [Space(10)]
        [Tex(_, _)] _GrassTex ("Grass Texture", 2D) = "black" {}
        _GrassSpread ("Grass Spread", Vector) = (0,1,0,0)
        _GrassHue ("Grass Hue", Range(-180, 180)) = 0
        _GrassColor ("Grass Color", Color) = (1,1,1,1)

        _NoiseTex01 ("Noise Texture", 2D) = "black" {}
        _NoiseContrast01 ("Noise Contrast (2)", Vector) = (0,1,0,0)
        _GrassColor01 ("Grass Color", Color) = (1,1,1,1)

        [Header(Dirt Layer)] [Space(10)]
        [Tex(_, _)] _DirtTex ("Dirt Texture", 2D) = "black" {}
        [Tex(_, _)] _DirtMap ("Additional Dirt Map", 2D) = "black" {}
        _MaxDirtValue ("Max Dirt Value", Range(0, 1)) = 1
        _DirtBlendGrass ("Grass Blend", Range(0, 1)) = 0.25
        _DirtBlendMud ("Mud Blend", Range(0, 1)) = 0.5

        [Header(Cliff Layer)] [Space(10)]
        [Tex(_, _)] _CliffTex ("Cliff Texture", 2D) = "black" {}
        _CliffSpread ("Cliff Spread", Vector) = (0,1,0,0)

        [Header(Fog)] [Space(10)]
        [Ramp] _RampDistanceFog ("Distance Fog Ramp", 2D) = "white" {} [Space(10)]
        _NearFarFog ("Near Far Fog Distance (2)", Vector) = (0,1,0,0)
        _FogNoiseTex01 ("Noise Texture", 2D) = "white" {}
        _FogNoiseContrast01 ("Noise Contrast (2)", Vector) = (0,1,0,0)
        _FogNoiseSpeed ("Noise Speed", Range(0, 5)) = 1

    }

    SubShader 
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surf ToonRamp addshadow fullforwardshadows
        // #pragma multi_compile_fog // needed because finalcolor oppresses fog code generation.
        #pragma target 3.0

        #include "UnityPBSLighting.cginc"

        // #pragma multi_compile_local __ _ALPHATEST_ON
        // #pragma multi_compile_local __ _NORMALMAP

        #pragma shader_feature _SHADING_ON

        #include "Assets/Game/Shader/DataInclude/CommonShaderFunctions.hlsl"

        sampler2D _GrassTex;
        sampler2D _Ramp, _RampGrass;

        float4 _GrassSpread;
        float _GrassHue;
        float4 _GrassColor;

        sampler2D _NoiseTex01; float4 _NoiseTex01_ST;
        float4 _GrassColor01;
        float2 _NoiseContrast01;
        
        sampler2D _DirtTex, _DirtMap;
        float _MaxDirtValue;
        float _DirtBlendGrass, _DirtBlendMud;

        sampler2D _CliffTex;
        float4 _CliffSpread;

        sampler2D _RampDistanceFog, _FogNoiseTex01; float4 _FogNoiseTex01_ST;
        float4 _NearFarFog;
        float2 _FogNoiseContrast01;
        float _FogNoiseSpeed;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };


        inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
        {
            #ifndef USING_DIRECTIONAL_LIGHT
            lightDir = normalize(lightDir);
            #endif
            // Wrapped lighting
            half d = dot (s.Normal, lightDir) * 0.5 + 0.5;
            // Applied through ramp
            half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;
            half4 c;
            #if _SHADING_ON
                c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2); //use only s.Albedo for unlit shade & render SplatMap
            #else
                c.rgb = s.Albedo;
            #endif

            c.a = 0;
            return c;
        }

        float3 TriPlanarSample(sampler2D Tex, float3 worldPos, float3 worldNormal)
        {
            float3 X = tex2D(Tex, worldPos.yz);
            float3 Y = tex2D(Tex, worldPos.xz);
            float3 Z = tex2D(Tex, worldPos.xy);

            float3 blendNormal = saturate( pow( worldNormal * 1.4, 4));
            float3 blendedTex = Z;

            blendedTex = lerp(blendedTex, X, blendNormal.x);
            blendedTex = lerp(blendedTex, Y, blendNormal.y);

            return blendedTex;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float2 uvWorldPos = IN.worldPos.xz / 20;
            half3 grass = tex2D(_GrassTex, uvWorldPos) * _GrassColor;
            half3 dirt = tex2D(_DirtTex, uvWorldPos);
            half3 cliff = tex2D(_CliffTex, uvWorldPos);

            half3 color = 0;

        //Blending Scale for Terrain Layer

            //Grass Layer
            float grassT = abs(dot(normalize(o.Normal), float3(0,1,0)));
            grassT = smoothstep(_GrassSpread.x, _GrassSpread.y, grassT);

            //Dirt Layer
            float dirtT = tex2D(_DirtMap, uvWorldPos).r;

            //Cliff Layer
            float cliffT = abs(dot(normalize(o.Normal), float3(0,1,0)));
            cliffT = 1 - smoothstep(_CliffSpread.x, _CliffSpread.y, cliffT);

        //Grass Shading
            float noise = Unity_SimpleNoise(uvWorldPos, 3);
            noise = smoothstep(0.1, 0.5, noise);

            half3 grassHue = Unity_Hue_Degrees(grass, noise * _GrassHue);
            grass = lerp(grass, grassHue, noise);

            half3 noise01 = tex2D(_NoiseTex01, uvWorldPos / _NoiseTex01_ST.xx);
            noise01 = smoothstep(_NoiseContrast01.x, _NoiseContrast01.y, noise01);

            grass = lerp(grass, _GrassColor01, noise01);



        //Generated Splash Map
            float4 genSplashMap = 0;
            genSplashMap.r = grassT * (1 - smoothstep(0, _DirtBlendGrass, dirtT)); //remove Grass from Dirt Map
            genSplashMap.g = smoothstep(0, _DirtBlendMud, dirtT); //Dirt from Dirt Map
            genSplashMap.b = saturate( cliffT * (1 - grassT) * (1 - genSplashMap.g) ); //remove Cliff at Dirt & Grass Layer

            genSplashMap.g = saturate( genSplashMap.g + (1 - genSplashMap.r) * (1 - genSplashMap.b) ); //add Dirt where not Grass & Cliff
            genSplashMap.g = clamp(0, _MaxDirtValue, genSplashMap.g);

            genSplashMap.r = saturate( genSplashMap.r - (1 - genSplashMap.r) * (1 - genSplashMap.b) ); //remove Grass at Dirt Layer


        // Terrain Final Shading
            color += grass * genSplashMap.r;
            color += dirt * genSplashMap.g;
            color += cliff * genSplashMap.b;

        //Distance Fog
            half fogNoise = tex2D(_FogNoiseTex01, uvWorldPos / _FogNoiseTex01_ST.xx + _Time.x * _FogNoiseSpeed/5);
            float distanceFog = smoothstep(_NearFarFog.x, _NearFarFog.y, length(_WorldSpaceCameraPos - IN.worldPos));
            distanceFog *= smoothstep(_FogNoiseContrast01.x, _FogNoiseContrast01.y, fogNoise);
            half3 distanceFogColor = tex2D(_RampDistanceFog, distanceFog);

            // color = lerp(color, distanceFogColor, distanceFog);

            o.Albedo = color;

            o.Alpha = 1;
        }

        ENDCG
    }

    CustomEditor "LWGUI.LWGUI"

}
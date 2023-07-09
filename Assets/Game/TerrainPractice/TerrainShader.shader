Shader "BIRP/Nature/Terrain" {
    Properties 
    {
        // used in fallback on old cards & base map
        [HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
        [HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)
        [HideInInspector] _TerrainHolesTexture("Holes Map (RGB)", 2D) = "white" {}

        [Header(Lighting)] [Space(10)]
        [Ramp] _Ramp ("Light Ramp", 2D) = "white" {} [Space(10)]
        [Toggle] _Shading ("Shading", Float) = 1

        [Header(Grass Layer)] [Space(10)]
        [Toggle] _TriPlanarGrass ("Triplanar Mapping", Float) = 0
        _GrassSpread ("Grass Spread", Vector) = (0,1,0,0)
        _GrassTint ("Grass Texture Tint", Color) = (1,1,1,1)
        _GrassHue ("Grass Hue", Range(-180, 180)) = 0

        _NoiseTex01 ("Noise Texture", 2D) = "black" {}
        _NoiseContrast01 ("Contrast (2)", Vector) = (0,1,0,0)
        _GrassColor01 ("Grass Color", Color) = (1,1,1,1)

        [Header(Dirt Layer)] [Space(10)]
        _DirtMap ("Additional Dirt Map", 2D) = "black" {}
        _MaxDirtValue ("Max Dirt Value", Range(0, 1)) = 1
        _DirtBlendGrass ("Grass Blend", Range(0, 1)) = 0.25
        _DirtBlendMud ("Mud Blend", Range(0, 1)) = 0.5

        [Header(Cliff Layer)] [Space(10)]
        _CliffSpread ("Cliff Spread", Vector) = (0,1,0,0)

        [Header(Splat Map)] [Space]
        [KeywordEnum(Off, Source, RGBA)] _SplatMap ("Splat Map Preview", Float) = 0


    }

    SubShader 
    {
        Tags 
        {
            "Queue" = "Geometry-100"
            "RenderType" = "Opaque"
            "TerrainCompatible" = "True"
        }

        CGPROGRAM
        #pragma surface surf ToonRamp vertex:SplatmapVert finalcolor:SplatmapFinalColor finalgbuffer:SplatmapFinalGBuffer addshadow fullforwardshadows
        #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd
        #pragma multi_compile_fog // needed because finalcolor oppresses fog code generation.
        #pragma target 3.0
        #include "UnityPBSLighting.cginc"

        #pragma multi_compile_local __ _ALPHATEST_ON
        #pragma multi_compile_local __ _NORMALMAP

        #pragma shader_feature _TRIPLANARGRASS_ON
        #pragma shader_feature _SHADING_ON
        #pragma multi_compile _SPLATMAP_OFF _SPLATMAP_SOURCE _SPLATMAP_RGBA

        #define TERRAIN_STANDARD_SHADER
        #define TERRAIN_INSTANCED_PERPIXEL_NORMAL
        #define TERRAIN_SURFACE_OUTPUT SurfaceOutput

        #include "Assets/Game/Shader/DataInclude/CommonShaderFunctions.hlsl"

        #include "TerrainSplatmapCommon_Custom.cginc"

        half _Metallic0;
        half _Metallic1;
        half _Metallic2;
        half _Metallic3;

        half _Smoothness0;
        half _Smoothness1;
        half _Smoothness2;
        half _Smoothness3;

        sampler2D _GrassTex;
        sampler2D _Ramp, _RampGrass;

        float4 _GrassSpread;
        float4 _GrassTint;
        float _GrassHue;
        sampler2D _NoiseTex01; float4 _NoiseTex01_ST;
        float4 _GrassColor01;
        float2 _NoiseContrast01;
        
        sampler2D _DirtMap;
        float _MaxDirtValue;
        float _DirtBlendGrass, _DirtBlendMud;

        float4 _CliffSpread;


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
            half4 splat_control;
            half weight;
            fixed4 mixedDiffuse;

            float3 worldNormal = o.Normal;

            half4 defaultSmoothness = half4(_Smoothness0, _Smoothness1, _Smoothness2, _Smoothness3);

            SplatmapMix(IN, defaultSmoothness, splat_control, weight, mixedDiffuse, o.Normal);

            float2 uvSplat0 = TRANSFORM_TEX(IN.tc.xy, _Splat0);
            float2 uvSplat1 = TRANSFORM_TEX(IN.tc.xy, _Splat1);
            float2 uvSplat2 = TRANSFORM_TEX(IN.tc.xy, _Splat2);
            float2 uvSplat3 = TRANSFORM_TEX(IN.tc.xy, _Splat3);

            #if _TRIPLANARGRASS_ON
                half3 grass = TriPlanarSample(_Splat0, IN.worldPos/10, worldNormal);
                half3 dirt = TriPlanarSample(_Splat1, IN.worldPos/1000, worldNormal);
                half3 cliff = TriPlanarSample(_Splat2, IN.worldPos/10, worldNormal);
            #else
                half3 grass = tex2D(_Splat0, uvSplat0) * _GrassTint;
                half3 dirt = tex2D(_Splat1, uvSplat1);
                half3 cliff = tex2D(_Splat2, uvSplat2);
            #endif

            half3 color = 0;

        //Blending Scale for Terrain Layer

            //Grass Layer
            float grassT = abs(dot(normalize(o.Normal), float3(0,1,0)));
            grassT = 1 - smoothstep(_GrassSpread.x, _GrassSpread.y, grassT);

            //Dirt Layer
            float dirtT = tex2D(_DirtMap, IN.tc.xy).r;

            //Cliff Layer
            float cliffT = abs(dot(normalize(o.Normal), float3(0,1,0)));
            cliffT = smoothstep(_CliffSpread.x, _CliffSpread.y, cliffT);

        //Grass Shading
            float noise = Unity_SimpleNoise(uvSplat0, 3);
            noise = smoothstep(0.1, 0.5, noise);

            half3 grassHue = Unity_Hue_Degrees(grass, noise * _GrassHue);
            grass = lerp(grass, grassHue, noise);

            half3 noise01 = tex2D(_NoiseTex01, IN.worldPos.xz / _NoiseTex01_ST.xx);
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
            color = Unity_Blend_Lighten(color.rgb, dirt * genSplashMap.g, 1);
            color += cliff * genSplashMap.b;

        // SplatMap 
            // float4 genSplashMap = float4(grassT, (1 - grassT) * (1 - cliffT), cliffT, 0); //splat_control generate from shader, set o.Alpha = 1 to get right result.

            #if _SPLATMAP_SOURCE
                color = splat_control.rgb;
            #elif _SPLATMAP_RGBA
                color.rgb = genSplashMap.rgb;
            #endif

            o.Albedo = color;

            o.Alpha = 1;//weight;
            // o.Smoothness = 0; //mixedDiffuse.a;
            // o.Metallic = 0; //dot(splat_control, half4(_Metallic0, _Metallic1, _Metallic2, _Metallic3));
        }

        ENDCG

        // UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
        // UsePass "Hidden/Nature/Terrain/Utilities/SELECTION"
    }

    // Dependency "AddPassShader"    = "Hidden/TerrainEngine/Splatmap/Standard-AddPass"
    // Dependency "BaseMapShader"    = "Hidden/TerrainEngine/Splatmap/Standard-Base"
    // Dependency "BaseMapGenShader" = "Hidden/TerrainEngine/Splatmap/Standard-BaseGen"

    // Fallback "Nature/Terrain/Diffuse"
    CustomEditor "LWGUI.LWGUI"

}
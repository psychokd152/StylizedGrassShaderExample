// ToonyPlants shader  by KD. Dat Nguyen 
// https://twitter.com/psychokd152

Shader "BIRP/ToonyPlants"
{
    Properties
    {
        [Header(Plant Color)] [Space(10)]
        [Tex(_, _Color)] _MainTex ("Albedo (RGB)", 2D) = "white" {} [Space]
        [Toggle] _UseTex ("Use Texture Color", Float) = 1
        [HideInInspector] _Color ("Tint Color", Color) = (1,1,1,1) [Space]
        _Cutoff ("Alpha Threshold", Range(0, 1)) = 0.5
        [Space]
        _UVContrast ("Height Blend Contrast (2-2)", Vector) = (0,1,0,0)
        [Vector2] _NearFarRange("Near Far Range (2)", Vector) = (0,50,0,0)
        _TopColorNear ("Top Color - N", Color) = (1,1,1,1)
        _TopColor ("Top Color - F", Color) = (1,1,1,1)
        _BottomColor ("Bottom Color", Color) = (1,1,1,1)
        // _WindNoiseColor ("Wind Noise Color", Color) = (1,1,1,1)

        [Header(Lighting)] [Space(10)]
        _SSSColor ("SSS Color", Color) = (1,1,1,1) 
        _ShadowSat ("Shadow Saturation", Range(0.01, 5)) = 2
        _ShadowHueOffset ("Shadow Hue Offset", Range(-180, 180)) = 30

        [Header(Wind Noise Control)] [Space(10)]
        [Tex(_, _UseWindNoiseTex)] _WindNoiseTex ("Wind Noise Texture (R)", 2D) = "black" {}
        [HideInInspector] [Toggle] _UseWindNoiseTex ("Use Texture", Float) = 0     [Space(10)]
        [Vector2] _WindNoiseTexScale ("Noise Scale (2)", Vector) = (128, 64, 0, 0) [Space(10)]
        _NoiseContrast ("Noise Contrast (2-2)", Vector) = (0,1,0,1)
        _NoiseSpeed ("Noise Speed", Range(-10, 10)) = 0

        [Header(Wind Control)] [Space(10)]
        [Toggle] _Swaying ("Swaying", Float) = 1    [Space]
        [Tex(_, _)] _WindMask ("Wind Mask (R)", 2D) = "white" {}
        _WindSpeed ("Wind Speed", Range(-5, 5)) = 0
        _WindWeight ("Wind Weight", Range(-5, 5)) = 0
        _WindIntensity ("Wind Intensity", Range(-5, 5)) = 0

        [Header(Tilt Control)] [Space(10)]
        [Toggle] _GrassTilt ("Enable Grass Tilt", Float) = 0     [Space(10)]
        _MaxTiltPercent("Max Tilt Percent", Range(0, 90)) = 0
        _TiltFactor("Tilt Factor", Range(-1, 1)) = 0

        [Header(Terrain)] [Space]
        [Toggle] _TerrainBlend ("Blend With Terrain", Float) = 1
        [Tex(_, _)] _TerrainRT ("Terrain Color", 2D) = "black" {}
        [Tex(_, _)] _TerrainShadowMask ("Terrain Shadow Mask (R)", 2D) = "white" {}
        [Tex(_, _)] _TerrainNormal ("Terrain Normal", 2D) = "black" {}
        _TerrainSize ("Terrain Size", Float) = 512
        _TerrainOffset ("Terrain Offset", Float) = 0.5
        
    }

    SubShader
    {
        Tags {"Queue" = "Geometry" "RenderType" = "Opaque"}
        Cull Off

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #include "Assets/Game/Shader/DataInclude/CommonShaderFunctions.hlsl"

            #pragma multi_compile_fog

            #pragma shader_feature _USETEX_ON
            #pragma shader_feature _USEWINDNOISETEX_ON
            #pragma shader_feature _SWAYING_ON
            #pragma shader_feature _GRASSTILT_ON
            #pragma shader_feature _TERRAINBLEND_ON

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 positionWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
                // float4 screenPos : TEXCOORD5;
                float3 vertexLighting : TEXCOORD7;

                UNITY_FOG_COORDS(6)
                LIGHTING_COORDS(8,9)    // Macro to send shadow & attenuation to the vertex shader

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex; float4 _MainTex_ST;
            half4 _Color, _TopColor, _TopColorNear, _BottomColor, _WindNoiseColor;
            float4 _UVContrast, _NearFarRange;
            float _Cutoff;

            half4 _SSSColor;
            float _ShadowSat, _ShadowHueOffset;

            sampler2D _WindNoiseTex;
            float2 _WindNoiseTexScale;
            float _NoiseSpeed;
            float4 _NoiseContrast;

            sampler2D _WindMask;
            float _WindSpeed, _WindWeight, _WindIntensity;

            float _MaxTiltPercent, _TiltFactor;

            sampler2D _TerrainRT, _TerrainNormal, _TerrainShadowMask;
            float _TerrainSize, _TerrainOffset;

            v2f vert (appdata_base v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.uv = v.texcoord;
                
                #include "Assets/Game/Shader/BIRP/PlantMovement.hlsl"

                o.pos = UnityObjectToClipPos(v.vertex);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex);

                o.normalWS = UnityObjectToWorldNormal(v.normal);

                o.viewDirWS = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex.xyz));

                UNITY_TRANSFER_FOG(o, o.pos);
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);               // Macro to send shadow & attenuation to the fragment shader.

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                UNITY_SETUP_INSTANCE_ID(i);

            //Setup
                half4 col = tex2D(_MainTex, i.uv);

                float4 positionOS = mul(unity_WorldToObject, i.positionWS);
                float depth = length(_WorldSpaceCameraPos - i.positionWS);
                depth = 1 - smoothstep(_NearFarRange.x, _NearFarRange.y, depth);

                #if _USETEX_ON
                    half3 topColor = col.rgb * _Color;
                #else
                    half3 topColor = lerp(_TopColor, _TopColorNear, depth);
                #endif

            //Lighting-based Color
                half3 ambient = ShadeSH9(half4(i.normalWS, 1));
                half shadow = LIGHT_ATTENUATION(i);

            //Wind Noise Color
                #if _USEWINDNOISETEX_ON
                    half windNoise = tex2D(_WindNoiseTex, (i.positionWS.xz + i.positionWS.y)/_WindNoiseTexScale + _Time.x * _NoiseSpeed);
                    windNoise = smoothstep(_NoiseContrast.z, _NoiseContrast.w, windNoise);
                #else
                    half windNoise = Unity_SimpleNoise(i.positionWS.xz + i.positionWS.y + _Time.y * _NoiseSpeed, 0.5);
                    windNoise = smoothstep(_NoiseContrast.x, _NoiseContrast.y, windNoise);
                #endif

                half3 windColor = lerp(topColor.rgb, _WindNoiseColor.rgb, 1).rgb;
                // topColor = lerp(windColor, topColor, 1 - windNoise);

            //Terrain Color
                float2 terrainUV = i.positionWS.xz / _TerrainSize + _TerrainOffset;

                half3 terrainColor = tex2D(_TerrainRT, terrainUV);
                half terrainShade = tex2D(_TerrainShadowMask, terrainUV).r;
                half3 terrainShadow = lerp(saturate(shadow * 0.5 + 0.5) * ambient + 0.05, 1, step(0.99, shadow) + 1 - terrainShade); //color at other's shadow area
                //should change "saturate(shadow * 0.5 + 0.5) * ambient + 0.05" to a Color, easy to use.
                
                //Realtime Terrain Shade
                // float3 terrainNormal = tex2D(_TerrainNormal, terrainUV);
                // float3x3 TBN = float3x3(float3(1,0,0), float3(0,0,1), float3(0,1,0));
                // terrainNormal = normalize(mul(terrainNormal, TBN));

                // terrainShade = dot(terrainNormal, _WorldSpaceLightPos0) * 2 + 0.3;
                // terrainShade = step(0.2, terrainShade);

                // half3 terrainShadow = lerp(saturate(shadow * 0.5 + 0.5) * ambient + 0.05, 1, step(0.99, shadow) + 1 - terrainShade);

                #if _TERRAINBLEND_ON
                    half3 bottomColor = terrainColor * terrainShadow;
                #else
                    half3 bottomColor = _BottomColor;
                #endif

            //UV.y-based Gradient Color
                // half heightBlend = smoothstep(_UVContrast.x, _UVContrast.y, i.uv.y); //UV

                float3 scale = float3
                (
                    length(unity_ObjectToWorld._m00_m10_m20),
                    length(unity_ObjectToWorld._m01_m11_m21),
                    length(unity_ObjectToWorld._m02_m12_m22)
                );

                half heightBlend = smoothstep(_UVContrast.z / scale.y, _UVContrast.w / scale.y, positionOS.y);

            ///SSS effect
                // float3 L = _WorldSpaceLightPos0;
                // float3 V = normalize(i.positionWS - _WorldSpaceCameraPos);
                // float3 N = i.normalWS;
                // float3 H = normalize(L + N * 1);
            
                // half NdotL = dot(i.normalWS, L);
                // float sssAmount = (1 - pow(saturate(dot(V, -H)), 2)) * smoothstep(0.1, 1, (NdotL/2 + 0.5));
                // sssAmount = 1 - smoothstep(0.1, 1, (NdotL * 0.5 + 0.5));
                // // sssAmount *= shadow;
                // sssAmount *= smoothstep(.5, 1, dot(V, -L));
                // sssAmount *= smoothstep(0, 1, shadow + smoothstep(0.3, 1, NdotL * 0.5 + 0.5));
                // sssAmount *= _SSSColor;

                #if _USETEX_ON
                    half3 hueColor = lerp(Unity_Hue_Degrees(pow(topColor, _ShadowSat), _ShadowHueOffset), topColor, step(0.99, shadow));
                #else
                    col.rgb = lerp(bottomColor, topColor * 0.25 + terrainColor, heightBlend * saturate(depth + windNoise));
                #endif

            //Alpha Clipping
                clip(col.a - _Cutoff);

                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }

            ENDCG
        }

        // // Forward Add Pass
        Pass 
        {
            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
            Blend One One                                           // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd                            // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            #pragma shader_feature _USEWINDNOISETEX_ON
            #pragma shader_feature _SWAYING_ON
            #pragma shader_feature _GRASSTILT_ON
            #include "Assets/Game/Shader/DataInclude/CommonShaderFunctions.hlsl"
            
            struct v2f
            {
                float4  pos         : SV_POSITION;
                float2  uv          : TEXCOORD0;
                float3  lightDir    : TEXCOORD2;
                float3 normal		: TEXCOORD1;
                LIGHTING_COORDS(8, 9)
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            float _MaxTiltPercent, _TiltFactor;

            sampler2D _WindNoiseTex;
            float2 _WindNoiseTexScale;
            float _NoiseSpeed;
            float4 _NoiseContrast;

            sampler2D _WindMask;
            float _WindSpeed, _WindWeight, _WindIntensity;

            v2f vert (appdata_tan v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.uv = v.texcoord;
                
                #include "Assets/Game/Shader/BIRP/PlantMovement.hlsl"
                
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.lightDir = ObjSpaceLightDir(v.vertex);
                
                o.normal = v.normal;
                TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.

                return o;
            }
 
            sampler2D _MainTex;
            // fixed4 _Color;

            fixed4 _LightColor0; // Colour of the light used in this pass.

            fixed4 frag(v2f i) : COLOR
            {   
                UNITY_SETUP_INSTANCE_ID(i);

                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
                float3 lightDirWS = normalize(mul(unity_ObjectToWorld, i.lightDir));
                                
                fixed3 normalWS = UnityObjectToWorldNormal(i.normal);                    
                fixed diff = 1 ; //saturate(dot(normalWS, normalize(_WorldSpaceLightPos0))); //plants don't need this
                diff = saturate(dot(normalWS, lightDirWS));
                
                fixed4 c;
                c.rgb = _LightColor0.rgb * diff * atten;

                c.a = tex.a;
                clip(c.a - 0.5);

                return c;
            }

            ENDCG
        }
        
        // //Shadow Caster Pass
        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
            
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "UnityStandardBRDF.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShadowLibrary.cginc"

            #pragma shader_feature _USEWINDNOISETEX_ON
            #pragma shader_feature _SWAYING_ON
            #pragma shader_feature _GRASSTILT_ON
            #include "Assets/Game/Shader/DataInclude/CommonShaderFunctions.hlsl"

            struct v2f
            {
                V2F_SHADOW_CASTER_NOPOS UNITY_POSITION(pos);
                float2  uv : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;

            float _MaxTiltPercent, _TiltFactor;

            sampler2D _WindNoiseTex;
            float2 _WindNoiseTexScale;
            float _NoiseSpeed;
            float4 _NoiseContrast;

            sampler2D _WindMask;
            float _WindSpeed, _WindWeight, _WindIntensity;

            v2f vert(appdata_tan v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.uv = v.texcoord;

                #include "Assets/Game/Shader/BIRP/PlantMovement.hlsl"

                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            float4 frag(v2f i) : SV_Target
            {   
                UNITY_SETUP_INSTANCE_ID(i);
                fixed4 tex = tex2D(_MainTex, i.uv);
                clip(tex.a - _Cutoff);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

    CustomEditor "LWGUI.LWGUI"

}
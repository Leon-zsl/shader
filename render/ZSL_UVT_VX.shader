/**
 *  Author: Shiliang Zhang
 *  Feel free to contact me if you have any question.
 */
 Shader "ZSL/UV Transform Vertex" {
    Properties {
        _main_color("Main Color", Color) = (1,1,1,1)
        _MainTex("Base Tex(RGB), Alpha(Transparent)", 2D) = "white" {}
        _uv_speed_u("Offset Speed U", Float) = 0
        _uv_speed_v("Offset Speed V", Float) = 0
        _uv_speed_r("Rotate Speed", Float) = 0
        _uv_speed_su("Scale Speed U", Float) = 0
        _uv_speed_sv("Scale Speed V", Float) = 0
    }

    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha
        Fog {Mode Off}

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            fixed4 _main_color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _uv_speed_u;
            float _uv_speed_v;
            float _uv_speed_r;
            float _uv_speed_su;
            float _uv_speed_sv;

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            float2 uvtransform (float2 uv) {
                float2 suv = float2(1 + _uv_speed_su * _Time.z,
                                    1 + _uv_speed_sv * _Time.z);

                float2 duv = float2(_uv_speed_u * _Time.z, 
                                    _uv_speed_v * _Time.z);

                float cs = cos(_uv_speed_r * _Time.z);
                float sn = sin(_uv_speed_r * _Time.z);
                float2x2 rm = float2x2(cs, sn, -sn, cs);

                float2 o = mul(rm, (uv - 0.5) * suv) + 0.5 + duv;
                return o;
            }

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

                float2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.texcoord = uvtransform(uv);
                return o;
            }
            
            fixed4 frag (v2f i) : COLOR
            {
                return _main_color * tex2D(_MainTex, i.texcoord);
            }
            ENDCG
        }
    }
    Fallback "Self-Illumin/Diffuse"
 }

/**
 *  Author: Shiliang Zhang
 *  Feel free to contact me if you have any question.
 */
 Shader "ZSL/Diff-Emmis-UVT-ViewPos" {
    Properties {
        _main_color("Main Color", Color) = (1,1,1,1)
        _diffuse_tex("Base Tex(RGB), Alpha(Mask)", 2D) = "white" {}
        _emission_multiple("Emission Multiple", Float) = 1
        _emmsion_uv_speed_u("Offset Speed U", Float) = 0
        _emmsion_uv_speed_v("Offset Speed V", Float) = 0
        _emmsion_uv_speed_r("Rotate Speed", Float) = 0
        _emission_tex("Emission Tex", 2D) = "black" {}
        _uv_scale("Multiple of view UV", Float) = 1
    }

    SubShader {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        float4 _main_color;
        sampler2D _diffuse_tex;

        float _emission_multiple;
        float _emmsion_uv_speed_u;
        float _emmsion_uv_speed_v;
        float _emmsion_uv_speed_r;
        float _uv_scale;

        sampler2D _emission_tex;

        struct Input {
            float2 uv_diffuse_tex;
            //float3 localNormal;
            float4 localPos;
        };

        void vert(inout appdata_full v, out Input o) {
            o.localPos = v.vertex;
            o.uv_diffuse_tex = v.texcoord;
        }

        void surf (Input IN, inout SurfaceOutput o) {
            float4 tex = tex2D(_diffuse_tex, IN.uv_diffuse_tex);
            float3 c = tex.rgb * _main_color.rgb * _main_color.a;
            o.Albedo = c;

            //use local pos as uv
            float4 p = mul(IN.localPos, UNITY_MATRIX_MVP) * _uv_scale;
            float2 uv = p.xy * 0.5 + 0.5;

            //use local normal as uv
            //float2 uv = IN.localNormal * 0.5 + 0.5;
            //float2 uv = mul(IN.localNormal, float3x3(UNITY_MATRIX_IT_MV)) * 0.5 + 0.5;

            float2 duv = float2(_emmsion_uv_speed_u * _Time.z, 
                                _emmsion_uv_speed_v * _Time.z);

            float cs = cos(_emmsion_uv_speed_r * _Time.z);
            float sn = sin(_emmsion_uv_speed_r * _Time.z);
            float2x2 rm = float2x2(cs, sn, -sn, cs);
            uv = mul(rm, uv - 0.5) + 0.5 + duv;
            
            float4 e = tex2D(_emission_tex, uv);
            e.rgb = e.rgb * _emission_multiple * tex.a;
            o.Emission = e;

            o.Alpha = _main_color.a;
        }
        ENDCG
    }
    Fallback "Self-Illumin/Diffuse"
 }
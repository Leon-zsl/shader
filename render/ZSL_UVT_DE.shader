/**
 *  Author: Shiliang Zhang
 *  Feel free to contact me if you have any question.
 */
 Shader "ZSL/Diff-Emmis-UVT-TEXCOORD1" {
    Properties {
        _main_color("Main Color", Color) = (1,1,1,1)
        _diffuse_tex("Base Tex(RGB), Alpha(Mask)", 2D) = "white" {}
        _emission_multiple("Emission Multiple", Float) = 1
        _emmsion_uv_speed_u("Offset Speed U", Float) = 0
        _emmsion_uv_speed_v("Offset Speed V", Float) = 0
        _emmsion_uv_speed_r("Rotate Speed", Float) = 0
        _emmsion_uv_speed_su("Scale Speed U", Float) = 0
        _emmsion_uv_speed_sv("Scale Speed V", Float) = 0
        _emission_tex("Emission Tex", 2D) = "black" {}
    }

    SubShader {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert

        float4 _main_color;
        sampler2D _diffuse_tex;

        float _emission_multiple;
        float _emmsion_uv_speed_u;
        float _emmsion_uv_speed_v;
        float _emmsion_uv_speed_r;
        float _emmsion_uv_speed_su;
        float _emmsion_uv_speed_sv;

        sampler2D _emission_tex;

        struct Input {
            float2 uv_diffuse_tex;
            float2 uv_emission_tex;
        };

        void surf (Input IN, inout SurfaceOutput o) {
            float4 tex = tex2D(_diffuse_tex, IN.uv_diffuse_tex);
            float3 c = tex.rgb * _main_color.rgb * _main_color.a;
            o.Albedo = c;

            float2 uv = IN.uv_emission_tex;

            float2 suv = float2(1 + _emmsion_uv_speed_su * _Time.z,
                                1 + _emmsion_uv_speed_sv * _Time.z);

            float2 duv = float2(_emmsion_uv_speed_u * _Time.z, 
                                _emmsion_uv_speed_v * _Time.z);

            float cs = cos(_emmsion_uv_speed_r * _Time.z);
            float sn = sin(_emmsion_uv_speed_r * _Time.z);
            float2x2 rm = float2x2(cs, sn, -sn, cs);
            uv = mul(rm, (uv - 0.5) * suv) + 0.5 + duv;
            
            float4 e = tex2D(_emission_tex, uv);
            e.rgb = e.rgb * _emission_multiple * tex.a;
            o.Emission = e;

            o.Alpha = _main_color.a;
        }
        ENDCG
    }
    Fallback "Self-Illumin/Diffuse"
 }
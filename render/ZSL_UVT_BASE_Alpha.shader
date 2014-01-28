/**
 *  Author: Shiliang Zhang
 *  Feel free to contact me if you have any question.
 */
 Shader "ZSL/UV Transform" {
    Properties {
        _main_color("Main Color", Color) = (1,1,1,1)
        _diffuse_tex("Base Tex(RGB)", 2D) = "white" {}
        _uv_speed_u("Offset Speed U", Float) = 0
        _uv_speed_v("Offset Speed V", Float) = 0
        _uv_speed_r("Rotate Speed", Float) = 0
        _uv_speed_su("Scale Speed U", Float) = 0
        _uv_speed_sv("Scale Speed V", Float) = 0
    }

    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        #pragma surface surf Lambert

        float4 _main_color;
        sampler2D _diffuse_tex;

        float _uv_speed_u;
        float _uv_speed_v;
        float _uv_speed_r;
        float _uv_speed_su;
        float _uv_speed_sv;

        struct Input {
            float2 uv_diffuse_tex;
        };

        void surf (Input IN, inout SurfaceOutput o) {
            float2 uv = IN.uv_diffuse_tex;

            float2 suv = float2(1 + _uv_speed_su * _Time.z,
                                1 + _uv_speed_sv * _Time.z);

            float2 duv = float2(_uv_speed_u * _Time.z, 
                                _uv_speed_v * _Time.z);

            float cs = cos(_uv_speed_r * _Time.z);
            float sn = sin(_uv_speed_r * _Time.z);
            float2x2 rm = float2x2(cs, sn, -sn, cs);

            uv = mul(rm, (uv - 0.5) * suv) + 0.5 + duv;
            
            float4 e = tex2D(_diffuse_tex, uv);
            o.Albedo = e.rgb * _main_color.rgb;

            o.Alpha = _main_color.a * e.a;
        }
        ENDCG
    }
    Fallback "Self-Illumin/Diffuse"
 }

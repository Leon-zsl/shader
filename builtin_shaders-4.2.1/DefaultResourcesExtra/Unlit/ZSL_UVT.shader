/**
 *  Author: Shiliang Zhang
 *  Feel free to contact me if you have any question.
 */
 Shader "ZSL/Tex-Emmis-UVT-LocalPos" {
    Properties {
        _main_color("Main Color", Color) = (1,1,1,1)
        _diffuse_tex("Base Tex(RGB), Alpha(Mask)", 2D) = "white" {}
        _emission_multiple("Emission Multiple", Float) = 1
        _emmsion_uv_speed_u("Offset Speed U", Float) = 0
        _emmsion_uv_speed_v("Offset Speed V", Float) = 0
        _emmsion_uv_speed_r("Rotate Speed", Float) = 0
        _emission_tex("Emission Tex", 2D) = "black" {}
        _obj_center("Cube Center", Vector) = (0,0,0,1)
        _obj_size("Cube Size", Vector) = (1,1,1,1)
        //_uv_scale("Multiple of view UV", Float) = 1
    }

    SubShader {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
            
        #include "UnityCG.cginc"

        struct appdata_t {
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            half2 texcoord : TEXCOORD0;
            float4 local_pos: TEXCOORD1;
        };
        
        float4 _main_color;
        sampler2D _diffuse_tex;

        float _emission_multiple;
        float _emmsion_uv_speed_u;
        float _emmsion_uv_speed_v;
        float _emmsion_uv_speed_r;
        float4 _obj_center;
        float4 _obj_size;
        sampler2D _emission_tex;

        v2f vert (appdata_t v)
        {
            v2f o;
            o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
            o.texcoord = TRANSFORM_TEX(v.texcoord, _diffuse_tex);
            o.local_pos = v.vertex;
            return o;
        }
        
        fixed4 frag (v2f i) : COLOR
        {
            fixed4 diff = tex2D(_diffuse_tex, i.texcoord);
            fixed4 diffcol = diff * _main_color;
            diffcol.a = _main_color.a;

            //use local pos as uv
            float4 p = (IN.localPos - _obj_center) * 2 / _obj_size;
            float2 uv = p.xy * 0.5 + 0.5;

            float2 duv = float2(_emmsion_uv_speed_u * _Time.z, 
                                _emmsion_uv_speed_v * _Time.z);

            float cs = cos(_emmsion_uv_speed_r * _Time.z);
            float sn = sin(_emmsion_uv_speed_r * _Time.z);
            float2x2 rm = float2x2(cs, sn, -sn, cs);
            uv = mul(rm, uv - 0.5) + 0.5 + duv;

            fixed4 emmis = tex2D(_emission_tex, uv);
            fixed emmiscol = emmis * _emission_multiple * tex.a;

            fixed4 col = diffcol + emmiscol;
            col.a = diffcol.a;
            return col;
        }
        ENDCG
    }
    Fallback "Unlit/Texture"
 }
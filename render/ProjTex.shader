Shader "ZSL/ProjectTex" {
    Properties {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    }

    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float4x4 _Projector;

            v2f vert(appdata_t v) {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                float4 uv = mul(_Projector, v.vertex);
                uv.xy = uv.xy / uv.w;
                o.texcoord = TRANSFORM_TEX(uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : COLOR {
                fixed4 c = tex2D(_MainTex, i.texcoord) * _Color;
                c.a = _Color.a;
                return c;
            }
            ENDCG
        }
    }
}
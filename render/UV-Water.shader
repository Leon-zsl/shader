Shader "ZSL/UV-Water" {
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
            float2 texcoord0 : TEXCOORD0;
            float2 texcoord1 : TEXCOORD1;
        };

        struct v2f {
            float4 vertex : SV_POSITION;
            float2 texcoord0 : TEXCOORD0;
            float2 texcoord1 : TEXCOORD1;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _MainTex_ST_1;
        fixed4 _Color;

        v2f vert(appdata_t v) {
            v2f o;
            o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
            o.texcoord0 = TRANSFORM_TEX(v.texcoord0, _MainTex);
            o.texcoord1 = v.texcoord1;
            return o;
        }

        fixed4 frag(v2f i) : COLOR {
            fixed4 c;
            c.a = tex2D(_MainTex, i.texcoord1).a * _Color.a;
            c.rgb = tex2D(_MainTex, i.texcoord0).rgb * _Color.rgb;
            return c;
        }
        ENDCG
    }
}
}
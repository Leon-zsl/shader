Shader "ZSL/PostProc/ColorCorrectDepth" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RampTex ("Base (RGB)", 2D) = "black" {}
	}

	SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

		CGPROGRAM
		#pragma vertex vert_img
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _CameraDepthTexture;
		float4 _CameraDepthTexture_ST;

		sampler2D _RampTex;

		fixed _Saturation;

		fixed4 frag (v2f_img i) : COLOR {
			half4 ori = tex2D(_MainTex, i.uv);

			//half2 uv = TRANSFORM_TEX(i.uv, _CameraDepthTexture);
			half2 uv = i.uv;
			half d = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv));
			d = Linear01Depth(d);

			half r = tex2D(_RampTex, half2(ori.r, d)).r;
			half g = tex2D(_RampTex, half2(ori.g, d)).g;
			half b = tex2D(_RampTex, half2(ori.b, d)).b;

			half4 c = half4(r, g, b, ori.a);
			// half lum = Luminance(c.rgb);
			// c.rgb = lerp(half3(lum,lum,lum), c.rgb, _Saturation);
			
			// fixed4 c = fixed4(d, d, d, 1);
			return c;
		}
		ENDCG
	}
	} 
	FallBack Off
}

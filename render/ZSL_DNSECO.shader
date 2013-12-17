/**
 *	Author: Shiliang Zhang
 *	Feel free to contact me if you have any question.
 */
Shader "ZSL/Diff-Norm-Spec-Emis-Cube-Outline"
{
	Properties 
	{
		_main_color("Main Color", Color) = (1,1,1,1)
		_diffuse_tex("Base(RGB) Alpha(A)", 2D) = "white" {}
		_spec_multiple("Specular Multiple", Float) = 1
		_spec_tex("Specular(RGB) Gloss(A)", 2D) = "black" {}
		_normal_map("Normal Map", 2D) = "bump" {}
		_emission_color("Emmision Color", Color) = (1,1,1,1)
		_emission_multiple("Emmision Multiple", Float) = 1
		_emission_tex("Emission Map", 2D) = "black" {}
		_cube_fresnel_power("Reflect Fresnel Power", Float) = 1
		_cube_fresnel_multiple("Reflect Fresnel Multiple", Float) = 1
		_cube_fresnel_bias("Reflect Fresnel Bias", Range(0,1)) = 0
		_cube_color("Reflect Color", Color) = (1,1,1,1)
		_cube_tex("Reflect Cube Map", cube) = "black" {}
		_cube_mask("Reflect Mask Map", 2D) = "black" {}

		_outline_width("Outline Width", Float) = 0
		_outline_color("Outline Color", Color) = (1, 0, 0, 1)
	}
	
	SubShader 
	{
		Tags
		{
			"Queue"="Geometry"
			"IgnoreProjector"="False"
			"RenderType"="Opaque"
		}

		
		Cull Back
		ZWrite On
		ZTest LEqual
		ColorMask RGBA

		CGPROGRAM
		#pragma surface surf BlinnPhongZSL
		#pragma target 3.0


		float4 _main_color;
		sampler2D _diffuse_tex;
		sampler2D _spec_tex;
		float _spec_multiple;
		sampler2D _normal_map;
		float4 _emission_color;
		float _emission_multiple;
		sampler2D _emission_tex;
		samplerCUBE _cube_tex;
		sampler2D _cube_mask;
		float _cube_fresnel_power;
		float _cube_fresnel_multiple;
		float _cube_fresnel_bias;
		float4 _cube_color;

		struct ZSLSurfaceOutput {
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Specular;
			half Gloss;
			half Alpha;
			half3 Rim;
		};

		//Fresnel falloff function for all round application
		float fresnel(half3 normal, half3 eyevec, half power, half multply, half bias)
		{
			normal = normalize(normal);
			eyevec = normalize(eyevec);
			
			half fresnel = saturate(abs(dot(normal, eyevec)));
			fresnel = 1-fresnel;
			fresnel = multply * pow(fresnel, power) + bias;
			
			return saturate(fresnel);
		}

		half4 LightingBlinnPhongZSL (ZSLSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half diff = max (0, dot ( lightDir, s.Normal ));

			half3 h = normalize (lightDir + viewDir);
			half nh = max (0, dot (s.Normal, h));
			//should we use luminance or not?
			//half spec = pow (nh, s.Gloss * 128.0) * Luminance (s.Specular.rgb);
			//why 128?
			half spec = pow (nh, s.Gloss * 128.0);
			//half spec = pow (nh, s.Gloss);
			
			//light
			half4 dif;
			//diff
			dif.rgb = s.Albedo.rgb * _LightColor0.rgb * diff * atten * 2.0;

			//spec
			half3 sp = _spec_multiple * s.Specular.rgb * _LightColor0.rgb * spec * atten * 2.0;

			//fresnel cube
			half3 fr = _cube_color.rgb * s.Rim.rgb * fresnel(s.Normal, viewDir, 
							  								_cube_fresnel_power, 
							  								_cube_fresnel_multiple, 
							  								_cube_fresnel_bias);

			half3 em = _emission_color.rgb * _emission_multiple * s.Emission.rgb;

			half4 c;
			c.rgb = dif.rgb + sp.rgb + fr.rgb + em.rgb;
			c.a = s.Alpha;
			return c;
		}
		
		struct Input {
			float2 uv_diffuse_tex;
			float3 worldRefl;
			INTERNAL_DATA
		};

		void surf (Input IN, inout ZSLSurfaceOutput o) {
			half4 diff = tex2D(_diffuse_tex, (IN.uv_diffuse_tex.xyxy).xy);
			o.Albedo = _main_color * diff;

			half3 norm = half3(UnpackNormal(tex2D(_normal_map, (IN.uv_diffuse_tex.xyxy).xy)).xyz);
			o.Normal = half3(norm.r, -norm.g, norm.b);

			half4 spec = tex2D(_spec_tex,(IN.uv_diffuse_tex.xyxy).xy);
			o.Gloss = spec.a;
			o.Specular = spec;

			half3 emmis = tex2D(_emission_tex, IN.uv_diffuse_tex.xy);
			o.Emission = emmis;

			half4 mask = tex2D(_cube_mask, (IN.uv_diffuse_tex.xyxy).xy);
			float3 worldRefl = WorldReflectionVector (IN, o.Normal);
			half3 rim = texCUBE(_cube_tex, worldRefl).rgb;
			o.Rim.rgb = rim.rgb * mask.a;
			
			o.Alpha = diff.aaaa;
		}
		
		ENDCG

		CGINCLUDE
		#include "UnityCG.cginc"
		
		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			fixed4 color : COLOR;
		};

		struct v2f {
			float4 pos : POSITION;
			float4 color : COLOR;
		};
		
		uniform float _outline_width;
		uniform float4 _outline_color;
		
		v2f vert(appdata v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

			float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			float2 offset = TransformViewToProjection(norm.xy);

			o.pos.xy += offset * o.pos.z * _outline_width;
			o.color = _outline_color * v.color;
			return o;
		}
		ENDCG

		Pass {
			Name "OUTLINE"
			Cull Front
			ZWrite On
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			half4 frag(v2f i) :COLOR { return i.color; }
			ENDCG
		}
	}
	Fallback "Diffuse"
}
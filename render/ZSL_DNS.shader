/**
 *	Author: Shiliang Zhang
 *	Feel free to contact me if you have any question.
 */

Shader "ZSL/Diffuse Normal Specular"
{
	Properties 
	{
		_main_color("Main Color", Color) = (1,1,1,1)
		_diffuse_tex("Base(RGB) Alpha(A)", 2D) = "white" {}
		_spec_multiple("Specular Multiple", Float) = 1
		_spec_tex("Specular(RGB) Gloss(A)", 2D) = "black" {}
		_normal_map("Normal Map", 2D) = "bump" {}
		_emission_tex("Emission Map", 2D) = "black" {}
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
		#pragma surface surf BlinnPhongDHD
		#pragma target 2.0


		float4 _main_color;
		sampler2D _diffuse_tex;
		sampler2D _spec_tex;
		float _spec_multiple;
		sampler2D _normal_map;
		sampler2D _emission_tex;
		sampler2D _rim_tex;

		struct DHDSurfaceOutput {
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Specular;
			half Gloss;
			half Alpha;
			//half3 Rim;
		};
		
		half4 LightingBlinnPhongDHD_PrePass (DHDSurfaceOutput s, half4 light)
		{
			half3 spec = light.a * s.Specular;
			half4 c;
			c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
			c.rgb = c.rgb + s.Emission.rgb;
			c.a = s.Alpha;
			return c;
		}

		half4 LightingBlinnPhongDHD (DHDSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
		{
			half3 h = normalize (lightDir + viewDir);
			
			half diff = max (0, dot ( lightDir, s.Normal ));
			
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Gloss * 128.0);
			
			half4 light;
			light.rgb = _LightColor0.rgb * diff;
			light.w = spec * Luminance (_LightColor0.rgb);
			light *= atten * 2.0;

			half3 sp = light.a * s.Specular;
			half4 c;
			c.rgb = (s.Albedo * light.rgb + light.rgb * sp);
			c.rgb = c.rgb + s.Emission.rgb;
			c.a = s.Alpha;
			return c;
		}
		
		struct Input {
			float2 uv_diffuse_tex;
			float2 uv_normal_map;
			float2 uv_spec_tex;
			float2 uv_emission_tex;
		};

		void surf (Input IN, inout DHDSurfaceOutput o) {
			o.Albedo = 0.0;
			o.Normal = float3(0.0,0.0,1.0);
			o.Emission = 0.0;
			o.Specular = float3(0.0, 0.0, 0.0);
			o.Gloss = 0.0;
			o.Alpha = 1.0;

			float4 diff = tex2D(_diffuse_tex, (IN.uv_diffuse_tex.xyxy).xy);
			float4 norm = float4(UnpackNormal(tex2D(_normal_map, (IN.uv_normal_map.xyxy).xy)).xyz, 1.0);
			float4 spec = tex2D(_spec_tex,(IN.uv_spec_tex.xyxy).xy);
			float4 emission = tex2D(_emission_tex, IN.uv_emission_tex.xy);

			o.Albedo = _main_color * diff;
			o.Normal = normalize(float3(norm.r, -norm.g, norm.b));
			o.Gloss = spec.a;
			o.Specular = spec * _spec_multiple.xxxx;
			o.Alpha = diff.aaaa;
			o.Emission = emission;
		}
		
		ENDCG
	}
	Fallback "Diffuse"
}
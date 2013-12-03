/**
 *  Author: Shiliang Zhang
 *  Feel free to contact me if you have any question.
 */
Shader "ZSL/MoveNormal/Diffuse" {

Properties {
    _MainColor ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
    _AttenTex ("Atten (Alpha)", 2D) = "white" {}
    //_BrightTex ("Brightness (Alpha)", 2D) = "white" {}
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 150

    CGPROGRAM
    #pragma surface surf LambertZSL noforwardadd

    fixed4 _MainColor;
    sampler2D _MainTex;
    sampler2D _AttenTex;
    //sampler2D _BrightTex;

    // inline half3 rotate_vector( half4 quat, half3 vec )
    // {
    //     return vec + 2.0 * cross( cross( vec, quat.xyz ) + quat.w * vec, quat.xyz );
    // }

    // inline fixed4 LightingLambertZSL (SurfaceOutput s, fixed3 lightDir, fixed atten)
    // {
    //     half3 axis = normalize(cross(s.Normal, lightDir));
    //     half angle = radians(_NormalBias);
    //     half sn = sin(angle/2);
    //     half cs = cos(angle/2);
    //     half4 quat = half4(sn * axis, cs);
    //     fixed3 norm = rotate_vector(quat, s.Normal);

    //     fixed diff = max (0, dot (norm, lightDir));
        
    //     fixed4 c;
    //     c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
    //     c.a = s.Alpha;
    //     return c;
    // }

    inline fixed4 LightingLambertZSL (SurfaceOutput s, fixed3 lightDir, fixed atten)
    {
        half uv = dot(s.Normal, lightDir) * 0.5 + 0.5;
        fixed diff = tex2D(_AttenTex, half2(uv, 0)).a;
        //fixed lit = tex2D(_BrightTex, half2(uv, 0)).a;

        fixed4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
        c.a = s.Alpha;
        return c;
    }

    struct Input {
    	float2 uv_MainTex;
    };

    void surf (Input IN, inout SurfaceOutput o) {
    	fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
    	o.Albedo = c.rgb * _MainColor.rgb;
    	o.Alpha = c.a * _MainColor.a;
    }
    ENDCG
}

Fallback "Mobile/Diffuse"
}

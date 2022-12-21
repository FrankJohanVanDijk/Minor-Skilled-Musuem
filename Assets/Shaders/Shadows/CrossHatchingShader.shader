Shader "Custom/CrossHatchingShader"
{
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_LitTex("Light Hatch", 2D) = "white" {}
		_MedTex("Medium Hatch", 2D) = "white" {}
		_HvyTex("Heavy Hatch", 2D) = "white" {}
		_repeat("Repeat Tile", int) = 4
		_color("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		CGPROGRAM
		//#pragma surface surf CrossHatch
		#pragma surface surf StandardCrossHatch fullforwardshadows

		#include "UnityPBSLighting.cginc"
		//#include "UnityGlobalIllumination.cginc"

		sampler2D _MainTex;
		sampler2D _LitTex;
		sampler2D _MedTex;
		sampler2D _HvyTex;
		int _repeat;
		float4 _color;

		struct MySurfaceOutput
		{
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			fixed Gloss;
			fixed Alpha;
			fixed val;
			float2 screenUV;
		};

		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
		};

		void surf(Input IN, inout MySurfaceOutput o) 
		{
			//uncomment to use object space hatching
			o.screenUV = IN.uv_MainTex * _repeat;
			//uncomment to use screen space hatching
			//o.screenUV = IN.screenPos.xy * _repeat / IN.screenPos.w;
			half v = length(tex2D(_MainTex, IN.uv_MainTex).rgb) * 0.33;
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
			o.val = v;
		}

		/*
		half4 LightingCrossHatch(MySurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = dot(s.Normal, lightDir);

			half4 cLit = tex2D(_LitTex, s.screenUV);
			half4 cMed = tex2D(_MedTex, s.screenUV);
			half4 cHvy = tex2D(_HvyTex, s.screenUV);
			half4 c;

			half v = saturate(length(_LightColor0.rgb) * (NdotL * atten * 2) * s.val);

			c.rgb = lerp(cHvy, cMed, v);
			c.rgb = lerp(c.rgb, cLit, v);

			c.rgb *= _color.rgb;
			c.a = s.Alpha;
			c.rgb *= s.Albedo.rgb;
			return c;
		}*/
		/**/
		half4 LightingStandardCrossHatch(MySurfaceOutput s, half3 viewDir, UnityGI gi)
		{
			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard(r, viewDir, gi);
		}

		void LightingStandardCrossHatch_GI(MySurfaceOutput s, UnityGIInput data, inout UnityGI gi)
		{
			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			LightingStandard_GI(r, data, gi);


			half NdotL = dot(s.Normal, gi.light.dir);

			half4 cLit = tex2D(_LitTex, s.screenUV);
			half4 cMed = tex2D(_MedTex, s.screenUV);
			half4 cHvy = tex2D(_HvyTex, s.screenUV);
			half4 c;

			half v = saturate(length(_LightColor0.rgb) * (NdotL * data.atten * 2) * s.val);

			c.rgb = lerp(cHvy, cMed, v);
			c.rgb = lerp(c.rgb, cLit, v);

			c.rgb *= _color.rgb;
			c.a = s.Alpha;
			c.rgb *= s.Albedo.rgb;

			gi.light.color = c;
			gi.indirect.diffuse = c;
			gi.indirect.specular = c;
			//return c;
		}

		ENDCG
	}
	Fallback "Diffuse"
}

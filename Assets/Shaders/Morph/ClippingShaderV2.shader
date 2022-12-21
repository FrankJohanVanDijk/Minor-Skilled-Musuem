Shader "Custom/ClippingShaderV2"
{
    Properties
    {
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normal Texture", 2D) = "white" {}
		_SpecularTex("Specular Texture", 2D) = "white" {}
		_OcclusionTex("Occlusion Map", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 1)) = 0
		//_Metallic("Metalness", Range(0, 1)) = 0
		[HDR] _Emission("Emission", color) = (0,0,0)

		[HDR]_cutoffColor("Cutoff Color", Color) = (1,0,0,0)
    }
    SubShader
    {
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		// render faces regardless if they point towards the camera or away from it
		Cull Off

		CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf StandardSpecular fullfowardshadows
			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 4.0



			sampler2D _MainTex;
			sampler2D _SpecularTex;
			sampler2D _NormalTex;
			sampler2D _OcclusionTex;
			fixed4 _Color;

			half _Smoothness;
			//half _Metallic;
			half3 _Emission;

			float4 _cutoffColor;

			float4 _sphere;

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_NormalTex;
				float2 uv_SpecularTex;
				float2 uv_OcclusionTex;
				float3 worldPos;
				float facing : VFACE; //This variable will have a value of 1 on the outside and a value of -1 on the inside.
			};


        void surf (Input i, inout SurfaceOutputStandardSpecular o)
        {
			//calculate signed distance to plane
			float distanceToSphere = distance(i.worldPos, _sphere.xyz);
			float insideSphere = distanceToSphere < _sphere.w ? -1 : 1;
			clip(insideSphere);

			float facing = i.facing * 0.5 + 0.5; // 1 or 0

			//normal color stuff
			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
			fixed4 normalCol = tex2D(_NormalTex, i.uv_MainTex);
			fixed4 specularCol = tex2D(_SpecularTex, i.uv_SpecularTex);
			fixed4 occlusionCol = tex2D(_OcclusionTex, i.uv_OcclusionTex);

			col *= _Color;
			o.Albedo = col.rgb * facing;
			o.Normal = normalCol.rgb * facing;
			o.Specular = specularCol.rgb * facing;
			o.Occlusion = occlusionCol.r * facing; //It's a black white tex so g and b don't matter
			//o.Metallic = _Metallic * facing;
			o.Smoothness = _Smoothness * facing;
			
#if UNITY_PASS_DEFERRED
			o.Emission = lerp(_cutoffColor, _Emission, facing);
#endif
        }
        ENDCG
    }
    FallBack "Diffuse"
}

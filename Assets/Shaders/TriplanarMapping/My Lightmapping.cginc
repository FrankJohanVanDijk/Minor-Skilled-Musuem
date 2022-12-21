#if !defined(MY_LIGHTMAPPING_INCLUDED)
#define MY_LIGHTMAPPING_INCLUDED

#include "My Lighting Input.cginc"
#include "UnityMetaPass.cginc"

//float4 _Color;
//sampler2D _MainTex, _DetailTex, _DetailMask;
//float4 _MainTex_ST, _DetailTex_ST;

//sampler2D _MetallicMap;
//float _Metallic;
//float _Smoothness;

//sampler2D _EmissionMap;
//float3 _Emission;

/*
struct VertexData {
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
};*/

/*
struct Interpolators {
	float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;
};*/

/*
float GetDetailMask (Interpolators i) {
	#if defined (_DETAIL_MASK)
		return tex2D(_DetailMask, i.uv.xy).a;
	#else
		return 1;
	#endif
}*/

/**
float3 GetAlbedo (Interpolators i) {
	float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
	#if defined (_DETAIL_ALBEDO_MAP)
		float3 details = tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;
		albedo = lerp(albedo, albedo * details, GetDetailMask(i));
	#endif
	return albedo;
}*/
/*
float GetMetallic (Interpolators i) {
	#if defined(_METALLIC_MAP)
		return tex2D(_MetallicMap, i.uv.xy).r;
	#else
		return _Metallic;
	#endif
}*/
/*
float GetSmoothness (Interpolators i) {
	float smoothness = 1;
	#if defined(_SMOOTHNESS_ALBEDO)
		smoothness = tex2D(_MainTex, i.uv.xy).a;
	#elif defined(_SMOOTHNESS_METALLIC) && defined(_METALLIC_MAP)
		smoothness = tex2D(_MetallicMap, i.uv.xy).a;
	#endif
	return smoothness * _Smoothness;
}*/

/*
float3 GetEmission (Interpolators i) {
	#if defined(_EMISSION_MAP)
		return tex2D(_EmissionMap, i.uv.xy) * _Emission;
	#else
		return _Emission;
	#endif
}*/



Interpolators MyLightmappingVertexProgram (VertexData v) {
	Interpolators i;
	i.pos = UnityMetaVertexPosition(
		v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST
	);

	i.normal = UnityObjectToWorldNormal(v.normal);
	i.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex);

	#if !defined(NO_DEFAULT_UV)
		i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
		i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
	#endif

	return i;
}

#if !defined(ALBEDO_FUNCTION)
	#define ALBEDO_FUNCTION GetAlbedo
#endif

float4 MyLightmappingFragmentProgram (Interpolators i) : SV_TARGET {
	SurfaceData surface;
	surface.normal = normalize(i.normal);
	surface.albedo = 1;
	surface.alpha = 1;
	surface.emission = 0;
	surface.metallic = 0;
	surface.occlusion = 1;
	surface.smoothness = 0.5;
	#if defined(SURFACE_FUNCTION)
		SurfaceParameters sp;
		sp.normal = i.normal;
		sp.position = i.worldPos.xyz;
		sp.uv = UV_FUNCTION(i);
		SURFACE_FUNCTION(surface, sp);
	#else
		surface.albedo = ALBEDO_FUNCTION(i);
		surface.emission = GetEmission(i);
		surface.metallic = GetMetallic(i);
		surface.smoothness = GetSmoothness(i);
	#endif
	
	UnityMetaInput surfaceData;
	surfaceData.Emission = surface.emission;
	float oneMinusReflectivity;
	surfaceData.Albedo = DiffuseAndSpecularFromMetallic(
		surface.albedo, surface.metallic,
		surfaceData.SpecularColor, oneMinusReflectivity
	);

	float roughness = SmoothnessToRoughness(surface.smoothness) * 0.5;
	surfaceData.Albedo += surfaceData.SpecularColor * roughness;

	return UnityMetaFragment(surfaceData);
}

#endif
﻿Shader "Custom/TriPlanar Mapping"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _MOHSMap("MOHS", 2D) = "white" {} //Metallic Occlusion Height Smoothness
		[NoScaleOffset] _NormalMap("Normals", 2D) = "white" {}

		[NoScaleOffset] _TopMainTex("Top Albedo", 2D) = "white" {}
		[NoScaleOffset] _TopMOHSMap("Top MOHS", 2D) = "white" {}
		[NoScaleOffset] _TopNormalMap("Top Normals", 2D) = "white" {}

		_MapScale("Map Scale", Float) = 1 //So all maps have the same scale

		_BlendOffset("Blend Offset", Range(0, 0.5)) = 0.25
		_BlendExponent("Blend Exponent", Range(1, 8)) = 2
		_BlendHeightStrength("Blend Height Strength", Range(0, 0.99)) = 0.5
    }
    SubShader
    {
		Pass 
		{
			Tags 
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma target 3.0
			#pragma shader_feature _SEPARATE_TOP_MAPS
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#define FORWARD_BASE_PASS

			#include "MyTriplanarMapping.cginc"
			#include "My Lighting.cginc"

			ENDCG
		}

		Pass 
		{
			Tags 
			{
				"LightMode" = "ForwardAdd"
			}

			Blend One One
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0
			#pragma shader_feature _SEPARATE_TOP_MAPS
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "MyTriplanarMapping.cginc"
			#include "My Lighting.cginc"

			ENDCG
		}

		Pass 
		{
			Tags 
			{
				"LightMode" = "Deferred"
			}

			CGPROGRAM

			#pragma target 3.0
			#pragma shader_feature _SEPARATE_TOP_MAPS
			#pragma exclude_renderers nomrt
			#pragma multi_compile_prepassfinal
			#pragma multi_compile_instancing
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#define DEFERRED_PASS

			#include "MyTriplanarMapping.cginc"
			#include "My Lighting.cginc"

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ShadowCaster"
			}
			
			CGPROGRAM

			#pragma target 3.0

			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing

			#pragma vertex MyShadowVertexProgram
			#pragma fragment MyShadowFragmentProgram
			
			#include "My Shadows.cginc"

			ENDCG
		}

		Pass 
		{
			Tags 
			{
				"LightMode" = "Meta"
			}

			Cull Off

			CGPROGRAM

			#pragma vertex MyLightmappingVertexProgram
			#pragma fragment MyLightmappingFragmentProgram

			#pragma shader_feature _SEPARATE_TOP_MAPS

			#include "MyTriplanarMapping.cginc"
			#include "My Lightmapping.cginc"

			ENDCG
		}
    }

	CustomEditor "MyTriplanarShaderGUI"
}

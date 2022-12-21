Shader "Unlit/OutlineV1"
{
	Properties
	{
		_Color("Normal color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_outlineColor("Outline Color", Color) = (0,0,0,1)
		_outlineWidth("Outline Width", Range(0.0,5.0)) = 1.0
		_SpecColor("Spec Color", Color) = (1,1,1,1)
		_Emission("Emmisive Color", Color) = (0,0,0,0)
		_Shininess("Shininess", Range(0.01, 1)) = 0.7
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata
	{
		float4 vertex : POSITION;
		//float3 normal : NORMAL;
		//float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD1;
		UNITY_FOG_COORDS(1)
		float4 pos : POSITION;
		float3 normal : NROMAL;
		float4 color : COLOR;
	};

	float _outlineWidth;
	float4 _outlineColor;

	v2f vert(appdata v)
	{
		v.vertex.xyz *= _outlineWidth; //Increase the size of the object

		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.color = _outlineColor;

		return o;
	}
	ENDCG

	SubShader
	{
		Tags{ "Queue" = "Transparent"}
		Pass //The outline Pass
		{
			
			Name "Outline"

			Zwrite Off //Always draw this

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			half4 frag(v2f i) : COLOR
			{
				return i.color;
			}
			
			ENDCG
		}

		Pass //The normal render
		{
			//Name "Normal"
			//This a lazy quick way to have your objects rendered normally
			//This is a surface shader pass
			
			Material
			{
				Diffuse[_Color]
				Ambient[_Color]
				Shininess[_Shininess]
				Specular[_SpecColor]
				Emission[_Emission]
			}

			Lighting On

			SetTexture[_MainTex]
			{
				ConstantColor[_Color]
			}

			SetTexture[_MainTex]
			{
				Combine previous * primary DOUBLE
			}
		}
	}
}

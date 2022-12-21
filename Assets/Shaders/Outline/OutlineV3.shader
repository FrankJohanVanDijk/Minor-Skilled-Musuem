Shader "Unlit/OutlineV3"
{
	Properties
	{
		_Color("Normal color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_outlineColor("outline color", Color) = (0,0,0,1)
		_outlineOffset("outline width", Range(0.0, 5.0)) = 1.0
	}


	CGINCLUDE
	#include "UnityCG.cginc"

	struct outlineAppdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};

	struct outlineV2f
	{
		float4 pos : POSITION;
		float3 normal : NORMAL;
		float4 color : COLOR;
		float2 uv : TEXCOORD1;
	};

	float _outlineOffset;
	float4 _outlineColor;

	half4 frag(outlineV2f i) : COLOR
	{
		return _outlineColor;
	}

	ENDCG

	SubShader
	{
		Tags{ "Queue" = "Transparent" }
			// No culling or depth
		Cull Off ZWrite Off ZTest Always



		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.x += _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.x -= _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y += _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y -= _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y -= _outlineOffset;
				o.pos.x -= _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{
			Zwrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y -= _outlineOffset;
				o.pos.x -= _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{
			Zwrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y += _outlineOffset;
				o.pos.x -= _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{
			Zwrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y -= _outlineOffset;
				o.pos.x += _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{
			Zwrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y -= _outlineOffset;
				o.pos.x += _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}
		Pass
		{
			Zwrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"


			outlineV2f vert(outlineAppdata v)
			{
				outlineV2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos.y += _outlineOffset;
				o.pos.x += _outlineOffset;
				o.uv = v.uv;
				return o;
			}

			ENDCG
		}


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			float4 _Color;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgba = col.rgba * _Color;
				return col;
			}
			ENDCG
		}
	}
}

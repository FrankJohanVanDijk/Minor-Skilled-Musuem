// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/OutlineV4"
{
	Properties
	{
		_MainTex("Main Texture",2D) = "black"{}
		_SceneTex("Scene Texture",2D) = "black"{}
		_outlineColor("Outline Color", Color) = (0,0,0,1)
		_outlineSizeX("Outline size x", Int) = 2
		_outlineSizeY("Outline size y", Int) = 2
	}

	
	

	SubShader
	{
		
		Pass
		{
			CGPROGRAM

			sampler2D _MainTex;
			int _outlineSizeX;
			//<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
			float2 _MainTex_TexelSize;

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uvs : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;

				//Despite the fact that we are only drawing a quad to the screen, Unity requires us to multiply vertices by our MVP matrix, presumably to keep things working when inexperienced people try copying code from other shaders.
				o.pos = UnityObjectToClipPos(v.vertex);

				//Also, we need to fix the UVs to match our screen space coordinates. There is a Unity define for this that should normally be used.
				o.uvs = o.pos.xy / 2.0 + 0.5;
				//o.uvs = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}


			float frag(v2f i) : COLOR
			{
				float NumberOfIterations = _outlineSizeX;
				//int NumberOfIterations = 15;
				//split texel size into smaller words
				float TX_x = _MainTex_TexelSize.x;

				//and a final intensity that increments based on surrounding intensities.
				float ColorIntensityInRadius;

				//for every iteration we need to do horizontally
				for (int k = 0; k < NumberOfIterations; k += 1)
				{
					//increase our output color by the pixels in the area
					ColorIntensityInRadius += tex2D(_MainTex,
						i.uvs.xy +
						float2(((float)k - (float)NumberOfIterations / 2.0f)*TX_x, 0)).r /* / NumberOfIterations*/;
				}

				//output some intensity of teal
				return ColorIntensityInRadius / NumberOfIterations;
			}

			ENDCG

		}
		//end pass    

		GrabPass{}

		Pass
		{
			CGPROGRAM
			sampler2D _MainTex;
			sampler2D _SceneTex;
			float4 _outlineColor;
			int _outlineSizeY;

			//we need to declare a sampler2D by the name of "_GrabTexture" that Unity can write to during GrabPass{}
			sampler2D _GrabTexture;

			//<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
			float2 _GrabTexture_TexelSize;
			float2 _MainTex_TexelSize;

			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers d3d11_9x
			#pragma exclude_renderers d3d9
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float2 uvs : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;

				//Despite the fact that we are only drawing a quad to the screen, Unity requires us to multiply vertices by our MVP matrix, presumably to keep things working when inexperienced people try copying code from other shaders.
				o.pos = UnityObjectToClipPos(v.vertex);

				//Also, we need to fix the UVs to match our screen space coordinates. There is a Unity define for this that should normally be used.
				//o.uvs = o.pos.xy / 2.0 + 0.5;
				o.uvs = ComputeScreenPos(o.pos);
				return o;
			}


			float4 frag(v2f i) : COLOR
			{
				//arbitrary number of iterations for now
				float NumberOfIterationss = _outlineSizeY;
				//int NumberOfIterationss = 15;
				//NumberOfIterationss *= _outlineSizeY;
				//split texel size into smaller words
				float TX_y = _GrabTexture_TexelSize.y;
				//float TX_y = _MainTex_TexelSize.y;
				//and a final intensity that increments based on surrounding intensities.
				float4 ColorIntensityInRadius = float4(0,0,0,0);

				//if something already exists underneath the fragment (in the original texture), discard the fragment.
				if (tex2D(_MainTex,i.uvs.xy).r > 0)
				{
					return tex2D(_SceneTex,float2(i.uvs.x, i.uvs.y));
				}

				//for every iteration we need to do vertically
				//[unroll(_outlineSizeY)]
				[loop]
				for (int j = 0; j < NumberOfIterationss; j++)
				{
					//increase our output color by the pixels in the area
					ColorIntensityInRadius += tex2D(_GrabTexture,
													float2(i.uvs.x, 1.0f - i.uvs.y) + 
													float2(0, ((float)j - (float)NumberOfIterationss / 2.0f)* TX_y )) /* / NumberOfIterationss*/;
					//if (j == NumberOfIterationss) {
					//	j = 50;
					//}
				}


				//this is alpha blending, but we can't use HW blending unless we make a third pass, so this is probably cheaper.
				float4 outcolor = (ColorIntensityInRadius.r /NumberOfIterationss) * _outlineColor + (1.0f - ColorIntensityInRadius.r /NumberOfIterationss ) * tex2D(_SceneTex,float2(i.uvs.x, i.uvs.y));
				return outcolor;
			}

			ENDCG

		}
		//end pass    
	}
	//end subshader
}

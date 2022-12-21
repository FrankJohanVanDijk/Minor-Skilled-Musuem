Shader "Unlit/ValkyriaChroniclesShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		_MainTexMask("Texture Mask", 2D) = "black" {}

		[Header(Paint)]
		_MainTexP("Paint Mask", 2D) = "black" {}
		_MainTexB("Paint Back", 2D) = "black" {}
		_progress("Paint Progress ", Float) = 0

		[Header(Outline)]
		_outlineThreshold("Threshold", Range(0, 1)) = 0.1
		_outlineSize("Size ", Range(0, 3000)) = 0
		_outlinecolor("Color",COLOR) = (0, 0, 0, 1)
		_outlineAlpha("Alpha not on mask", Range(0, 1)) = 0.3
		_outlineAlphaMask("Alpha on mask", Range(0, 1)) = 1.0
	}
	SubShader
	{
		Tags {"Queue" = "Geometry" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST; //Scale and Tilling (offset)
			uniform half4 _MainTex_TexelSize; //Vector4(1 / width, 1 / height, width, height)
			sampler2D _MainTexMask;
			half4 _MainTexMask_ST;

			sampler2D _MainTexP;
			sampler2D _MainTexB;
			fixed _progress;

			fixed _outlineThreshold;
			fixed _outlineSize;
			fixed4 _outlinecolor;
			fixed _outlineAlpha;
			fixed _outlineAlphaMask;

			sampler2D _CameraDepthNormalsTexture; //Unity magic

			struct v2f
			{
				fixed2 uvTM : TEXCOORD0;
				half2 uvSilhouetteCollection[5] : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata_img v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uvTM = (v.texcoord - _MainTexMask_ST.zw) * _MainTexMask_ST.xy; //Tilling Mask

				half2 uvSilhouette = (v.texcoord - _MainTex_ST.zw) * _MainTex_ST.xy; //Orginal texture - Offset * Scaling
				fixed2 size = fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y) * _outlineSize;
				//The silhouettes placed in all 4 directions + the orginal position
				//The screensize is taken into account + the outlinesize
				o.uvSilhouetteCollection[0] = uvSilhouette + _MainTex_TexelSize.xy * half2(0, 0)  * size;
				o.uvSilhouetteCollection[1] = uvSilhouette + _MainTex_TexelSize.xy * half2(-1, -1) * size;
				o.uvSilhouetteCollection[2] = uvSilhouette + _MainTex_TexelSize.xy * half2(1, -1) * size;
				o.uvSilhouetteCollection[3] = uvSilhouette + _MainTex_TexelSize.xy * half2(-1, 1) * size;
				o.uvSilhouetteCollection[4] = uvSilhouette + _MainTex_TexelSize.xy * half2(1, 1)  * size;
				

				return o;
			}

			fixed luminance(fixed4 color) {
				//GrayScale (0.222, 0.707, 0.071));
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}
			
			half RobertDepthN(v2f i) {
				#if UNITY_UV_STARTS_AT_TOP
					if (_MainTex_TexelSize.y < 0) 
					{
						i.uvSilhouetteCollection[1].y = 1 - i.uvSilhouetteCollection[1].y;
						i.uvSilhouetteCollection[2].y = 1 - i.uvSilhouetteCollection[2].y;
						i.uvSilhouetteCollection[3].y = 1 - i.uvSilhouetteCollection[3].y;
						i.uvSilhouetteCollection[4].y = 1 - i.uvSilhouetteCollection[4].y;
					}
				#endif		

				float4 LD = tex2D(_CameraDepthNormalsTexture, i.uvSilhouetteCollection[1].xy); //Left Down
				float4 RD = tex2D(_CameraDepthNormalsTexture, i.uvSilhouetteCollection[2].xy); //Right Down
				float4 LU = tex2D(_CameraDepthNormalsTexture, i.uvSilhouetteCollection[3].xy); //Left Up
				float4 RU = tex2D(_CameraDepthNormalsTexture, i.uvSilhouetteCollection[4].xy); //Right Up

				
				half edgenormal = abs(LD.rg - RU.rg) + abs(LU.rg - RD.rg); //Always positive :)
				edgenormal = saturate((1 - edgenormal) / (_outlineThreshold)); //Between 0 and 1

				//EncodeFloatRG : Encodes [0..1) range float into a float2
				//DecodeFloatRG : Decodes a previously-encoded RG float
				half edgedepth = abs(DecodeFloatRG(LD.ba) - DecodeFloatRG(RU.ba)) + abs(DecodeFloatRG(LU.ba) - DecodeFloatRG(RD.ba));
				edgedepth = saturate((1 - edgedepth) / (_outlineThreshold)); //Between 0 and 1
				return edgedepth * edgenormal;

			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 texMain = tex2D(_MainTex, i.uvSilhouetteCollection[0]); //The silhouette is scaled by _outlinesize
				fixed4 texMask = tex2D(_MainTexMask, i.uvTM);
				fixed4 texPaint = tex2D(_MainTexP, i.uvTM);
				fixed4 texBack = tex2D(_MainTexB, i.uvTM);

				half edge = 0;

				fixed4 paperOrPaint = lerp(texBack, texMain, saturate(_progress - luminance(texPaint)));
				fixed4 onmask = lerp(paperOrPaint, texMask, texMask.a);
				edge = RobertDepthN(i); //Between 0 and 1

				fixed alphaOutline = lerp(_outlineAlpha, _outlineAlphaMask, texMask.a);

				fixed ff = (1 - edge) * alphaOutline; //Flip it and times the alpa
				fixed4 sum = lerp(onmask, _outlinecolor, ff); //If detects edge and alpha is high chose outlincolor otherwise render normally
				//sum.a = texMain.a;
				return sum;
			}
			ENDCG
		}
	}
}

Shader "Unlit/OutlineV5"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		[Header(Outline)]
		_outlineThreshold("Threshold", Range(0, 1)) = 0.1
		_outlineSize("Size ", Range(0, 1)) = 0
		_outlinecolor("Color",COLOR) = (0, 0, 0, 1)
    }
    SubShader
    {
		Tags {"Queue" = "Geometry" }
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			sampler2D _MainTex;
			half4 _MainTex_ST; //Scale and Tilling (offset)
			uniform half4 _MainTex_TexelSize; //Vector4(1 / width, 1 / height, width, height)
			fixed _outlineThreshold;
			fixed _outlineSize;
			fixed4 _outlinecolor;

            struct v2f
            {
				half2 uvSilhouetteCollection[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				//half2 uvSilhouette = (v.texcoord - _MainTex_ST.zw) * _MainTex_ST.xy; //Orginal texture - Offset * Scaling
				half2 uvSilhouette = v.texcoord;

				//The silhouettes placed in all 8 directions + the orginal position
				//The screensize is taken into account + the outlinesize
				o.uvSilhouetteCollection[0] = uvSilhouette + _MainTex_TexelSize.xy * half2(-1, -1)* _outlineSize;// TexelSize is the size of the texture. x = 1/width, y = 1/height, z = width, w = height
				o.uvSilhouetteCollection[1] = uvSilhouette + _MainTex_TexelSize.xy * half2(0, -1) * _outlineSize;
				o.uvSilhouetteCollection[2] = uvSilhouette + _MainTex_TexelSize.xy * half2(1, -1) * _outlineSize;
				o.uvSilhouetteCollection[3] = uvSilhouette + _MainTex_TexelSize.xy * half2(-1, 0) * _outlineSize;
				o.uvSilhouetteCollection[4] = uvSilhouette + _MainTex_TexelSize.xy * half2(0, 0)  * _outlineSize;
				o.uvSilhouetteCollection[5] = uvSilhouette + _MainTex_TexelSize.xy * half2(1, 0)  * _outlineSize;
				o.uvSilhouetteCollection[6] = uvSilhouette + _MainTex_TexelSize.xy * half2(-1, 1) * _outlineSize;
				o.uvSilhouetteCollection[7] = uvSilhouette + _MainTex_TexelSize.xy * half2(0, 1)  * _outlineSize;
				o.uvSilhouetteCollection[8] = uvSilhouette + _MainTex_TexelSize.xy * half2(1, 1)  * _outlineSize;

                return o;
            }

			fixed luminance(fixed4 color) {
				//GrayScale (0.222, 0.707, 0.071));
				return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}

			half Robert(v2f i) {

				// L = Left, D = Down, R = Right, U = Up	
				half LD = luminance(tex2D(_MainTex, i.uvSilhouetteCollection[0].xy));
				half RD = luminance(tex2D(_MainTex, i.uvSilhouetteCollection[2].xy));
				half LU = luminance(tex2D(_MainTex, i.uvSilhouetteCollection[6].xy));
				half RU = luminance(tex2D(_MainTex, i.uvSilhouetteCollection[8].xy));

				//half edge = sqrt( (LD-RU) *(LD-RU) + (LU-RD)*(LU-RD));	
				//half edge =abs(LU-RD) * abs(LD-RU);
				half edge = abs(LD - RU) + abs(LU - RD); // Always positive

				edge = saturate((1 - edge) / _outlineThreshold);
				return edge; //Between 0 and 1
			}

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texMain = tex2D(_MainTex, i.uvSilhouetteCollection[4]); //The silhouette is not scaled by _outlinesize
                
				half edge = Robert(i); //Between 0 and 1
				fixed ff = (1 - edge) * _outlinecolor.a; //Flip it and times the alpha
				
				fixed4 sum = lerp(texMain, _outlinecolor, ff); //If detects edge and alpha is high choose outlinecolor otherwise render normally
				return sum;
            }
            ENDCG
        }
    }
}

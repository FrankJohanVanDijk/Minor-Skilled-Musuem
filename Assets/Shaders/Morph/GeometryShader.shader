Shader "Unlit/GeometryShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_factor ("Height Multiplier", Range(0, 10.0)) = 2.0 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag
           

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
				float4 objPos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

			struct g2f {
				float4 worldPos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 col : COLOR;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float _factor;

            v2g vert (appdata v)
            {
                v2g o;
                //o.objPos = UnityObjectToClipPos(v.vertex);
				o.objPos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
                return o;
            }

			[maxvertexcount(12)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream) {
				g2f o;

				float3 faceNormal = normalize(cross(input[1].objPos - input[0].objPos, input[2].objPos - input[0].objPos)); // important normal for later

				// determine which lateral side is the longest
				float a2b = distance(input[1].objPos, input[0].objPos);
				float a2c = distance(input[2].objPos, input[0].objPos);
				float b2c = distance(input[2].objPos, input[1].objPos);

				//We immediatly set to one of the possibilities so we skip one if statement. This happens when b2c is the longest
				float4 pointDPos = (input[1].objPos + input[2].objPos) / 2; // In the middle of the 2 points
				float2 pointDTex = (input[1].uv + input[2].uv) / 2;// In the middle of the 2 points
				
				// step(a,x) if x > a return 1 otherwise 0
				// so if the multiplication is equal to 1, both steps return 1
				// which means that x is longer than either of them
				if (step(a2c, a2b) * step(b2c, a2b) == 1) {
					pointDPos = (input[1].objPos + input[0].objPos) / 2;
					pointDTex = (input[1].uv + input[0].uv) / 2;
				}
				else if (step(a2b, a2c) * step(b2c, a2c) == 1) {
					pointDPos = (input[2].objPos + input[0].objPos) / 2;
					pointDTex = (input[2].uv + input[0].uv) / 2;
				}

				pointDPos += float4(faceNormal, 0) * _factor; // Point D now has a position
				//pointDTex += float2(faceNormal.x, faceNormal.z) * _factor;

				// Let's make some triangles. These are: abd, bcd and cad
				for (int i = 0; i < 3; i++) {
					o.worldPos = UnityObjectToClipPos(input[i].objPos);
					o.uv = input[i].uv;
					o.col = fixed4(0, 0, 0, 1);
					tristream.Append(o);

					int nexti = (i + 1) % 3;
					o.worldPos = UnityObjectToClipPos(input[nexti].objPos);
					o.uv = input[nexti].uv;
					o.col = fixed4(0, 0, 0, 1);
					tristream.Append(o);

					o.worldPos = UnityObjectToClipPos(pointDPos);
					o.uv = pointDTex;
					o.col = fixed4(1, 1, 1, 1);
					tristream.Append(o);

					tristream.RestartStrip(); //Done with this triangle. Lets start a new triangle
				}

				//The normal triangle abc
				o.worldPos = UnityObjectToClipPos(input[0].objPos);
				o.uv = input[0].uv;
				o.col = fixed4(0, 0, 0, 1);
				tristream.Append(o);

				o.worldPos = UnityObjectToClipPos(input[1].objPos);
				o.uv = input[1].uv;
				o.col = fixed4(0, 0, 0, 1);
				tristream.Append(o);

				o.worldPos = UnityObjectToClipPos(input[2].objPos);
				o.uv = input[2].uv;
				o.col = fixed4(0, 0, 0, 1);
				tristream.Append(o);

				tristream.RestartStrip();
			}

            fixed4 frag (g2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col /* i.col*/;
            }
            ENDCG
        }
    }
}

Shader "Unlit/HologramDissolveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_amount("Dissolve", Range(-1,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
		
		CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2g
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		struct g2f
		{
			float4 vertex : SV_POSITION;
			float4 fragmentColor : COLOR;
			float2 uv : TEXCOORD0;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _amount;

		v2g vert(appdata v)
		{
			//float t = pow(saturate(smoothstep(v.vertex.y - 0.2, v.vertex.y, _amount * 2)), 2);
			float t = saturate(smoothstep(v.vertex.y - 0.25, v.vertex.y, _amount * 2));
			//float t = saturate()

			v2g o;
			o.vertex = lerp(v.vertex + float4(0, 1, 0, 0), v.vertex, t);
			//o.vertex = lerp(v.vertex + float4(0, 1, 0, 0), v.vertex, _amount);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		fixed4 frag(g2f i) : SV_Target
		{
			//float t = pow(saturate(smoothstep(i.vertex.y, i.vertex.y + 0.25, _amount * 2)), 2);
			// sample the texture
			fixed4 col = tex2D(_MainTex, i.uv);

			col = lerp(i.fragmentColor, col, _amount);
			return col;
		}

		ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

			[maxvertexcount(6)]
			void geom(triangle v2g i[3], inout LineStream<g2f> tristream)
			{
				//float t = pow(saturate(smoothstep(i[0].vertex.y, i[0].vertex.y + 0.25, _amount * 2)), 2);
				float t = saturate(smoothstep(i[0].vertex.y, i[0].vertex.y + 0.25, _amount * 2));

				g2f o;

				o.vertex = UnityObjectToClipPos(i[0].vertex);
				o.fragmentColor = abs(i[0].vertex);
				o.uv = i[0].uv;
				tristream.Append(o);

				o.vertex = UnityObjectToClipPos(lerp(i[0].vertex, i[1].vertex, t));
				//o.vertex = UnityObjectToClipPos(lerp(i[0].vertex, i[1].vertex, _amount));
				o.fragmentColor = abs(lerp(i[0].vertex, i[1].vertex, _amount));
				o.uv = i[1].uv;
				tristream.Append(o);

				tristream.Append(o);
			}

            
            ENDCG
        }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			[maxvertexcount(12)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> tristream)
			{
				//float t = pow(saturate(smoothstep(i[0].vertex.y, i[0].vertex.y + 0.25, _amount * 2)), 2);
				float t = saturate(smoothstep(i[0].vertex.y, i[0].vertex.y + 0.25, _amount * 2));

				g2f o;

				if (t >= 1)
				{
					o.vertex = UnityObjectToClipPos(i[0].vertex);
					o.fragmentColor = abs(i[0].vertex);
					o.uv = i[0].uv;
					tristream.Append(o);

					o.vertex = UnityObjectToClipPos(i[1].vertex);
					o.fragmentColor = abs(i[1].vertex);
					o.uv = i[1].uv;
					tristream.Append(o);

					o.vertex = UnityObjectToClipPos(i[2].vertex);
					o.fragmentColor = abs(i[2].vertex);
					o.uv = i[2].uv;
					tristream.Append(o);

					tristream.Append(o);
				}
			}


			ENDCG
		}

    }
}

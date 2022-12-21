Shader "Unlit/MorphShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MorphValue("Morph Value", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			uniform float4 _meshBVerts[1100];
			uniform float _groupDivider;
			uniform float _vertNumber = 0;
			uniform float _MorphValue;

            v2f vert (appdata v)
            {
                v2f o;

				_vertNumber += 1;
				float vertToFollow = ceil(_vertNumber / _groupDivider);
				float4 blended = lerp(v.vertex, _meshBVerts[vertToFollow], _MorphValue);
				o.vertex = UnityObjectToClipPos(blended);

				//o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}

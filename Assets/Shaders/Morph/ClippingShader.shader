Shader "Custom/ClippingShader"
{
    Properties
    {
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 1)) = 0
		_Metallic("Metalness", Range(0, 1)) = 0
		[HDR] _Emission("Emission", color) = (0,0,0)

		[HDR]_cutoffColor("Cutoff Color", Color) = (1,0,0,0)
    }
    SubShader
    {
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}

		// render faces regardless if they point towards the camera or away from it
		Cull Off

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		fixed4 _Color;

		half _Smoothness;
		half _Metallic;
		half3 _Emission;

		float4 _cutoffColor;

		float4 _plane;

        struct Input
        {
            float2 uv_MainTex;
			float3 worldPos;
			float facing : VFACE; //This variable will have a value of 1 one the outside and a value of -1 on the inside.
        };

        void surf (Input i, inout SurfaceOutputStandard o)
        {
			//calculate signed distance to plane
			float distance = dot(i.worldPos, _plane.xyz);
			distance = distance + _plane.w;
			clip(-distance);

			float facing = i.facing * 0.5 + 0.5;

			//normal color stuff
			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
			col *= _Color;
			o.Albedo = col.rgb * facing;
			o.Metallic = _Metallic * facing;
			o.Smoothness = _Smoothness * facing;
			o.Emission = lerp(_cutoffColor, _Emission, facing);
        }
        ENDCG
    }
    //FallBack "Standard"
}

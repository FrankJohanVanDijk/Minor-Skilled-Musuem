Shader "Custom/DitheringV2"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", COLOR) = (0,0,0,1)
		_Smoothness("Smoothness", Float) = 0
		_Metallic("Metallic", Float) = 1
		_DitherPattern("Dithering Pattern", 2D) = "white" {}
		_MinDistance("Minimum Fade Distance", Float) = 0
		_MaxDistance("Maximum Fade Distance", Float) = 1
    }

    SubShader
    {
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry"}
        

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

		//The dithering pattern
		sampler2D _DitherPattern;
		float4 _DitherPattern_TexelSize;

		//remapping of distance
		float _MinDistance;
		float _MaxDistance;

        struct Input
        {
			float2 uv_MainTex;
			float4 screenPos;
        };

        half _Smoothness;
        half _Metallic;
        fixed4 _Color;

       

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, i.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = c.a;

			//value from the dither pattern
			float2 screenPos = i.screenPos.xy / i.screenPos.w;
			float2 ditherCoordinate = screenPos * _ScreenParams.xy * _DitherPattern_TexelSize.xy;
			float ditherValue = tex2D(_DitherPattern, ditherCoordinate).r;

			//get relative distance from the camera
			float relDistance = i.screenPos.w;
			relDistance = relDistance - _MinDistance;
			relDistance = relDistance / (_MaxDistance - _MinDistance);
			//discard pixels accordingly
			clip(relDistance - ditherValue);

            
        }
        ENDCG
    }
    FallBack "Diffuse"
}

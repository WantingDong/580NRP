Shader "NPR/firttest" {
	/*
	Properties {
		//_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Base Texture (RGB)", 2D) = "white" {}
		_Ramp("Ramp Texture", 2D) = "white" {}
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	*/
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	  _BumpMap("Bumpmap", 2D) = "bump" {}
	  _Ramp("Ramp Textrue", 2D) = "white" {}
	  _Tooniness("Tooniness", Range(0.1, 20)) = 10

	}
		SubShader{
		  Tags { "RenderType" = "Transparent" }
		  CGPROGRAM
		  #pragma surface surf Toon//Lambert

		  struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		  };

		  sampler2D _MainTex;
		  sampler2D _BumpMap;
		  sampler2D _Ramp;
		  float _Tooniness;

		  void surf(Input IN, inout SurfaceOutput o) {
			half4 c = tex2D(_MainTex, IN.uv_MainTex);
			//  o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Albedo = (floor(c.rgb * _Tooniness) / _Tooniness);
			o.Alpha = c.a;

		  }

		  float4 LightingToon(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
			  float difLight = max(0, dot(s.Normal, lightDir));
			  float dif_hLambert = difLight * 0.5 + 0.5;

			  float rimLight = max(0, dot(s.Normal, viewDir));
			  float rim_hLambert = rimLight * 0.5 + 0.5;

			  float3 ramp = tex2D(_Ramp, float2(dif_hLambert, 0)).rgb;

			  float4 c;
			  c.rgb = s.Albedo * _LightColor0.rgb * ramp;
			  c.a = s.Alpha;
			  return c;
		  }
		  
		  ENDCG
	}
	FallBack "Diffuse"
}

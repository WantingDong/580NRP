Shader "NPR/firttest" {
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	  _BumpMap("Bumpmap", 2D) = "bump" {}
	  _Ramp("Ramp Textrue", 2D) = "white" {}
	  _Tooniness("Tooniness", Range(0.1, 20)) = 20

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
			// o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Albedo.rgb = (floor(c.rgb * _Tooniness) / _Tooniness);

			o.Alpha = c.a;

			}

			float4 LightingToon(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
				float difLight = max(0, dot(s.Normal, lightDir));
				float dif_hLambert = difLight * 0.5 + 0.5;

				float rimLight = max(0, dot(s.Normal, viewDir));
				float rim_hLambert = rimLight * 0.5 + 0.5;

				float3 ramp = tex2Dlod(_Ramp, float4(dif_hLambert, dif_hLambert, 0.5,0.5)).rgb;
				//float3 ramp = tex2D(_Ramp, float2(dif_hLambert, 0.5)).rgb;
				float4 c;
				c.rgb = s.Albedo * _LightColor0.rgb * ramp*0.6;
				c.a = s.Alpha;
				return c;
			}

			  ENDCG
	  }
	FallBack "Diffuse"
}

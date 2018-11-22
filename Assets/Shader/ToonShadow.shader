// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "NPR/ToonShadow" {
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	  //_BumpMap("Bumpmap", 2D) = "bump" {}
	  _Ramp("Ramp Textrue", 2D) = "white" {}
	  _Tooniness("Tooniness", Range(0.1, 20)) = 10

	}
	SubShader {
		Tags { "RenderType"="opaque" }

		Pass {
			Tags { "LightMode" = "ForwardBase" }
			Cull Back
			Lighting On
		  CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
						#include "UnityShaderVariables.cginc"
			
			sampler _MainTex;
			//sampler _BumpMap;
			sampler _Ramp;
			//float4 _BumpMap_ST;
			float4 _MainTex_ST;
			float _Tooniness;



			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 lightDirection : TEXCOORD2;
				float4 worldPos:TEXCOORD3;
				LIGHTING_COORDS(3, 4)
			};
			v2f vert(a2v v) {
				v2f o;

				//TANGENT_SPACE_ROTATION;
				o.lightDirection = WorldSpaceLightDir(v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				//o.uv2 = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.normal = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			float4 frag(v2f i) : COLOR{
				/*float4 c = tex2D(_MainTex, i.uv);
				//float3 n = UnpackNormal(tex2D(_BumpMap, i.uv2));

				float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float atten = LIGHT_ATTENUATION(i);

				// Angle to the light
				float ndl = max(0, dot(normalize(i.normal),  normalize(_WorldSpaceLightPos0.xyz)));
				float diff = ndl * 0.5 + 0.5;
				diff = tex2D(_Ramp, float2(diff, 0.5));
				lightColor += _LightColor0.rgb * (diff * atten);

				c.rgb = lightColor * c.rgb * 2;



				c.rgb = (floor(c.rgb * _Tooniness) / _Tooniness);
				*/

				float4 c = tex2D(_MainTex, i.uv);
				float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//Work out this distance of the light
				float atten = LIGHT_ATTENUATION(i);
				//Angle to the light
				float ndl = max(0, dot(normalize(i.normal), normalize(_WorldSpaceLightPos0.xyz)));
				float diff = ndl * 0.5 + 0.5;
				//Perform our toon light mapping 
				diff = tex2D(_Ramp, float2(diff, 0.5));
				//Update the colour
				lightColor += _LightColor0.rgb * (diff * atten);
				//Product the final color
				c.rgb = lightColor * c.rgb * 0.5;


				return c;
			}
		  ENDCG
	  }
	}
	FallBack "Diffuse"
}

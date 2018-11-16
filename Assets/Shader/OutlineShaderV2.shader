// Upgrade NOTE: replaced 'UnityObjectToWorldNorm' with 'UnityObjectToWorldNormal'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'UnityObjectToWorldNorm' with 'UnityObjectToWorldNormal'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/OutlinShaderV2"
{
	Properties{
		_Scale("RIM_SCALE", range(1, 8)) = 2
		_MainTex("main tex",2D) = "black"{}
	}
		SubShader{
		//渲染队列为透明
		tags{ "Queue" = "Transparent" }
		pass {
		//混合方式
		Blend SrcAlpha oneMinusSrcAlpha

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "unitycg.cginc"

			float _Scale;
		struct v2f {
			float4 pos: SV_POSITION;
			float3 normal: TEXCOORD0;
			float4 vertex: TEXCOORD1;
		};

		v2f vert(appdata_base v) {
			v2f vf;
			vf.pos = UnityObjectToClipPos(v.vertex);
			vf.normal = v.normal;
			vf.vertex = v.vertex;
			return vf;
		}

		fixed4 frag(v2f IN) :color{
			float3 N = UnityObjectToWorldNormal(IN.normal);
			float3 V = WorldSpaceViewDir(IN.vertex);
			V = normalize(V);

			float bright = 1 - saturate(dot(N, V));
			bright = pow(bright, _Scale);
			return fixed4(1,1,1,1) * bright;
		}

			ENDCG
	}
	}
}

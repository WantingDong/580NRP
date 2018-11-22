// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/transparentShader" {
	Properties {
	
	}
		SubShader{
				Tags{ "RenderType" = "Opaque" "Queue" = "Transparent" }
				LOD 100
				Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv)
#pragma exclude_renderers d3d11

			#pragma vertex vert  
			#pragma fragment frag  
			#pragma multi_compile_fog 
			#include "UnityCG.cginc" 
		
		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		}

		struct v2f  
		{
			float2 uv : TEXCOORD0;
			UNITY_FOG_COORDS(1)
			float4 vertex : SV_POSITION;
			float lengthInCamera : TEXCOORD1;
		}

		sampler2D _MainTex;
		float4 _MainTex_ST;

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex  = UnityObjectToClipPos(v.vertex);
			o.uv  = TRANSFORM_TEX(v.uv, _MainTex);
			//计算顶点和camera之间的距离  
			o.lengthInCamera  = length(_WorldSpaceCameraPos  - v.vertex.xyz);
			return o;
		}
		

				ENDCG  
		}
	
	
}

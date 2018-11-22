// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NewSurfaceShader" {
	Properties
	{
		_MainTex("main tex",2D) = "black"{}
		_Factor("factor",Range(0,0.1)) = 0.01//描边粗细因子
		_OutLineColor("outline color",Color) = (0,0,0,1)//描边颜色
		//_MainTex("Texture", 2D) = "white" {}
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_Ramp("Ramp Textrue", 2D) = "white" {}
		_Tooniness("Tooniness", Range(0.1, 20)) = 20
	}

		SubShader
	{
		
		Pass //描边1 剔除前面
	{
		Cull Front //剔除前面
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		struct v2f
	{
		float4 vertex :POSITION;
	};

	float _Factor;
	half4 _OutLineColor;

	v2f vert(appdata_full v)
	{
		v2f o;
		//v.vertex.xyz += v.normal * _Factor;
		//o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);

		//变换到视坐标空间下，再对顶点沿法线方向进行扩展
		float4 view_vertex = mul(UNITY_MATRIX_MV,v.vertex);
		float3 view_normal = mul(UNITY_MATRIX_IT_MV,v.normal);
		view_vertex.xyz += normalize(view_normal) * _Factor; //记得normalize
		o.vertex = mul(UNITY_MATRIX_P,view_vertex);
		return o;
	}

	half4 frag(v2f IN) :COLOR
	{
		//return half4(0,0,0,1);
		return _OutLineColor;
	}
		ENDCG
	}

			Pass{
		Tags{ "LightMode" = "ForwardBase" }
		//Blend SrcAlpha OneMinusSrcAlpha // 传统透明度

		Cull Off
		Lighting On

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

#pragma multi_compile_fwdbase

#include "UnityCG.cginc"


	sampler2D _MainTex;
	float _EdgeThred;


	struct v2f
	{
		float4 vertex :POSITION;
		float4 uv:TEXCOORD0;
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		return o;
	}

	float4 frag(v2f i) : COLOR
	{
		half4 c = tex2D(_MainTex,i.uv);
		return c;

	}

		ENDCG
	}
		Tags{ "RenderType" = "Transparent" }
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


	//	FallBack "Diffuse"
}

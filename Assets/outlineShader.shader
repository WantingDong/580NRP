// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NewSurfaceShader" {
	Properties
	{
		_MainTex("main tex",2D) = "black"{}
	_RimColor("rim color",Color) = (1,1,1,1)//边缘颜色
		_RimPower("rim power",range(1,10)) = 2//边缘强度

	_Factor("factor",Range(0,0.1)) = 0.01//描边粗细因子
		_OutLineColor("outline color",Color) = (0,0,0,1)//描边颜色

		_MainTex("Base (RGB)", 2D) = "white" {}
	_MainBump("Bump", 2D) = "bump" {}
	// 该变量主要使用来降低颜色种类的
	_Tooniness("Tooniness", Range(0.1,20)) = 4
		_ColorMerge("ColorMerge", Range(0.1,20)) = 8
		// 使用ramp texture
		_Ramp("Ramp Texture", 2D) = "white" {}
	_Outline("Outline", Range(0,1)) = 0.4
	}

		SubShader
	{
		Pass   //边缘发光
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include"UnityCG.cginc"

		struct v2f
	{
		float4 vertex:POSITION;
		float4 uv:TEXCOORD0;
		float4 NdotV:COLOR;
	};

	sampler2D _MainTex;
	float4 _RimColor;
	float _RimPower;

	v2f vert(appdata_base v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		float3 V = WorldSpaceViewDir(v.vertex);
		V = mul(unity_WorldToObject,V);//视方向从世界到模型坐标系的转换
		o.NdotV.x = saturate(dot(v.normal,normalize(V)));//必须在同一坐标系才能正确做点乘运算
		return o;
	}

	half4 frag(v2f IN) :COLOR
	{
		half4 c = tex2D(_MainTex,IN.uv);
		//用视方向和法线方向做点乘，越边缘的地方，法线和视方向越接近90度，点乘越接近0.
		//用（1- 上面点乘的结果）*颜色，来反映边缘颜色情况
		c.rgb += pow((1 - IN.NdotV.x) ,_RimPower)* _RimColor.rgb;
		return c;
	}
		ENDCG
	}
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

		Pass//描边1 剔除后面
	{
		Cull Back //剔除后面
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		struct v2f
	{
		float4 vertex :POSITION;
		float4 uv:TEXCOORD0;
	};

	sampler2D _MainTex;

	v2f vert(appdata_full v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		return o;
	}

	half4 frag(v2f IN) :COLOR
	{
		//return half4(1,1,1,1);
		half4 c = tex2D(_MainTex,IN.uv);
		return c;
	}
		ENDCG
	}



	}


		FallBack "Diffuse"
}

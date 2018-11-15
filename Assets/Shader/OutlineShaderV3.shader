// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.


Shader "Custom/dotSurfaceShader" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_Ramp("Ramp Texture", 2D) = "white" {}
	//_Ink("Ink Texture", 2D) = "white" {}
	_Tooniness("Tooniness", Range(0.1,20)) = 4


		_OutlineThickness("Detail Outline Thickness", Range(0,1)) = 0.023
		_EdgeThred("Rough Outline Thickness", Range(0,1)) = 0.3
		_OutLineColor("outline color",Color) = (0,0,0,1)//描边颜色

														// rim light
		_RimColor("Rim Color", Color) = (0.8, 0.8, 0.8, 0.6)
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.5
		_RimSmooth("Rim Smooth", Range(0, 1)) = 0.1

		_HDR("hdr factor", Range(0.01, 10)) = 0.1

		[Toggle(IS_CUSTOMIZE_BACK_COLOR)]
	_IsCustomizeBackColor("Customize Back Color", Float) = 0
		_BackColor("Back color",Color) = (0,0,0,1)

		[Toggle(IS_CUSTOMIZE_FRONT_COLOR)]
	_IsCustomizeFrontColor("Customize Front Color", Float) = 0
		_ForwardColor("Forward color",Color) = (0,0,0,1)

	}
		SubShader{
		Tags{ "RenderType" = "Transparant" }
		LOD 200

		// outline pass
		Pass{
		//Tags{ "LightMode" = "ForwardBase" }
		Blend SrcAlpha OneMinusSrcAlpha // 传统透明度
										//Blend One OneMinusSrcAlpha // 预乘透明度
										//Blend One One // 叠加
										//Blend OneMinusDstColor One // 柔和叠加
										//Blend DstColor Zero // 相乘——正片叠底
										//Blend DstColor SrcColor // 两倍相乘

		Cull Front
		Lighting Off
		ZWrite On

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

#pragma multi_compile_fwdbase

#include "UnityCG.cginc"

		float _EdgeThred;

	float _OutlineThickness;
	half4 _OutLineColor;

	struct a2v
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : POSITION;
		float3 color : TEXCOORD1;
		float3 normal : TEXCOORD2;
	};

	v2f vert(a2v v)
	{
		v2f o;

		half4 projSpacePos = UnityObjectToClipPos(v.vertex);
		half4 projSpaceNormal = normalize(UnityObjectToClipPos(half4(v.normal, 0)));

		half4 nv = normalize(v.vertex);

		o.color = float3(nv.x * 0.5 + 0.5, (0.5 - nv.x * 0.5), (nv.z * 0.5 + 0.5));

		fixed thicknessFactor = ((nv.x * 0.5 + 0.5) * (0.5 - nv.y * 0.5) * (nv.z * 0.5 + 0.5));
		thicknessFactor = thicknessFactor * thicknessFactor * thicknessFactor;
		thicknessFactor = thicknessFactor / 0.5 + 0.5;

		half4 scaledNormal = _OutlineThickness  * thicknessFactor  * projSpaceNormal; // * projSpacePos.w;

																					  //scaledNormal.z += 0.000001;
		o.pos = projSpacePos + scaledNormal;

		o.normal = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL); // world normal

		return o;

	}

	float4 frag(v2f i) : COLOR
	{
		return half4(0,0,0,1);

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

#pragma shader_feature IS_CUSTOMIZE_BACK_COLOR
#pragma shader_feature IS_CUSTOMIZE_FRONT_COLOR

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "UnityShaderVariables.cginc"


		sampler2D _MainTex;
	sampler2D _Ramp;
	float _EdgeThred;

	float4 _MainTex_ST;
	//			sampler2D _Ink;

	float _Tooniness;

	fixed4 _RimColor;
	fixed _RimThreshold;
	float _RimSmooth;
	float _HDR;


	fixed4 _BackColor;
	fixed4 _ForwardColor;


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
	}

	//	FallBack "Diffuse"
}

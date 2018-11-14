// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Unity描边处理
//@author mingming mingtingjian@sina.com
//@time 2017-05-10 18:06:28
Shader "Toon Shader/Toon Outline" {
	Properties{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
	_Outline("Outline", Range(0, 1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }
		//

		Pass
	{
		//剔除正面，只渲染背面，对于大多数模型适用，不过如果需要背面的，就有问题了  
		Cull Front
		//控制深度偏移，描边pass远离相机一些，防止与正常pass穿插  
		Offset 1,1
		CGPROGRAM
		//使用vert函数和frag函数  
#pragma vertex vert  
#pragma fragment frag  
#include "UnityCG.cginc"  
		fixed4 _OutlineColor;
	float _Outline;

	struct v2f
	{
		float4 pos : SV_POSITION;
	};

	v2f vert(appdata_full v)
	{
		v2f o;
		//在vertex阶段，每个顶点按照法线的方向偏移一部分，不过这种会造成近大远小的透视问题  
		//v.vertex.xyz += v.normal * _OutlineFactor;  
		o.pos = UnityObjectToClipPos(v.vertex);
		//将法线方向转换到视空间  
		float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		//将视空间法线xy坐标转化到投影空间  
		float2 offset = TransformViewToProjection(vnormal.xy);
		//在最终投影阶段输出进行偏移操作  
		o.pos.xy += offset * _Outline;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//这个Pass直接输出描边颜色  
		return _OutlineColor;
	}

		
		ENDCG
	}
	
		Pass{
		Tags{ "LightMode" = "ForwardBase" }

		Cull Back

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

#pragma multi_compile_fwdbase

#include "UnityCG.cginc"

		fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;

	struct a2v {
		float4 pos : POSITION;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		half2 texcoord : TEXCOORD0;
	};

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.pos);
		o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
	}
	fixed4 frag(v2f i) : SV_Target{
		fixed4 col = tex2D(_MainTex, i.texcoord);
	col *= _Color;
	return col;
	}

		ENDCG
	}
	
	}
		FallBack Off
}


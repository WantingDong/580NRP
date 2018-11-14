﻿Shader "Custom/ScannerShader2"
{
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_EdgeOnly("Edge Only", Float) = 1.0
		_EdgeColor("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor("Background Color", Color) = (1, 1, 1, 1)
	}
		SubShader{
		Pass{
		ZTest Always Cull Off ZWrite Off

		CGPROGRAM

#include "UnityCG.cginc"

#pragma vertex vert  
#pragma fragment fragSobel

		sampler2D _MainTex;
	//xxx_TexelSize 是Unity为我们提供访问xxx纹理对应的每个纹素的大小。
	//例如一张512×512的纹理，该值大小为0.001953(即1/512)。由于卷积需要对相邻区域内的纹理
	//进行采样，因此我们需要它来计算相邻区域的纹理坐标
	uniform half4 _MainTex_TexelSize;
	fixed _EdgeOnly;
	fixed4 _EdgeColor;
	fixed4 _BackgroundColor;

	struct v2f {
		float4 pos : SV_POSITION;
		half2 uv[9] : TEXCOORD0;
	};

	v2f vert(appdata_img v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		half2 uv = v.texcoord;
		//我们在v2f结构体中定义了一个维数为9的纹理数组，对应了使用Sobel算子采样时需要的9个
		//邻域纹理坐标。通过把计算采样纹理坐标的代码从片元着色器转移到顶点着色器中，可以减少
		//运算，提供性能。由于从顶点着色器到片元着色器的插值是线性的，因此这样的转移不会影响
		//纹理坐标的计算结果。
		o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
		o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
		o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
		o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
		o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
		o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
		o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
		o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
		o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

		return o;
	}

	fixed luminance(fixed4 color) {
		return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
	}

	//利用Sobel算子计算梯度值
	half Sobel(v2f i) {
		//水平方向卷积核
		const half Gx[9] = { -1,  0,  1,
			-2,  0,  2,
			-1,  0,  1 };
		//竖直方向卷积核
		const half Gy[9] = { -1, -2, -1,
			0,  0,  0,
			1,  2,  1 };

		half texColor;
		half edgeX = 0;
		half edgeY = 0;
		for (int it = 0; it < 9; it++) {
			//采样，得到亮度值
			texColor = luminance(tex2D(_MainTex, i.uv[it]));
			//水平方向上梯度
			edgeX += texColor * Gx[it];
			//竖直方向上梯度
			edgeY += texColor * Gy[it];
		}
		//edge 越小，表面该位置越可能是一个边缘点。
		half edge = 1 - abs(edgeX) - abs(edgeY);

		return edge;
	}

	fixed4 fragSobel(v2f i) : SV_Target{
		half edge = Sobel(i);

	fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
	fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
	return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
	}

		ENDCG
	}
	}
		FallBack Off
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 12/Brightness Saturation And Contrast" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
		SubShader{
		Pass{
		//屏幕后处理实际上是在场景中绘制了一个与屏幕同宽同高的四边形面片
		//为了防止它对其他物体产生影响，我们需要设置相关的渲染状态。
		//关闭深度写入，是为了防止它“挡住”在其后面被渲染的物体
		ZTest Always Cull Off ZWrite Off

		CGPROGRAM
#pragma vertex vert  
#pragma fragment frag  

#include "UnityCG.cginc"  

		sampler2D _MainTex;
	half _Brightness;
	half _Saturation;
	half _Contrast;

	struct v2f {
		float4 pos : SV_POSITION;
		half2 uv: TEXCOORD0;
	};

	//屏幕特效使用的顶点着色器代码通常比较简单，我们只需要进行必须的顶点变换
	//更重要的是，我们需要把正确的纹理坐标传递给片元着色器，以便对屏幕图像进行正确的采样
	//使用了内置appdata_img 结构体作为顶点着色器的输入
	v2f vert(appdata_img v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target{
		fixed4 renderTex = tex2D(_MainTex, i.uv);

	//调整亮度
	fixed3 finalColor = renderTex.rgb * _Brightness;

	//调整饱和度
	fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
	fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
	finalColor = lerp(luminanceColor, finalColor, _Saturation);

	//调整对比度
	fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
	finalColor = lerp(avgColor, finalColor, _Contrast);

	return fixed4(finalColor, renderTex.a);
	}

		ENDCG
	}
	}

		Fallback Off
}
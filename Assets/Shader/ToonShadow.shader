Shader "NPR/ToonShadow" {
	Properties{
	  _MainTex("Texture", 2D) = "white" {}
	  _BumpMap("Bumpmap", 2D) = "bump" {}
	  _Ramp("Ramp Textrue", 2D) = "white" {}
	  _Tooniness("Tooniness", Range(0.1, 20)) = 10

	}
	SubShader {
		Tags { "RenderType"="Tranparent" }

		Pass {
			Tags { "LightMode" = "Vertex" }
			Cull Back
			Lighting On
		  CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"

		 

		  ENDCG
	  }
	}
	FallBack "Diffuse"
}

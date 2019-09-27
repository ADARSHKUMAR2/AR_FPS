// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
/*
Shader "Outlined/Silhouetted Diffuse" {
	Properties{
		_Color("Main Color", Color) = (.5,.5,.5,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_Outline("Outline width", Range(0.0, 0.3)) = .005
		_MainTex("Base (RGB)", 2D) = "white" { }
	}

		CGINCLUDE
#include "UnityCG.cginc"

		struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : POSITION;
		float4 color : COLOR;
	};

	uniform float _Outline;
	uniform float4 _OutlineColor;

	v2f vert(appdata v) {
		// just make a copy of incoming vertex data but scaled according to normal direction
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		float2 offset = TransformViewToProjection(norm.xy);

		o.pos.xy += offset * o.pos.z * _Outline;
		o.color = _OutlineColor;
		return o;
	}
	ENDCG

		SubShader{
			Tags { "Queue" = "Transparent" }

			// note that a vertex shader is specified here but its using the one above
			Pass {
				Name "OUTLINE"
				Tags { "LightMode" = "Always" }
				Cull Off
				ZWrite Off
				ZTest Always
				ColorMask RGB // alpha not used

				// you can choose what kind of blending mode you want for the outline
				Blend SrcAlpha OneMinusSrcAlpha // Normal
				//Blend One One // Additive
				//Blend One OneMinusDstColor // Soft Additive
				//Blend DstColor Zero // Multiplicative
				//Blend DstColor SrcColor // 2x Multiplicative

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	half4 frag(v2f i) :COLOR {
		return i.color;
	}
	ENDCG
			}

			Pass {
				Name "BASE"
				ZWrite On
				ZTest LEqual
				Blend SrcAlpha OneMinusSrcAlpha
				Material {
					Diffuse[_Color]
					Ambient[_Color]
				}
				Lighting On
				SetTexture[_MainTex] {
					ConstantColor[_Color]
					Combine texture * constant
				}
				SetTexture[_MainTex] {
					Combine previous * primary DOUBLE
				}
			}
	}

		SubShader{
			Tags { "Queue" = "Transparent" }

			Pass {
				Name "OUTLINE"
				Tags { "LightMode" = "Always" }
				Cull Front
				ZWrite Off
				ZTest Always
				ColorMask RGB

		// you can choose what kind of blending mode you want for the outline
		Blend SrcAlpha OneMinusSrcAlpha // Normal
		//Blend One One // Additive
		//Blend One OneMinusDstColor // Soft Additive
		//Blend DstColor Zero // Multiplicative
		//Blend DstColor SrcColor // 2x Multiplicative

		CGPROGRAM
		#pragma vertex vert
		#pragma exclude_renderers gles xbox360 ps3
		ENDCG
		SetTexture[_MainTex] { combine primary }
	}

	Pass {
		Name "BASE"
		ZWrite On
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		Material {
			Diffuse[_Color]
			Ambient[_Color]
		}
		Lighting On
		SetTexture[_MainTex] {
			ConstantColor[_Color]
			Combine texture * constant
		}
		SetTexture[_MainTex] {
			Combine previous * primary DOUBLE
		}
	}
	}

		Fallback "Diffuse"
}*/
Shader "Unlit/SpecialFX/Cool Hologram"
{
Properties
{
	_MainTex("Albedo Texture", 2D) = "white" {}
	_TintColor("Tint Color", Color) = (1,1,1,1)
	_Transparency("Transparency", Range(0.0,0.5)) = 0.25
	_CutoutThresh("Cutout Threshold", Range(0.0,1.0)) = 0.2
	_Distance("Distance", Float) = 1
	_Amplitude("Amplitude", Float) = 1
	_Speed("Speed", Float) = 1
	_Amount("Amount", Range(0.0,1.0)) = 1
}

SubShader
	{
		Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _TintColor;
			float _Transparency;
			float _CutoutThresh;
			float _Distance;
			float _Amplitude;
			float _Speed;
			float _Amount;

			v2f vert(appdata v)
			{
				v2f o;
				v.vertex.x += sin(_Time.y * _Speed + v.vertex.y * _Amplitude) * _Distance * _Amount;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) + _TintColor;
				col.a = _Transparency;
				clip(col.r - _CutoutThresh);
				return col;
			}
			ENDCG
		}
	}
}
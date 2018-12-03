Shader "neo/directionMelt"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_NoiseTex("Noise",2D) = "white"{}

		_Direction("Direction", Vector) = (0,1,0,0)
		_Threshold("Threshold", Float) = 0
		_NoiseStrength("Cull Value", Range(0,100)) = 1

		_Edge("Edge Width", Range(0,0.5)) = 0.1
		_EdgeColor("Edge Color", Color) = (1,1,1,1)

	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Cull Off
		LOD 100

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
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 light : COLOR0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			float4 _Direction;
			float _Threshold;
			float _NoiseStrength;

			float _Edge;
			float4 _EdgeColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				half3 lightDir = normalize(ObjSpaceLightDir(v.vertex));
				half3 normalDir = normalize(v.normal);
				o.light = 1 - min(dot(normalDir, lightDir) * 0.4 + 0.5, 1);

				_Direction = normalize(_Direction);
				float VdotD = dot(_Direction, v.vertex);
				o.light.a = VdotD - _Threshold;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 noise = tex2D(_NoiseTex, i.uv);
				float noiseEnhanced = noise.a * _NoiseStrength;
				clip(i.light.a + noiseEnhanced + _Edge);

				fixed4 col = tex2D(_MainTex, i.uv);
				if (i.light.a + noiseEnhanced < 0) {
					col = _EdgeColor;
				}
				col.xyz *= i.light.xyz;
				return col;
			}
			ENDCG
		}
	}
}

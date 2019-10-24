// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NitRoShader/UVRotate"
{
	Properties
	{
		_Texture("Texture", 2D) = "white" {}
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_Emission("Emission", Color) = (0,0,0,0)
		_SpeedR("Speed R", Range( -5 , 5)) = 1
		_SpeedB("Speed B", Range( -5 , 5)) = 1
		_SpeedG("Speed G", Range( -5 , 5)) = 1
		_AnchorR("Anchor R", Vector) = (0.5,0.5,0,0)
		_AnchorB("Anchor B", Vector) = (0.5,0.5,0,0)
		_AnchorG("Anchor G", Vector) = (0.5,0.5,0,0)
		_RotateMask("Rotate Mask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Emission;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;
		uniform float2 _AnchorR;
		uniform float _SpeedR;
		uniform sampler2D _RotateMask;
		uniform float4 _RotateMask_ST;
		uniform float2 _AnchorB;
		uniform float _SpeedB;
		uniform float2 _AnchorG;
		uniform float _SpeedG;
		uniform float _Opacity;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv0_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			float cos31 = cos( ( _Time.y * _SpeedR ) );
			float sin31 = sin( ( _Time.y * _SpeedR ) );
			float2 rotator31 = mul( uv0_Texture - _AnchorR , float2x2( cos31 , -sin31 , sin31 , cos31 )) + _AnchorR;
			float2 uv_RotateMask = i.uv_texcoord * _RotateMask_ST.xy + _RotateMask_ST.zw;
			float4 tex2DNode17 = tex2D( _RotateMask, uv_RotateMask );
			float cos2 = cos( ( _Time.y * _SpeedB ) );
			float sin2 = sin( ( _Time.y * _SpeedB ) );
			float2 rotator2 = mul( uv0_Texture - _AnchorB , float2x2( cos2 , -sin2 , sin2 , cos2 )) + _AnchorB;
			float cos58 = cos( ( _Time.y * _SpeedG ) );
			float sin58 = sin( ( _Time.y * _SpeedG ) );
			float2 rotator58 = mul( uv0_Texture - _AnchorG , float2x2( cos58 , -sin58 , sin58 , cos58 )) + _AnchorG;
			float4 break39 = ( ( tex2D( _Texture, rotator31 ) * tex2DNode17.r ) + ( tex2D( _Texture, rotator2 ) * tex2DNode17.b ) + ( tex2D( _Texture, rotator58 ) * tex2DNode17.g ) );
			float4 appendResult41 = (float4(break39.r , break39.g , break39.b , 0.0));
			o.Emission = ( _Emission + appendResult41 ).rgb;
			o.Alpha = ( break39.a * _Opacity );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
347;235;1414;718;1713.343;1618.129;3.727745;True;True
Node;AmplifyShaderEditor.RangedFloatNode;8;-1338.654,864.6047;Float;False;Property;_SpeedB;Speed B;5;0;Create;True;0;0;False;0;1;1;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;27;-1976.99,-24.55066;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-1324.304,174.4105;Float;False;Property;_SpeedG;Speed G;6;0;Create;True;0;0;False;0;1;1;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1424.909,-677.7405;Float;False;Property;_SpeedR;Speed R;4;0;Create;True;0;0;False;0;1;-1;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1991.822,-234.7738;Float;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;6;-1095.12,620.1188;Float;False;Property;_AnchorB;Anchor B;8;0;Create;True;0;0;False;0;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;57;-1127.899,-98.76231;Float;False;Property;_AnchorG;Anchor G;9;0;Create;True;0;0;False;0;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1040.056,-668.7802;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1009.43,103.2585;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-993.0427,828.2872;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;29;-1138.495,-856.6223;Float;False;Property;_AnchorR;Anchor R;7;0;Create;True;0;0;False;0;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RotatorNode;58;-852.1991,-165.1743;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;2;-819.4192,553.7067;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;31;-864.3828,-926.3749;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;59;-515.7026,-152.6857;Float;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;1;;b0f0845e2386f95428e7f657413437fd;b0f0845e2386f95428e7f657413437fd;True;0;False;white;Auto;False;Instance;5;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-539.105,-889.5276;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;5;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-482.9227,568.0764;Float;True;Property;_Texture;Texture;1;0;Create;True;0;0;False;1;;None;b0f0845e2386f95428e7f657413437fd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-779.6021,-545.6843;Float;True;Property;_RotateMask;Rotate Mask;10;0;Create;True;0;0;False;0;None;cab612364ada89a49a2145fd38ccf327;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-76.18896,-717.7773;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-35.19501,529.4927;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-67.97488,-189.3881;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;320.1001,-405.7;Float;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;39;639.962,-296.1142;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;16;706.5003,-562.8999;Float;False;Property;_Emission;Emission;3;0;Create;True;0;0;False;0;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;41;951.9617,-322.1142;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;62;729.3749,-8.518831;Float;False;Property;_Opacity;Opacity;2;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;1180.115,-483.6263;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1113.215,-81.90003;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;1176.862,-356.5142;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1344.3,-254.4;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;NitRoShader/UVRotate;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;0;27;2
WireConnection;30;1;26;0
WireConnection;55;0;27;2
WireConnection;55;1;53;0
WireConnection;7;0;27;2
WireConnection;7;1;8;0
WireConnection;58;0;28;0
WireConnection;58;1;57;0
WireConnection;58;2;55;0
WireConnection;2;0;28;0
WireConnection;2;1;6;0
WireConnection;2;2;7;0
WireConnection;31;0;28;0
WireConnection;31;1;29;0
WireConnection;31;2;30;0
WireConnection;59;1;58;0
WireConnection;25;1;31;0
WireConnection;5;1;2;0
WireConnection;32;0;25;0
WireConnection;32;1;17;1
WireConnection;23;0;5;0
WireConnection;23;1;17;3
WireConnection;60;0;59;0
WireConnection;60;1;17;2
WireConnection;15;0;32;0
WireConnection;15;1;23;0
WireConnection;15;2;60;0
WireConnection;39;0;15;0
WireConnection;41;0;39;0
WireConnection;41;1;39;1
WireConnection;41;2;39;2
WireConnection;63;0;39;3
WireConnection;63;1;62;0
WireConnection;40;0;16;0
WireConnection;40;1;41;0
WireConnection;0;2;40;0
WireConnection;0;9;63;0
ASEEND*/
//CHKSM=A221FB4484CFF7F9E8BC4C00DE11E7CD2DE97779
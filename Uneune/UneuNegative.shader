// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NitRoShader/UneuNegativeShader"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		[Enum(Off,0,On,1)]_ZWrite("ZWrite", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", Float) = 4
		_AnimationSpeed("AnimationSpeed", Range( 0 , 5)) = 2.190335
		_AnimationScale("AnimationScale", Range( 0 , 1)) = 0
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Overlay" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Sub
		Cull Back
		ColorMask RGBA
		ZWrite [_ZWrite]
		ZTest [_ZTest]
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};

			uniform float _ZTest;
			uniform float _ZWrite;
			uniform float _AnimationSpeed;
			uniform float _AnimationScale;
			uniform float4 _Color;
			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float simplePerlin2D20 = snoise( ( v.vertex.xyz + ( _Time.y * _AnimationSpeed ) ).xy );
				simplePerlin2D20 = simplePerlin2D20*0.5 + 0.5;
				float3 temp_cast_1 = ((( _AnimationScale * 0.0 ) + (simplePerlin2D20 - 0.0) * (_AnimationScale - ( _AnimationScale * 0.0 )) / (1.0 - 0.0))).xxx;
				
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = temp_cast_1;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				
				
				finalColor = _Color;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17101
117;195;1691;855;1459.026;326.9611;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;18;-1044.427,179.1781;Float;False;Property;_AnimationSpeed;AnimationSpeed;3;0;Create;True;0;0;False;0;2.190335;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;16;-1015.889,6.297045;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-712.2212,39.91328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;24;-852.3441,-159.9142;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-531.1551,-26.20958;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-809.0281,494.8273;Float;False;Property;_AnimationScale;AnimationScale;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-454.168,384.8707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;20;-375.8655,111.6451;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-505,-254;Float;False;Property;_ZTest;ZTest;2;1;[Enum];Create;True;1;Option1;0;1;UnityEngine.Rendering.CompareFunction;True;0;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-519,-158;Float;False;Property;_ZWrite;ZWrite;1;1;[Enum];Create;True;2;Off;0;On;1;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-302,-213;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;23;-49.32762,259.9199;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;11;209.931,-79.05125;Float;False;True;2;ASEMaterialInspector;0;1;NitRoShader/UneuNegativeShader;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;2;False;-1;4;False;-1;True;2;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;True;14;True;7;True;13;True;False;0;False;-1;0;False;-1;True;2;RenderType=Opaque=RenderType;Queue=Overlay=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;0
WireConnection;17;0;16;2
WireConnection;17;1;18;0
WireConnection;19;0;24;0
WireConnection;19;1;17;0
WireConnection;22;0;21;0
WireConnection;20;0;19;0
WireConnection;23;0;20;0
WireConnection;23;3;22;0
WireConnection;23;4;21;0
WireConnection;11;0;12;0
WireConnection;11;1;23;0
ASEEND*/
//CHKSM=2185051BD24DCC1C5DEDE36AED438779A636EA51
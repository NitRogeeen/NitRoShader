// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NitRoShader/WarterObject"
{
	Properties
	{
		_Albedo("Albedo", Color) = (0,0,0,0)
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_OpacityExp("OpacityExp", Range( 0 , 10)) = 1
		[Toggle]_RimSwitch("RimSwitch", Float) = 0
		_Emission("Emission", Color) = (0,0,0,0)
		_AnimationSpeed("AnimationSpeed", Range( 0 , 5)) = 1.536353
		_AnimationScale("AnimationScale", Range( 0 , 0.1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Specular("Specular", Range( 0 , 1)) = 0
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_IndexofRefraction("Index of Refraction", Range( 0 , 2)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma surface surf StandardSpecular keepalpha finalcolor:RefractionF exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _AnimationSpeed;
		uniform float _AnimationScale;
		uniform float4 _Albedo;
		uniform float4 _Emission;
		uniform float _Specular;
		uniform float _Smoothness;
		uniform float _RimSwitch;
		uniform float _OpacityExp;
		uniform float _Opacity;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _IndexofRefraction;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float simplePerlin2D4 = snoise( ( ase_vertex3Pos + ( _Time.y * _AnimationSpeed ) ).xy );
			simplePerlin2D4 = simplePerlin2D4*0.5 + 0.5;
			float VertexOffset39 = (( _AnimationScale * 0.0 ) + (simplePerlin2D4 - 0.0) * (_AnimationScale - ( _AnimationScale * 0.0 )) / (1.0 - 0.0));
			float3 temp_cast_1 = (VertexOffset39).xxx;
			v.vertex.xyz += temp_cast_1;
		}

		inline float4 Refraction( Input i, SurfaceOutputStandardSpecular o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandardSpecular o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, _IndexofRefraction, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			o.Normal = float3(0,0,1);
			o.Albedo = _Albedo.rgb;
			o.Emission = _Emission.rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult18 = dot( ase_worldNormal , ase_worldViewDir );
			float Specular45 = ( ( 1.0 - saturate( ( pow( dotResult18 , 2.0 ) - 0.1 ) ) ) * _Specular );
			float3 temp_cast_2 = (Specular45).xxx;
			o.Specular = temp_cast_2;
			o.Smoothness = _Smoothness;
			float dotResult28 = dot( ase_worldNormal , ase_worldViewDir );
			float temp_output_32_0 = saturate( pow( dotResult28 , _OpacityExp ) );
			float Opacity41 = ( lerp(( 1.0 - temp_output_32_0 ),temp_output_32_0,_RimSwitch) * _Opacity );
			o.Alpha = Opacity41;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
197;147;1691;855;2538.266;1120.368;2.576687;True;True
Node;AmplifyShaderEditor.WorldNormalVector;16;-1701.207,-778.145;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;27;-1698.427,-161.2942;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;26;-1710.16,-343.2939;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-1691.207,-596.1451;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;18;-1481.569,-653.3648;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1706.862,3.83923;Inherit;False;Property;_OpacityExp;OpacityExp;3;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-1488.787,-218.5138;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;35;-1291.979,-217.5752;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;19;-1330.073,-654.7078;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1680.374,559.2789;Float;False;Property;_AnimationSpeed;AnimationSpeed;6;0;Create;True;0;0;False;0;1.536353;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;1;-1680.03,351.9911;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-1159.888,-650.168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;-1083.723,-219.8424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-1356.718,421.9099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;5;-1609.94,185.8436;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-1172.241,214.7215;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;21;-989.0561,-642.5986;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1253.469,600.9015;Float;False;Property;_AnimationScale;AnimationScale;7;0;Create;True;0;0;False;0;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-856.3288,-246.0788;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;4;-1006.392,248.8789;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;38;-638.4232,-170.2838;Inherit;False;Property;_RimSwitch;RimSwitch;4;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;-794.5032,-644.8967;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-944.9261,-491.3503;Inherit;False;Property;_Specular;Specular;9;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-917.2255,505.774;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-832.0241,-38.12378;Inherit;False;Property;_Opacity;Opacity;2;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-704.2922,473.1542;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-362.2701,-156.3441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-536.134,-558.801;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-301.8325,-566.4934;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-429.2149,464.9807;Inherit;False;VertexOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-149.7197,-138.1433;Inherit;False;Opacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;217.2448,60.63569;Inherit;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;212.316,137.6846;Inherit;False;Property;_IndexofRefraction;Index of Refraction;12;0;Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;308.3472,212.843;Inherit;False;41;Opacity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;271.9944,-378.9164;Inherit;False;Property;_Albedo;Albedo;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;12;271.2018,-201.5972;Inherit;False;Property;_Emission;Emission;5;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;40;283.5822,293.1555;Inherit;False;39;VertexOffset;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;296.1221,-24.8825;Inherit;False;45;Specular;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;630.2686,-144.7052;Float;False;True;6;ASEMaterialInspector;0;0;StandardSpecular;NitRoShader/WarterObject;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;10;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;35;0;28;0
WireConnection;35;1;36;0
WireConnection;19;0;18;0
WireConnection;20;0;19;0
WireConnection;32;0;35;0
WireConnection;2;0;1;2
WireConnection;2;1;3;0
WireConnection;6;0;5;0
WireConnection;6;1;2;0
WireConnection;21;0;20;0
WireConnection;30;0;32;0
WireConnection;4;0;6;0
WireConnection;38;0;30;0
WireConnection;38;1;32;0
WireConnection;22;0;21;0
WireConnection;9;0;7;0
WireConnection;8;0;4;0
WireConnection;8;3;9;0
WireConnection;8;4;7;0
WireConnection;31;0;38;0
WireConnection;31;1;13;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;45;0;24;0
WireConnection;39;0;8;0
WireConnection;41;0;31;0
WireConnection;0;0;25;0
WireConnection;0;2;12;0
WireConnection;0;3;43;0
WireConnection;0;4;14;0
WireConnection;0;8;15;0
WireConnection;0;9;42;0
WireConnection;0;11;40;0
ASEEND*/
//CHKSM=0B9DADFEF04FFA9BFB6F749B6AF498795632BF52
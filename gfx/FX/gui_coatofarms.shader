Includes = {
	"cw/pdxgui.fxh"
	"cw/pdxgui_sprite_base.fxh"
	"cw/pdxgui_sprite_textures.fxh"
}

ConstantBuffer( 2 )
{
	float3 HighlightColor;
	float4 CoALeftTop_WidthHeight;
};

VertexStruct VS_OUTPUT_COA
{
	float4 Position		: PDX_POSITION;
	float2 UV			: TEXCOORD0;
	float2 RelativePos	: TEXCOORD1;
	float4 Color		: COLOR;
};

VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_GUI"
		Output = "VS_OUTPUT_COA"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_COA Out;
				float2 PixelPos = WidgetLeftTop + Input.LeftTop_WidthHeight.xy + Input.Position * Input.LeftTop_WidthHeight.zw;
				Out.Position = PixelToScreenSpace( PixelPos );
				Out.UV.xy = Input.Position;
				Out.Color = Input.Color;
				Out.RelativePos = Input.Position;
				
				return Out;
			}
		]]
	}
}


PixelShader =
{
	TextureSampler Mask
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}

	TextureSampler CoA
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}

	MainCode PixelShader
	{
		Input = "VS_OUTPUT_COA"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{	
				float2 UV = Input.UV.xy;
				float verticalOffset = 0.0f;
				UV.y = min( 1.0f, UV.y + verticalOffset );
				UV = CoALeftTop_WidthHeight.xy + UV.xy * CoALeftTop_WidthHeight.zw;
			
				float4 OutColor = PdxTex2D( CoA, UV.xy );
				#ifdef SEAL
					float4 background = PdxTex2D( Mask, Input.RelativePos );
					float3 SealPattern = OutColor.rgb;
					const float SealPatternOffset = 0.0002;	// The larger the number, the thicker the outlines. Also depends on the size of CoA used  0.0004
					const float SealPatternStrength = 2.0;	// The larger the number, the more contrast there is in the seal pattern 2.7
					SealPattern += PdxTex2D( CoA, UV.xy - float2( SealPatternOffset, SealPatternOffset ) ).xyz * SealPatternStrength;
					SealPattern -= PdxTex2D( CoA, UV.xy + float2( SealPatternOffset, SealPatternOffset ) ).xyz * SealPatternStrength;
					SealPattern = .7 + SealPattern * .7;	// The pattern is pretty dark at this point, this offsets it towards white and squishes the contrast a bit. A good choice of these values depends on the seal background texture used.
					SealPattern = clamp( DisableColor( SealPattern ), .0, 1.7 );	// This clamps the seal pattern values. It doesn't clamp it to 1.0 because it's ok if it makes the seal background brighter in some parts.  A good choice of these values depends on the seal background texture used.

					OutColor = float4( SealPattern, Input.Color.a );

					OutColor *= background;
				#else
					float mask = PdxTex2D( Mask, Input.RelativePos ).a;
					OutColor *= mask;
					OutColor *= Input.Color;
				#endif
				
				ApplyModifyTextures( OutColor, Input.UV.xy );

				#ifdef DISABLED
					OutColor.rgb = DisableColor( OutColor.rgb );
				#endif
				
				return OutColor;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
}

Effect PdxGuiDefault
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect PdxGuiDefaultDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" }
}

Effect PdxGuiPreMultipliedAlpha
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	BlendState = PreMultipliedAlpha
}

Effect PdxGuiPreMultipliedAlphaDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	BlendState = PreMultipliedAlpha
	
	Defines = { "DISABLED" }
}

Effect PdxGuiSeal
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "SEAL" }
}

Effect PdxGuiSealDisabled
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
	
	Defines = { "DISABLED" "SEAL" }
}

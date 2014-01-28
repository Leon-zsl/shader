
#pragma strict

import System.IO;

@script ExecuteInEditMode
@script AddComponentMenu ("ZSL/Image Effects/Color Correction (Curves, Saturation)")

enum ZSLColorCorrectionMode {
	Simple = 0,
	Advanced = 1	
}

class ColorCorrectionCurvesZSL extends PostEffectsBase 
{
	public var redChannel : AnimationCurve;
	public var greenChannel : AnimationCurve;
	public var blueChannel : AnimationCurve;
	
	public var useDepthCorrection : boolean = false;
	
	public var zCurve : AnimationCurve;
	public var depthRedChannel : AnimationCurve;
	public var depthGreenChannel : AnimationCurve;
	public var depthBlueChannel : AnimationCurve;
	
	private var ccMaterial : Material;
	private var ccDepthMaterial : Material;
	private var selectiveCcMaterial : Material;
	
	private var rgbChannelTex : Texture2D;
	private var rgbDepthChannelTex : Texture2D;
	private var zCurveTex : Texture2D;
	
	public var saturation : float = 1.0f;

	public var selectiveCc : boolean = false;
	
	public var selectiveFromColor : Color = Color.white;
	public var selectiveToColor : Color = Color.white;
	
	public var mode : ZSLColorCorrectionMode;
	
	public var updateTextures : boolean = true;		
		
	public var colorCorrectionCurvesShader : Shader = null;
	public var simpleColorCorrectionCurvesShader : Shader = null;
	public var colorCorrectionSelectiveShader : Shader = null;
			
	private var updateTexturesOnStartup : boolean = true;

	private var finalTex : Texture2D;
		
	// public function rgbTex() : Texture2D { return rgbChannelTex; }
	// public function rgbDepthTex() : Texture2D { return rgbDepthChannelTex; }
	// public function zTex() : Texture2D { return zCurveTex; }
	function Start () {
		super ();
		updateTexturesOnStartup = true;
	}
	
	function Awake () {	}
	
	function CheckResources () : boolean {		
		CheckSupport (mode == ZSLColorCorrectionMode.Advanced);
		
		if(colorCorrectionCurvesShader == null)
			colorCorrectionCurvesShader = Shader.Find("ZSL/PostProc/ColorCorrectionCurves");
		if(simpleColorCorrectionCurvesShader == null)
			simpleColorCorrectionCurvesShader = Shader.Find("Hidden/ColorCorrectionCurvesSimple");
		if(colorCorrectionSelectiveShader == null)
			colorCorrectionSelectiveShader = Shader.Find("Hidden/ColorCorrectionSelective");

		ccMaterial = CheckShaderAndCreateMaterial (simpleColorCorrectionCurvesShader, ccMaterial);
		ccDepthMaterial = CheckShaderAndCreateMaterial (colorCorrectionCurvesShader, ccDepthMaterial);
		selectiveCcMaterial = CheckShaderAndCreateMaterial (colorCorrectionSelectiveShader, selectiveCcMaterial);
		
		if (!rgbChannelTex)
			 rgbChannelTex = new Texture2D (256, 4, TextureFormat.ARGB32, false, true); 
		if (!rgbDepthChannelTex)
			 rgbDepthChannelTex = new Texture2D (256, 4, TextureFormat.ARGB32, false, true);
		if (!zCurveTex)
			 zCurveTex = new Texture2D (256, 1, TextureFormat.ARGB32, false, true);
			 
		rgbChannelTex.hideFlags = HideFlags.None;
		rgbDepthChannelTex.hideFlags = HideFlags.None;
		zCurveTex.hideFlags = HideFlags.None;
			
		rgbChannelTex.wrapMode = TextureWrapMode.Clamp;
		rgbDepthChannelTex.wrapMode = TextureWrapMode.Clamp;
		zCurveTex.wrapMode = TextureWrapMode.Clamp;	

		if(!finalTex)
			finalTex = new Texture2D(256, 256, TextureFormat.RGB24, false, true);
		finalTex.hideFlags = HideFlags.None;
		finalTex.wrapMode = TextureWrapMode.Clamp;
		finalTex.anisoLevel = 9;
		finalTex.filterMode = FilterMode.Trilinear;
					
		if(!isSupported)
			ReportAutoDisable ();
		return isSupported;		  
	}	
	
	public function UpdateParameters () 
	{
		//Debug.Log("update params...");
		CheckResources(); // textures might not be created if we're tweaking UI while disabled
		
		if (redChannel && greenChannel && blueChannel) {		
			for (var i : float = 0.0f; i <= 1.0f; i += 1.0f / 255.0f) {
				var rCh : float = Mathf.Clamp (redChannel.Evaluate(i), 0.0f, 1.0f);
				var gCh : float = Mathf.Clamp (greenChannel.Evaluate(i), 0.0f, 1.0f);
				var bCh : float = Mathf.Clamp (blueChannel.Evaluate(i), 0.0f, 1.0f);
				
				rgbChannelTex.SetPixel (Mathf.Floor(i*255.0f), 0, Color(rCh,rCh,rCh) );
				rgbChannelTex.SetPixel (Mathf.Floor(i*255.0f), 1, Color(gCh,gCh,gCh) );
				rgbChannelTex.SetPixel (Mathf.Floor(i*255.0f), 2, Color(bCh,bCh,bCh) );
				
				var zC : float = Mathf.Clamp (zCurve.Evaluate(i), 0.0,1.0);
					
				zCurveTex.SetPixel (Mathf.Floor(i*255.0), 0, Color(zC,zC,zC) );
			
				rCh = Mathf.Clamp (depthRedChannel.Evaluate(i), 0.0f,1.0f);
				gCh = Mathf.Clamp (depthGreenChannel.Evaluate(i), 0.0f,1.0f);
				bCh = Mathf.Clamp (depthBlueChannel.Evaluate(i), 0.0f,1.0f);
				
				rgbDepthChannelTex.SetPixel (Mathf.Floor(i*255.0f), 0, Color(rCh,rCh,rCh) );
				rgbDepthChannelTex.SetPixel (Mathf.Floor(i*255.0f), 1, Color(gCh,gCh,gCh) );
				rgbDepthChannelTex.SetPixel (Mathf.Floor(i*255.0f), 2, Color(bCh,bCh,bCh) );
			}
			
			rgbChannelTex.Apply ();
			rgbDepthChannelTex.Apply ();
			zCurveTex.Apply ();
		}
	}

	function UpdateFinalTex() {
		if(!rgbChannelTex || !rgbDepthChannelTex || !zCurveTex) {
			Debug.Log("raw texture is not prepared");
			return;
		}

		for(var i : int = 0; i < 256; i++) {
			
			var nearCol : Color = Color.white;
			nearCol.r = rgbChannelTex.GetPixel(i, 0).r;
			nearCol.g = rgbChannelTex.GetPixel(i, 1).g;
			nearCol.b = rgbChannelTex.GetPixel(i, 2).b;

			var farCol : Color = Color.white;
			farCol.r = rgbDepthChannelTex.GetPixel(i, 0).r;
			farCol.g = rgbDepthChannelTex.GetPixel(i, 1).g;
			farCol.b = rgbDepthChannelTex.GetPixel(i, 2).b;

			for(var j : int = 0; j < 256; j++) {
				var t : float = zCurveTex.GetPixel(j, 0).r;
				var pixel : Color = Color.Lerp(nearCol, farCol, t);
				//write column order
				finalTex.SetPixel(i, j, pixel);
			}
		}
		finalTex.Apply();
	}
	
	function UpdateTextures () {
		UpdateParameters ();
		//SaveTextures();

		// UpdateFinalTex();
		// SaveFinalTex();
	}

	function SaveTextures() {
		//var curve : ColorCorrectionCurves = serObj.targetObject as ColorCorrectionCurves;
		if(useDepthCorrection) {
			SaveTex("Gen_CC_RgbTex.png", rgbChannelTex);
			SaveTex("Gen_CC_RgbDepthTex.png", rgbDepthChannelTex);
			SaveTex("Gen_CC_ZCurveTex.png", zCurveTex);
		} else {
			Debug.Log("do not save texture for simple mode");
		}

		if(selectiveCc) {
			Debug.Log("do not save selective data");
		}
	}

	public function SaveFinalTex() {
		if(useDepthCorrection) {
			UpdateFinalTex();
			SaveTex("Gen_CC_FinalTex.png", finalTex);
		}
	}

	function SaveTex(name, tex : Texture2D) {
		var bytes = tex.EncodeToPNG();
	    var file = new File.Open(Application.dataPath + "/" + name, FileMode.Create);
	    var binary = new BinaryWriter(file);
	    binary.Write(bytes);
	    file.Close();
	}
	
	function OnRenderImage (source : RenderTexture, destination : RenderTexture) {
		if(CheckResources()==false) {
			//Debug.Log("direct blit...");
			Graphics.Blit (source, destination);
			return;
		}
		
		if (updateTexturesOnStartup) {
			UpdateParameters ();
			updateTexturesOnStartup = false;
		}
		
		if (useDepthCorrection)
			camera.depthTextureMode |= DepthTextureMode.Depth;			
		
		var renderTarget2Use : RenderTexture = destination;
		
		if (selectiveCc) {
			renderTarget2Use = RenderTexture.GetTemporary (source.width, source.height);
		}
		
		if (useDepthCorrection) {
			//Debug.Log("depth blit...");
			ccDepthMaterial.SetTexture ("_RgbTex", rgbChannelTex);
			ccDepthMaterial.SetTexture ("_ZCurve", zCurveTex);
			ccDepthMaterial.SetTexture ("_RgbDepthTex", rgbDepthChannelTex);
			ccDepthMaterial.SetFloat ("_Saturation", saturation);
	
			Graphics.Blit (source, renderTarget2Use, ccDepthMaterial); 	
		} 
		else {
			//Debug.Log("normal blit");
			ccMaterial.SetTexture ("_RgbTex", rgbChannelTex);
			ccMaterial.SetFloat ("_Saturation", saturation);
			
			Graphics.Blit (source, renderTarget2Use, ccMaterial); 			
		}
		
		if (selectiveCc) {
			//Debug.Log("select blit...");
			selectiveCcMaterial.SetColor ("selColor", selectiveFromColor);
			selectiveCcMaterial.SetColor ("targetColor", selectiveToColor);
			Graphics.Blit (renderTarget2Use, destination, selectiveCcMaterial); 	
			
			RenderTexture.ReleaseTemporary (renderTarget2Use);
		}
	}
}
#pragma strict

import System.IO;

@script ExecuteInEditMode
@script AddComponentMenu ("ZSL/Move Normal")

public class ZSLMoveNormal extends MonoBehaviour
{
    private var material : Material;
    public var shader : Shader;
    
    public var color : Color;
    public var mainTex : Texture2D;

    private var attenTex : Texture2D;
    //private var brightTex : Texture2D;

    public var attenChannel : AnimationCurve;
    //public var brightChannel : AnimationCurve;

    private var updateParamStartup : boolean = true;

    public function Start() : void {
        //Debug.Log("Start....");
        if(shader == null) {
            shader = Shader.Find("ZSL/MoveNormal/Diffuse");
        }
        if(shader == null) {
            Debug.LogError("shader is null!");
            return;
        }

        material = new Material(shader);

        attenTex = new Texture2D(256, 1, TextureFormat.ARGB32, false, true);
        attenTex.hideFlags = HideFlags.None;
        attenTex.wrapMode = TextureWrapMode.Clamp;
        //finalTex.anisoLevel = 9;
        //finalTex.filterMode = FilterMode.Trilinear;

        // brightTex = new Texture2D(256, 1, TextureFormat.ARGB32, false, true);
        // brightTex.hideFlags = HideFlags.None;
        // brightTex.wrapMode = TextureWrapMode.Clamp;

        gameObject.renderer.material = material;
    }

    public function Update() : void {
        if(updateParamStartup) {
            UpdateParams();
            updateParamStartup = false;
        }

        UpdateMat();
    }

    public function SaveTextures() : void {
        SaveTex("_AttenTex", attenTex);
        //SaveTex("_BrightTex", brightTex);
    }

    function SaveTex(name, tex : Texture2D) {
        var bytes = tex.EncodeToPNG();
        var file = new File.Open(Application.dataPath + "/" + name, FileMode.Create);
        var binary = new BinaryWriter(file);
        binary.Write(bytes);
        file.Close();
    }

    public function UpdateParams() : void {
        //Debug.Log("Update params...");
        if(attenChannel == null) { // || brightChannel == null) {
            Debug.Log("anim curve is null");
            return;
        }

        for (var i : float = 0.0f; i <= 1.0f; i += 1.0f / 255.0f) {
            var atten : float = Mathf.Clamp (attenChannel.Evaluate(i), 0.0f, 1.0f);
            attenTex.SetPixel(Mathf.Floor(i*255.0f), 0, Color(atten,atten,atten, atten));
            
            // var bright : float = Mathf.Clamp (brightChannel.Evaluate(i), 0.0f, 10.0f);
            // brightTex.SetPixel(Mathf.Floor(i*255.0f), 0, Color(bright,bright,bright, bright));
        }
        
        attenTex.Apply();
        //brightTex.Apply();
    }

    function UpdateMat() {
        if(material == null) return;

        material.SetColor("_MainColor", color);
        material.SetTexture("_MainTex", mainTex);
        material.SetTexture("_AttenTex", attenTex);
        //material.SetTexture("_BrightTex", brightTex);
    }
}
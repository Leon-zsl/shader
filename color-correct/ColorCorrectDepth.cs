using UnityEngine;

[RequireComponent (typeof(Camera))]
[ExecuteInEditMode]
[AddComponentMenu("ZSL/Image Effects/Color Correction Depth(Ramp)")] 
public class ColorCorrectDepth : MonoBehaviour {
    public Texture texRamp;
    public float saturation = 1.0f;

    public Shader shader;
    private Material material;

    public void Start() {
        //shader = Shader.Find("ZSL/PostProc/ColorCorrectDepth");
        if(shader == null) {
            Debug.LogError("can not find shader ZSL/PostProc/ColorCorrectDepth");
            return;
        }

        material = new Material(shader);
    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if(material == null) {
            return;
        }

        camera.depthTextureMode |= DepthTextureMode.Depth;

        material.SetFloat("_Saturation", saturation);
        material.SetTexture("_RampTex", texRamp);
        Graphics.Blit(source, destination, material);
    }
} 
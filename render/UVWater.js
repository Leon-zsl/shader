#pragma strict

public var scaleSpeed : Vector2;
public var offsetSpeed : Vector2;

private var scale : Vector2;
private var offset : Vector2;

function Start() {
    if(renderer == null || renderer.material == null) return;
    
    offset = renderer.material.mainTextureOffset;
    scale = renderer.material.mainTextureScale;
}

function Update() {
    if(renderer == null || renderer.material == null) return;

    var s = Time.deltaTime * scaleSpeed;
    scale += s;
    var o = Time.deltaTime * offsetSpeed;
    offset += o;

    renderer.material.mainTextureScale = scale;
    renderer.material.mainTextureOffset = offset;
}
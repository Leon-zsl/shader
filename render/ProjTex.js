#pragma strict

public var scaleSpeed : Vector2;
public var offsetSpeed : Vector2;

private var scale : Vector2;
private var offset : Vector2;

function Start() {
    var proj : Projector = GetComponent(Projector);
    if(proj == null || proj.material == null) return;
    
    offset = proj.material.mainTextureOffset;
    scale = proj.material.mainTextureScale;
}

function Update() {
    var proj : Projector = GetComponent(Projector);
    if(proj == null || proj.material == null) return;

    var s = Time.deltaTime * scaleSpeed;
    scale += s;
    var o = Time.deltaTime * offsetSpeed;
    offset += o;

    proj.material.mainTextureScale = scale;
    proj.material.mainTextureOffset = offset;

    // var m : Matrix4x4 = transform.worldToLocalMatrix;
    // var p : Matrix4x4 = Matrix4x4.Perspective(proj.fieldOfView,proj.aspectRatio,
    //     proj.nearClipPlane, proj.farClipPlane);
    // proj.material.SetMatrix("_ModelView", m);
    // proj.material.SetMatrix("_Projection", p);
}
#pragma strict

@CustomEditor(ZSLMoveNormal)

class ZSLMoveNormalEditor extends Editor {
    var serObj : SerializedObject;  
    
    var attenChannel : SerializedProperty;
//    var brightChannel : SerializedProperty;
    
    var color : SerializedProperty;
    var mainTex : SerializedProperty;

    private var applyCurveChanges : boolean = false;
    
    function OnEnable () {
        serObj = new SerializedObject (target);
        
        attenChannel = serObj.FindProperty ("attenChannel");
 //       brightChannel = serObj.FindProperty ("brightChannel");
         
        color = serObj.FindProperty("color");
        mainTex = serObj.FindProperty("mainTex");
                
        if (!attenChannel.animationCurveValue.length) 
            attenChannel.animationCurveValue = new AnimationCurve(Keyframe(0, 0.0, 1.0, 1.0), Keyframe(1, 1.0, 1.0, 1.0));
        // if (!brightChannel.animationCurveValue.length) 
        //     brightChannel.animationCurveValue = new AnimationCurve(Keyframe(0, 0.0, 1.0, 1.0), Keyframe(1, 1.0, 1.0, 1.0));      
                    
        serObj.ApplyModifiedProperties ();        
    }
    
    function CurveGui (name : String, animationCurve : SerializedProperty, color : Color) {
        // @NOTE: EditorGUILayout.CurveField is buggy and flickers, using PropertyField for now
        //animationCurve.animationCurveValue = EditorGUILayout.CurveField (GUIContent (name), animationCurve.animationCurveValue, color, Rect (0.0,0.0,1.0,1.0));
        EditorGUILayout.PropertyField (animationCurve, GUIContent (name));
        if (GUI.changed) 
            applyCurveChanges = true;
    }
    
    function BeginCurves () {
        applyCurveChanges = false;
    }
    
    function ApplyCurves () {
        if (applyCurveChanges) {
            serObj.ApplyModifiedProperties ();   
            (serObj.targetObject as ZSLMoveNormal).gameObject.SendMessage ("UpdateParams");
       }    
    }

    function ExportTex() {
        if(serObj == null) return;
        var cur : ZSLMoveNormal = serObj.targetObject as ZSLMoveNormal;
        cur.SaveTextures();
    }
            
    function OnInspectorGUI () {
        serObj.Update ();
        
        GUILayout.Label ("Use curves to tweak atten and bright channel", EditorStyles.miniBoldLabel);

        if(GUILayout.Button("Export Texture")) {
            ExportTex();
        }

        EditorGUILayout.Separator ();               

        BeginCurves ();
                        
        CurveGui (" Atten", attenChannel, Color.red);
//        CurveGui (" Bright", brightChannel, Color.green);
        
        EditorGUILayout.Separator ();
        
        EditorGUILayout.PropertyField (color, GUIContent ("Color"));   
        EditorGUILayout.PropertyField (mainTex, GUIContent ("Main Tex"));
        
        ApplyCurves ();

        if (!applyCurveChanges)
            serObj.ApplyModifiedProperties ();         
    }
}
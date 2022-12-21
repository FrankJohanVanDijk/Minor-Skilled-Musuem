using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Scaler))]
public class ScalerEditor : Editor
{

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        Scaler scaler = (Scaler)target;

        GUILayout.BeginHorizontal();

        if(GUILayout.Button("Scale up or down"))
        {
            scaler.ScaleUpOrDown();
        }

        if(GUILayout.Button("Go back one step"))
        {
            scaler.GoBackOneStep();
        }

        GUILayout.EndHorizontal();

        if(GUILayout.Button("Reset Scale"))
        {
            scaler.ResetScale();
        }
    }
}

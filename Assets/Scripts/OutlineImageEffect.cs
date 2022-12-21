using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class OutlineImageEffect : MonoBehaviour
{
    public Material outlineMaterial;

    //[ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (outlineMaterial != null)
        {
            Graphics.Blit(source, destination, outlineMaterial);
        }
    }
}

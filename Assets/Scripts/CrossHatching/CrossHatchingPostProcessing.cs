using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CrossHatchingPostProcessing : MonoBehaviour
{
    public Material crossHatchingMat;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, crossHatchingMat);
    }
}

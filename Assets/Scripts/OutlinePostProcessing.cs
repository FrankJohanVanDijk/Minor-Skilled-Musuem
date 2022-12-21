using UnityEngine;
using System.Collections;

public class OutlinePostProcessing : MonoBehaviour
{
    private Camera _camera;
    public Shader Post_Outline;
    public Shader DrawSimple;
    public Color outlineColor;
    [Range(2,50)]
    public int outlineSize = 2;
    private Camera _tempCam;
    private Material _post_Mat;
    private int _outlineSizeX;
    private int _outlineSizeY;

    void Start()
    {
        _camera = GetComponent<Camera>();
        _tempCam = new GameObject().AddComponent<Camera>();
        _tempCam.enabled = false;
        _post_Mat = new Material(Post_Outline);
        
    }

    public void ChangeOutlineSize(float newSize)
    {
        outlineSize = (int)newSize;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _outlineSizeX = outlineSize;
        _outlineSizeY = outlineSize;

        //set up a temporary camera
        _tempCam.CopyFrom(_camera);
        _tempCam.clearFlags = CameraClearFlags.Color;
        _tempCam.backgroundColor = Color.black;

        //cull any layer that isn't the outline
        _tempCam.cullingMask = 1 << LayerMask.NameToLayer("Outline");

        //make the temporary rendertexture
        RenderTexture TempRT = new RenderTexture(source.width, source.height, 0, RenderTextureFormat.R8);

        //put it to video memory
        TempRT.Create();

        //set the camera's target texture when rendering
        _tempCam.targetTexture = TempRT;

        _post_Mat.SetTexture("_SceneTex", source);
        _post_Mat.SetColor("_outlineColor", outlineColor);
        _post_Mat.SetInt("_outlineSizeX", _outlineSizeX);
        _post_Mat.SetInt("_outlineSizeY", _outlineSizeY);

        //render all objects this camera can render, but with our custom shader. Otherwise know as a replacement shader
        _tempCam.RenderWithShader(DrawSimple, "");
        //this cam renders to TempRT and not the screen

        //copy the temporary RT to the final image
        Graphics.Blit(TempRT, destination, _post_Mat);

        //release the temporary RT
        TempRT.Release();
    }

}
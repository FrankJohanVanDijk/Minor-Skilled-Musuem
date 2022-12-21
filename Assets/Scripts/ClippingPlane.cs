using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ClippingPlane : MonoBehaviour
{
    //material we pass the values to
    public Material mat;

    private Plane _plane;
    

    private void Awake()
    {
        //create plane
        _plane = new Plane(transform.up, transform.position);
    }

    //execute every frame
    void Update()
    {
        //Update plane
        _plane.SetNormalAndPosition(transform.up, transform.position);
        //transfer values from plane to vector4
        Vector4 planeRepresentation = new Vector4(_plane.normal.x, _plane.normal.y, _plane.normal.z, _plane.distance);
        //pass vector to shader
        mat.SetVector("_plane", planeRepresentation);
    }
}

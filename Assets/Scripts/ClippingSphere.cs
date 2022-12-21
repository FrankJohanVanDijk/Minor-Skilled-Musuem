using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ClippingSphere : MonoBehaviour
{
    //material we pass the values to
    public Material mat;

    private float _radius;

    private void Start()
    {
        _radius = GetComponent<MeshFilter>().sharedMesh.bounds.extents.x * transform.localScale.x;
        //_radius = GetComponent<SphereCollider>().radius;
    }
    // Update is called once per frame
    void Update()
    {
        Vector4 sphereRepresentation = new Vector4(transform.position.x, transform.position.y, transform.position.z, _radius);
        //Debug.Log("Radius: " + _radius);
        //Debug.DrawLine(transform.position, new Vector3(transform.position.x + _radius, transform.position.y, transform.position.z));
        mat.SetVector("_sphere", sphereRepresentation);
    }
}

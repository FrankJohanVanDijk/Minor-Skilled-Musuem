using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MorphingScript : MonoBehaviour
{
    public Mesh meshA;
    private MeshFilter _currentMesh;
    public Mesh meshB;
    private Material _mat;

    void Awake()
    {
        _currentMesh = gameObject.GetComponent<MeshFilter>();
        _mat = gameObject.GetComponent<MeshRenderer>().material;
        Debug.Log("VertexCount: " + _currentMesh.mesh.vertexCount);

        if(meshA == null)
        {
            meshA = _currentMesh.mesh;
        }

        float groupDivider = 1;
        Vector3[] smallestMesh;
        
        if (meshA.vertexCount > meshB.vertexCount)
        {
            _currentMesh.mesh = meshA;
            groupDivider = Mathf.Ceil((float)meshA.vertexCount / (float)meshB.vertexCount);
            smallestMesh = meshB.vertices;
        }
        else
        {
            _currentMesh.mesh = meshB;
            groupDivider = Mathf.Ceil((float)meshB.vertexCount / (float)meshA.vertexCount);
            smallestMesh = meshA.vertices;
        }

        Vector4[] smallestMeshV4 = new Vector4[smallestMesh.Length];

        for (int i = 0; i < smallestMesh.Length; i++)
        {
            smallestMeshV4[i] = new Vector4(smallestMesh[i].x, smallestMesh[i].y, smallestMesh[i].z, 1);
        }

        _mat.SetVectorArray("_meshBVerts", smallestMeshV4);
        
        _mat.SetFloat("_groupDivider", groupDivider);
    }

}

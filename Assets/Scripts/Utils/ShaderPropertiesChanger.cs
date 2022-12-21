using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ShaderPropertiesChanger : MonoBehaviour
{
    private Material _material;
    private int _propId = 0;
    private float _newValue = 0;
    public Material mat;
    public string[] propNames;
    public Vector2[] propSinRangePlusOffset;
    public bool updateValue1 = false;
    public float speed = 1.5f;
    
    //public Vector4[] minMaxValues;

    void Start()
    {
        if (mat == null)
        {
            _material = GetComponent<MeshRenderer>().sharedMaterial;
            
        }
        else
        {
            _material = mat;
        }
        Debug.Log("I got mat: " + _material.name);
    }

    private void Update()
    {
        if(updateValue1)
        {
            _newValue = Mathf.Sin(Time.fixedTime * speed) * (propSinRangePlusOffset[_propId].x * 0.5f) + (propSinRangePlusOffset[_propId].x * 0.5f) + propSinRangePlusOffset[_propId].y;
            _material.SetFloat(propNames[_propId], _newValue);
        }
    }

    public void TurnOnOff()
    {
        updateValue1 = !updateValue1;
    }

    public void SetPropId(int pPropId)
    {
        updateValue1 = false;
        _propId = pPropId;
    }

    public void ChangeProp(float pNewValue)
    {
        if (_material != null)
        {
            _material.SetFloat(propNames[_propId], pNewValue);
        }
    }
}

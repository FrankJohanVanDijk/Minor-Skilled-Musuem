using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirtyCheck : MonoBehaviour
{
    private BoxCollider _middleWallPart;
    private Transform _child;

    public float minimumX;
    public float maximumX;
    public float minimumY;
    public float maximumY;

    void Awake()
    {
        BoxCollider[] boxColliders = GetComponents<BoxCollider>();
        _middleWallPart = boxColliders[2];

        Transform[] children = GetComponentsInChildren<Transform>();
        _child = children[1];
    }

    // Update is called once per frame
    void Update()
    {
        CheckEnableOrDisable();
    }

    void CheckEnableOrDisable()
    {
        if(_middleWallPart.enabled)
        {
            //Debug.Log("Box still enabled");
            if(InsideAssignedArea())
            {
                //Debug.Log("Box turning off");
                _middleWallPart.enabled = false;
            }
        }
        if(!_middleWallPart.enabled)
        {
            //Debug.Log("Box still disabled");
            if (!InsideAssignedArea())
            {
                //Debug.Log("Box turning on");
                _middleWallPart.enabled = true;
            }
        }
    }

    bool InsideAssignedArea()
    {
        //Debug.Log("Child " + _child.name + " with x:" + _child.localPosition.z + ", y:" + _child.localPosition.y);
        if(minimumX <= _child.localPosition.z && _child.localPosition.z <= maximumX)
        {
            if(minimumY <= _child.localPosition.y && _child.localPosition.y <= maximumY)
            {
                return true;
            }
        }

        return false;
    }
}

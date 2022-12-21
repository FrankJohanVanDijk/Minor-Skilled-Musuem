using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DirtyMovementClipPlanes : MonoBehaviour
{
    public void RotateX(float newXrotation)
    {
        Quaternion temp = transform.localRotation;
        temp.eulerAngles = new Vector3(newXrotation, temp.eulerAngles.y, temp.eulerAngles.z);
        transform.localRotation = temp;
        //transform.Rotate(newXrotation, 0, 0);
        //transform.Rotate(new Vector3(1, 0, 0), newXrotation);
    }

    public void RotateY(float newYrotation)
    {
        Quaternion temp = transform.localRotation;
        temp.eulerAngles = new Vector3(temp.eulerAngles.x, newYrotation, temp.eulerAngles.z);
        transform.localRotation = temp;
        //transform.Rotate(new Vector3(0, 1, 0), newYrotation);
    }

    public void RotateZ(float newZrotation)
    {
        Quaternion temp = transform.localRotation;
        temp.eulerAngles = new Vector3(temp.eulerAngles.x, temp.eulerAngles.y, newZrotation);
        transform.localRotation = temp;
        //transform.Rotate(new Vector3(0, 0, 1), newZrotation);
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Scaler : MonoBehaviour
{
    public float scaleValue = 2;
    private Vector3 _originalValues;
    private Vector3 _previousScale;

    void Awake()
    {
        _originalValues = transform.localScale;
        _previousScale = _originalValues;
    }

    public void ScaleUpOrDown()
    {
        Vector3 temp = transform.localScale;
        _previousScale = temp;
        temp.Scale(new Vector3(scaleValue,scaleValue,scaleValue));
        transform.localScale = temp;
    }

    public void GoBackOneStep()
    {
        transform.localScale = _previousScale;
    }

    public void ResetScale()
    {
        transform.localScale = _originalValues;
    }
}

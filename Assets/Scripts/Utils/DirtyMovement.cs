using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirtyMovement : MonoBehaviour
{
   

    //public float maxSpeed = 1.5f;
    //public float acceleration = 0.1f;
    private float _currentSpeed = 0.5f;

    public float minimumX;
    public float maximumX;
    public float minimumY;
    public float maximumY = 6;
    
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        /*
        //_currentSpeed -= acceleration * 0.25f;
        if(_currentSpeed < 0)
        {
            _currentSpeed = 0;
        }
        if(_currentSpeed > maxSpeed)
        {
            _currentSpeed = maxSpeed;
        }*/
        CheckInArea();
    }

    void CheckInArea()
    {
        Vector3 temp = transform.localPosition;
        if(temp.z < minimumX)
        {
            temp.z = minimumX;
        }
        if(temp.z > maximumX)
        {
            temp.z = maximumX;
        }
        if(temp.y < minimumY)
        {
            temp.y = minimumY;
        }
        if(temp.y > maximumY)
        {
            temp.y = maximumY;
        }
        transform.localPosition = temp;
    }

    public void Up()
    {
        Move(0, 1);
    }

    public void Down()
    {
        Move(0, -1);
    }

    public void Left()
    {
        Move(1, 0);
    }

    public void Right()
    {
        Move(-1, 0);
    }

    private void Move(int pX, int pY) //pX and pY only surposed to be 0 or 1 or -1
    {

        //Debug.Log("I have been clicked");
        //_currentSpeed += acceleration;
        Vector3 temp = transform.localPosition;
        temp.z += _currentSpeed * pX;
        temp.y += _currentSpeed * pY;
        transform.localPosition = temp;
    }
    

}

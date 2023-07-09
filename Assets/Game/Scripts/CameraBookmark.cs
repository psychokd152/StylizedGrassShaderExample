using UnityEngine;
using UnityEditor;
using System;

[Serializable]
public class Bookmark
{
    public Transform viewTransform;

    public int fieldOfView;
}

[ExecuteInEditMode]
public class CameraBookmark : MonoBehaviour
{
   public Bookmark[] bookmark;

    [Range(0, 20)]
    public int bookmarkNumber;

    void OnEnable()
    {
        SetCameraToBookmark();
    }

    void OnValidate()
    {
        // Debug.Log("Check");
        SetCameraToBookmark();
    }
    
    public void SetCameraToBookmark()
    {
        if (bookmarkNumber >= 0 && bookmarkNumber < bookmark.Length)
        {
            Transform bookmarkView = bookmark[bookmarkNumber].viewTransform;
            SceneView sceneCam = SceneView.lastActiveSceneView;

            if (sceneCam != null)
            {
                sceneCam.cameraSettings.fieldOfView = bookmark[bookmarkNumber].fieldOfView;
                sceneCam.AlignViewToObject(bookmarkView);
                // sceneCam.Repaint();
            }
        
        }
        else
        {
            Debug.LogWarning("Invalid Bookmark Number!");
        }
    }
}

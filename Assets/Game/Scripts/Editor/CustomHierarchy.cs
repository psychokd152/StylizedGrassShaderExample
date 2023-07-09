using System.Linq;
using UnityEditor;
using UnityEngine;

[InitializeOnLoad]
public class CustomHierarchy : MonoBehaviour
{
    private static Vector2 offset = new Vector2(-20, 0);

    static CustomHierarchy()
    {
        EditorApplication.hierarchyWindowItemOnGUI += HandleHierarchyWindowItemOnGUI;
    }

    private static void HandleHierarchyWindowItemOnGUI(int instanceID, Rect selectionRect)
    {
        Color fontColor = Color.white;
        // Color backgroundColor = new Color(.76f, .76f, .76f);
        Color backgroundColor = new Color(0.3176471f, 0.3176471f, 0.3176471f);

        var obj = EditorUtility.InstanceIDToObject(instanceID);
        if (obj != null && obj is GameObject gameObject)
        {
            // var prefabAssetType = PrefabUtility.GetPrefabAssetType(obj);
            // var prefabInstanceStatus = PrefabUtility.GetPrefabInstanceStatus(obj);

            // if (prefabAssetType == PrefabAssetType.Regular && prefabInstanceStatus == PrefabInstanceStatus.Connected)
            if (/*gameObject.transform.childCount == 0 &&*/ gameObject.name.Contains("#"))
            {                
                if (Selection.instanceIDs.Contains(instanceID))
                {
                    fontColor = Color.white;
                    backgroundColor = new Color(0.24f, 0.48f, 0.90f);
                }

                Rect offsetRect = new Rect(selectionRect.position + offset, selectionRect.size);

                EditorGUI.DrawRect(new Rect(selectionRect.position + new Vector2(-28, 0), selectionRect.size + new Vector2(45, 0)), backgroundColor);

                EditorGUI.LabelField(offsetRect, obj.name, new GUIStyle()
                {
                    normal = new GUIStyleState() { textColor = fontColor },
                    fontStyle = FontStyle.Bold
                }
                );
            }
        }
    }
}
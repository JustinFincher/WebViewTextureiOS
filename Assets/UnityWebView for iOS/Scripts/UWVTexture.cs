using UnityEngine;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using UnityEngine.UI;

#if UNITY_EDITOR
using UnityEditor;

[CustomEditor (typeof(UWVTexture))]
public class UWVTextureEditor : Editor
{
	public void OnSceneGUI ()
	{
		UWVTexture UWVTextureRawImage = (UWVTexture)target;
	}
	public void OnEnable()
	{
	}

	public override void OnInspectorGUI ()
	{
		UWVTexture UWVTextureRawImage = (UWVTexture)target;

		UWVTextureRawImage.textureType = (UWVTextureFormatType)EditorGUILayout.EnumPopup ("Texture Format", UWVTextureRawImage.textureType);
		UWVTextureRawImage.graphicAPIType = (UWVTextureGraphicAPIType)EditorGUILayout.EnumPopup ("Graphic API", UWVTextureRawImage.graphicAPIType);

		UWVTextureRawImage.width = EditorGUILayout.IntField ("Width",UWVTextureRawImage.width);
		UWVTextureRawImage.height = EditorGUILayout.IntField ("Height",UWVTextureRawImage.height);

		if (GUI.changed)
		{
			EditorUtility.SetDirty (UWVTextureRawImage);
		}

		Undo.RecordObject (UWVTextureRawImage, "UWVTextureRawImage Preferences Changed: " + UWVTextureRawImage.name);
	}
}
#endif

public enum UWVTextureFormatType 
{
	PVRTC_RGBA4 = 0,
	PVRTC_RGB4 = 1,
	PVRTC_RGBA2 = 2,
	PVRTC_RGB2 = 3,
	RGB24 = 4,
	RGBA32 = 5,
	ARGB32 = 6
}
public enum UWVTextureGraphicAPIType 
{
	Metal = 0,
	OpenGL = 1,
	Auto = 2,
}

public class UWVTexture : MonoBehaviour 
{
	private Texture2D webViewTexture;
	public int height;
	public int width;
	public UWVTextureFormatType textureType;
	public UWVTextureGraphicAPIType graphicAPIType;
	public string webURL;

	private int webViewIndex = -1;

	void Awake()
	{
		switch ((int)textureType)
		{
			case 0:
				webViewTexture = new Texture2D (width, height, TextureFormat.PVRTC_RGBA4, false);
				break;
			case 1:
				webViewTexture = new Texture2D (width, height, TextureFormat.PVRTC_RGB4, false);
				break;
			case 2:
				webViewTexture = new Texture2D (width, height, TextureFormat.PVRTC_RGBA2, false);
				break;
			case 3:
				webViewTexture = new Texture2D (width, height, TextureFormat.PVRTC_RGB2, false);
				break;
			case 4:
				webViewTexture = new Texture2D (width, height, TextureFormat.RGB24, false);
				break;
			case 5:
				webViewTexture = new Texture2D (width, height, TextureFormat.RGBA32, false);
				break;
			case 6:
				webViewTexture = new Texture2D (width, height, TextureFormat.ARGB32, false);
				break;
		}
		webViewTexture.filterMode = FilterMode.Bilinear;
		webViewTexture.wrapMode = TextureWrapMode.Clamp;
	}
	// Use this for initialization
	void Start ()
	{
		//test
		UWVHelloFromUnity();
		//create webview and get index in nsmutablearray
		webViewIndex = UWVCreateWebView (width, height);
		//get texture intptr and send to objC side
		UWVSetWebViewTexturePtr (webViewIndex, webViewTexture.GetNativeTexturePtr ());
	}
	
	// Update is called once per frame
	void Update () 
	{
	}

	void LateUpdate ()
	{
		if (webViewIndex >= 0)
		{
			UWVUpdateWebViewTexture (webViewIndex);
			if (gameObject.GetComponent <RawImage>().texture != webViewTexture)
			{
				gameObject.GetComponent <RawImage>().texture = webViewTexture;
				Debug.Log ("gameObject.GetComponent <RawImage>().texture = webViewTexture;");
			}
		}
	}

	[DllImport ("__Internal")]
	public static extern int UWVCreateWebView(float width, float height);
	[DllImport ("__Internal")]
	public static extern void UWVUpdateWebView(int index, float width, float height);
	[DllImport ("__Internal")]
	public static extern void UWVSetWebViewTexturePtr(int index, IntPtr ptr);
	[DllImport ("__Internal")]
	public static extern void UWVUpdateWebViewTexture(int index);
	[DllImport("__Internal")]
	public static extern void UWVHelloFromUnity();
}

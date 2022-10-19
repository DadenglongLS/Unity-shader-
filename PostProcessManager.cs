using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class PostProcessManager : MonoBehaviour
{
    public Shader PostShader;
    private Material mat;
    public Color color = Color.white;
    [Header("黑白阈值")]
    [Range(0, 1f)] public float BlackToWhite = 0.5f;
    [Header("黑白射线控制（XY（平铺值)ZW(XY流动速度)")]
    public Vector4 _NoiseTexvalue;
    // public float _NoiseTexvaluey;
    public Texture2D noisetex;
    // public float _Speed;
    [Header("饱和度")]
    [Range(0, 3f)] public float Luminance = 1f;
    [Header("对比度")]
    [Range(0, 3f)] public float Contrast = 1f;
    [Header("径向模糊的迭代次数")]
    [Range(1, 50)] public int _Iteration = 30;
    [Header("径向模糊的迭代半径")]
    [Range(0, 0.03f)] public float BlurRadius = 0.01f;
    [Header("径向模糊的中心点")]
    public Vector2 BlurCenter = new Vector2(0.5f, 0.5f);

    //材质属性只读
    public Material Mat
    {
        get
        {
            //如果面板没有指定shader
            if (PostShader == null)
            {
                Debug.LogError("Shder没有指定");
                return null;
            }
            //如果shader不支持
            if (!PostShader.isSupported)
            {
                Debug.LogError("Shder不被支持");
                return null;
            }
            if (mat == null)
            {
                Material postmat = new Material(PostShader);//新建材质
                postmat.hideFlags = HideFlags.HideAndDontSave;//设置材质的标签 隐藏并不保存
                mat = postmat;
                return mat;

            }
            else
            {
                return mat;
            }

        }


    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Mat.SetTexture("_NoiseTex", noisetex);
        Mat.SetVector("_NoiseTexvalue", _NoiseTexvalue);
        // Mat.SetFloat("_NoiseTexvalue", _NoiseTexvaluey);

        // Mat.SetFloat("_Speed", _Speed);
        Mat.SetFloat("_BWSet", BlackToWhite);
        Mat.SetFloat("_Luminance", Luminance);
        Mat.SetFloat("_Contrast", Contrast);
        Mat.SetInt("_Iteration", _Iteration);
        Mat.SetFloat("_BlurRadius", BlurRadius);
        Mat.SetFloat("_BlurCenterX", BlurCenter.x);
        Mat.SetFloat("_BlurCenterY", BlurCenter.y);
        Mat.SetColor("_Color", color);

        Graphics.Blit(src, dest, Mat);

    }
}

Shader "TaLs/PostImageEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Texture", 2D) = "white" {}
        // _NoiseTexvalue("NoiseTexvalue",Vector)=(0,0,0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"
            

            

            sampler2D _MainTex,_NoiseTex;
            float _BWSet;
            float _BlurCenterX;
            float _BlurCenterY;
            float _BlurRadius;
            float _Iteration;
            float4 _Color;
            float4 _NoiseTexvalue;
            float _Luminance,_Contrast ;
            //径向模糊
            half4 RadialBlur(v2f_img i)
            {
                float2 blurVector = (float2(_BlurCenterX,_BlurCenterY) - i.uv.xy) * _BlurRadius;
                

                half4 acumulateColor = half4(0, 0, 0, 0);

                for (int j = 0; j < _Iteration; j ++)
                {
                    acumulateColor += tex2D(_MainTex, i.uv);

                    i.uv.xy += blurVector;
                }

                return acumulateColor/_Iteration;
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                //【定位uv原点】
                float2 uv0 = i.uv - float2(_BlurCenterX,_BlurCenterY);      //将uv(0.5 , 0.5)移动至原点 ，现在uv的范围是[-0.5 ,0.5]
                //【角度theta】
                float theta = atan2(uv0.y , uv0.x);             //角度,范围(-PI , PI]
                theta = theta / 3.1415927 * 0.5 + 0.5;    //Remap,角度范围(0 ,1]
                //【半径r】有流动效果
                float r = length(uv0) ;
                
                //【计算极坐标uv】
                float2 PolarUV = float2(theta , r)+ _Time.y *_NoiseTexvalue.zw;

                float4 noisetex=     tex2D(_NoiseTex, float2(PolarUV.x*_NoiseTexvalue.x,PolarUV.y*_NoiseTexvalue.y));
                // return noisetex;
                
                float4 c;
                //径向模糊
                c=RadialBlur(i);
                //饱和度
                c=lerp(Luminance(c.rgb),c,_Luminance);
                //色相
                float3 graycolor=fixed3(0.5,0.5,0.5);
                c.rgb=lerp(graycolor,c.rgb,_Contrast);
                
                
                
                //反向控制
                float  bw=saturate(1-c);
                
                c*=noisetex.r;
                c=step(c.r,_BWSet);
                
                c*=_Color;
                return c;
            }
            ENDCG
        }
    }
}

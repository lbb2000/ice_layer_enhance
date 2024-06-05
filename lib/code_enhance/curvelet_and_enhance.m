function [data_curvelet] = curvelet_and_enhance(data1,data2,index)   %data原始数据，index为需要优化的尺度, threshold阈值
[Sample_num,N_trace]=size(data1);  %Sample_num：距离向采样点数    N_trace：道数
scale=ceil(log2(min(Sample_num,N_trace))-3);
%% 变换到曲波域
C0=fdct_wrapping(((normalize(data1))),1,2,scale,64);
C1= fdct_wrapping(data1,1,2,scale,64);    %C1：含噪图像曲波系数
C2= fdct_wrapping((normalize(data2)),1,2,scale,64);    %C2：随机噪声曲波系数
for a=1:size(index,2)
    delta_all=[];
    C_all=[]; 
    for b=1:size(C0{1,index(a)},2)
        [m,n] = size(C0{1,index(a)}{1,b});
        delta=(abs((C0{1,index(a)}{1,b}))./abs((C2{1,index(a)}{1,b})));   %计算灵敏度
        temp =reshape(delta,1,m*n);
        delta_all=[delta_all temp];                 %同尺度经处理后的灵敏度排成1行
        temp1 =reshape(C1{1,index(a)}{1,b},1,m*n);
        C_all=[C_all temp1];                        %同尺度系数排成1行 
    end
%根据灵敏度调整同尺度内系数
    temp2 =sort(delta_all);
    temp3=temp2(1,ceil(size(temp2,2)*0.75));
    delta_all((delta_all)<temp3)=0;
    delta_all((delta_all)>=temp3)=1;
    C_all_Re=C_all.*delta_all;
%贝叶斯软阈值对调整后的同尺度系数进行处理
    sigmahat=median(abs((C_all)))/0.6745;
    threshold=bayes((C_all),sigmahat);
    C_all_Re(abs(C_all_Re)<threshold)=0;
    temp4 =sort(abs(C_all_Re));
    temp5=temp4(1,ceil(size(temp2,2)*0.95));
    temp6=temp4(1,ceil(size(temp2,2)*0.99));
    C_all_Re(abs(C_all_Re)>temp5 )=C_all_Re(abs(C_all_Re)>temp5)*1.1;  
    C_all_Re(abs(C_all_Re)>temp6 )=C_all_Re(abs(C_all_Re)>temp6)/1;  
%将处理完的阈值返回原位置
    for i=1:size(C1{1,index(a)},2)
        [m,n] = size(C1{1,index(a)}{1,i});
        C1{1,index(a)}{1,i}=reshape(C_all_Re(1:m*n),m,n);
        C_all_Re=C_all_Re(m*n+1:size(C_all_Re,2));
        if (index(a)==scale) && scale < 10 %|| index(a)==scale-2 || index(a)==scale-3 
            C1{1,index(a)}{1,i} =zeros(m,n);                             %精细尺度直接置零
        end
    end
end 
%% 变换回空间域
data_curvelet = real(ifdct_wrapping(C1,1,Sample_num,N_trace));
data_curvelet(data_curvelet<0)=0;
end
function [data_curvelet] = data_curvelet(data,index)   %data原始数据，index为需要优化的尺度, threshold阈值，times中尺度扩大比例
[Sample_num,N_trace]=size(data);  %Sample_num：距离向采样点数    N_trace：道数
scale=ceil(log2(min(Sample_num,N_trace))-3);
%% 变换到曲波域
C= fdct_wrapping((data),1,2,scale,64);    %C1：含噪图像曲波系数
for a=1:size(index,2)
    C_all=[]; 
    for b=1:size(C{1,index(a)},2)
        [m,n] = size(C{1,index(a)}{1,b});              
        temp1 =reshape(C{1,index(a)}{1,b},1,m*n);
        C_all=[C_all temp1];                        %同尺度系数排成1行 
    end
%根据灵敏度调整同尺度内系数
%贝叶斯软阈值对调整后的同尺度系数进行处理
    sigmahat=median((abs(C_all)))/0.6745;
%%%%%%%%%%%%%%%%%%%%%贝叶斯阈值
    len=length(C_all);
    sigmay2=sum((C_all).^2)/len;
    sigmax=sqrt(max(sigmay2-sigmahat^2,0));
    if sigmax==0 
        threshold=max(abs(C_all));
    else
        threshold=sigmahat^2/sigmax^2;
    end
%%%%%%%%%%%%%%%%%%%%
    C_all(abs(C_all)<1*threshold)=0;  
%将处理完的阈值返回原位置
    for i=1:size(C{1,index(a)},2)
        [m,n] = size(C{1,index(a)}{1,i});
        C{1,index(a)}{1,i}=reshape(C_all(1:m*n),m,n);
        C_all=C_all(m*n+1:size(C_all,2));
    end
end 
%% 变换回空间域
data_curvelet = real(ifdct_wrapping(C,1,Sample_num,N_trace));
end
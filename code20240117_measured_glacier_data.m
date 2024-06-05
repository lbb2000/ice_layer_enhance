%% Ice Radar Layer Data Enhancement Based on Dual-Transform Domains
%Author: Binbin Li
%date:June 4, 2024
%programing language:matlab
%Software required:Matlab 2021a
%Hardware:intel core 12900Hx
%% 读取数据
clear;clc;close all;
fn = 'data\IRACC1B_20140502_03_008.nc';  %data\IRACC1B_20140502_03_008.nc
mdata = load_L1B(fn);
addpath(genpath('lib/'));
% 数据预处理
param = [];
param.update_surf = true;
param.filter_surf = false;
param.er_ice = 3.15;  %冰盖的介电常数
param.depth = '[min(Surface_Elev)-20 max(Surface_Elev)+2]';
[mdata_WGS84,depth_good_idxs] = elevation_compensation(mdata,param);
data=double(10*log10(mdata.Data));
trace_NaN=find(isnan(mdata_WGS84.Surface_Bin));
data_1=zeros(700,size(data,2)-size(trace_NaN,2));
%data(:,trace_NaN)=[];
for i=1:size(data,2)
    if ~(ismember(i,trace_NaN))
        data_1(:,i)=data((mdata_WGS84.Surface_Bin(i)-99):(mdata_WGS84.Surface_Bin(i))+600,i);  %校正高程
    end
end
data_1(:,trace_NaN)=[];
data_coh_overlay=overlay(data_1,2);              %非相干叠加
c=3e8;                                           %光速
ts=mdata.Time(2)-mdata.Time(1);                  %采样间隔
ordinate=(-c/sqrt(param.er_ice)*99*ts:c/sqrt(param.er_ice)*ts:c/sqrt(param.er_ice)*600*ts)/2; % 纵坐标
abscissa=linspace(0,20,size(data_coh_overlay,2));%横坐标
X = data_coh_overlay;
E_sigma=NoiseEstimation(X);                      %噪声估计
%% PID
x_pid= PID(normalize(X),NoiseEstimation(normalize(X)),30);
%% 曲波变换
scale1=ceil(log2(min(size(X,1),size(X,2)))-3);   %最大尺度
Xclt=data_curvelet(X,2:scale1);                  %直接曲波变换效果
%% 剪切波变换
scales = 6;                                      %剪切波变换尺度    
thresholdingFactor =3;     
%剪切波参数生成
shearletSystem = SLgetShearletSystem2D(0,size(X,1),size(X,2),scales);
%生成剪切波分量
coeffs = SLsheardec2D((X),shearletSystem);
coeffs1=coeffs;
parfor i=1:size(coeffs1,3)
    coeffs1(:,:,i)=bayes_method(coeffs1(:,:,i));
end
Xshearlet = SLshearrec2D(coeffs1,shearletSystem);
%% 对剪切波各个分量进行处理
x_pid_temp= PID(normalize(X),NoiseEstimation(normalize(X)),12);
coeffs10 = SLsheardec2D((X-x_pid_temp),shearletSystem);                           %用于增强的噪声分量
coeffs2=coeffs;
scale=shearletSystem.shearletIdxs(:,2);
parfor i=1:size(coeffs2,3)
    temp= coeffs2(:,:,i);
    scale1=ceil(log2(min(size( coeffs2(:,:,i),1),size( coeffs2(:,:,i),2)))-3);    %曲波最大尺度
    temp1=(coeffs10(:,:,i));              
    coeffs2(:,:,i)=curvelet_and_enhance(temp,temp1,2:scale1);
end
%随尺度变化的阈值
parfor i=1:size(coeffs1,3)
    coeffs1(:,:,i)=scale_method(coeffs1(:,:,i),scale(i,:));
end
%反剪切波变换
Xcor = SLshearrec2D(coeffs2,shearletSystem);
%Xcor= PID(normalize(Xcor),0.2,15);
%% 绘图
%处理后效果
figure;
colormap(gray)
imagesc(abscissa,ordinate,X);
daspect('auto')
pbaspect('auto')
set(gca, 'Xtick',0:2:20,'FontSize', 12,'FontName','times')
title('accum 2017\_Greenland\_P3: "North Glaciers 02 Prime" 20140502\_03\_008','FontSize', 14,'FontName','times')
xlabel('distance(km)','FontSize', 14,'FontName','times')
ylabel('depth,e_r=3.15(m)','FontSize', 14,'FontName','times')
%ylim([-10,110])

figure;
colormap(gray)
imagesc(abscissa,ordinate,x_pid);
daspect('auto')
pbaspect('auto')
set(gca, 'Xtick',0:2:20,'FontSize', 12,'FontName','times')
xlabel('distance(km)','FontSize', 14,'FontName','times')
ylabel('depth,e_r=3.15(m)','FontSize', 14,'FontName','times')
ylim([-10,110])


figure;colormap(gray)
imagesc(abscissa,ordinate,Xshearlet);
daspect('auto')
pbaspect('auto')
set(gca, 'Xtick',0:2:20,'FontSize', 12,'FontName','times')
xlabel('distance(km)','FontSize', 14,'FontName','times')
ylabel('depth,e_r=3.15(m)','FontSize', 14,'FontName','times')
ylim([-10,110])

figure;colormap(gray)
imagesc(abscissa,ordinate,Xcor);
daspect('auto')
pbaspect('auto')
set(gca, 'Xtick',0:2:20,'FontSize', 12,'FontName','times')
xlabel('distance(km)','FontSize', 14,'FontName','times')
ylabel('depth,e_r=3.15(m)','FontSize', 14,'FontName','times')
ylim([-10,110])
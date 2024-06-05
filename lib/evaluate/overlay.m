function [data_overlay] = overlay(data,span)         %data原始数据，span叠加道数，data_overlay叠加后的结果
[Sample_num,N_trace]=size(data);
data_overlay=zeros(Sample_num,floor(N_trace/span));
for i=1:1:floor(N_trace/span)
   data_overlay(:,i)=sum(data(:,(i-1)*span+1:i*span),2)/span;
end
end
function sigma=NoiseEstimation(CFAN,windowsize,K,method)
if ~exist('method','var')
    method=1;
end
if ~exist('K','var')
    K=50;
end
if ~exist('windowsize','var')
    windowsize=5;

end
if windowsize==5
    load('f5x5.mat')
else
    windowsize=3;
    load('f3x3.mat')
end
width=size(CFAN,2);
height=size(CFAN,1);
radius=floor(windowsize/2);

minMeasValArr=2000+(1:K);
varArr=9*255^2+(1:K);
for i=radius+1:height-radius
    for j=radius+1:width-radius
        block=CFAN(i-radius:i+radius,j-radius:j+radius);
        if min(block(:))==0 || max(block(:))==255
            continue;
        end
        measVal1=abs(sum(sum(block.*f1)));
        measVal2=abs(sum(sum(block.*f2)));
        measVal3=abs(sum(sum(block.*f3)));
        measVal4=abs(sum(sum(block.*f4)));
        measVal5=abs(sum(sum(block.*f5)));
        measVal6=abs(sum(sum(block.*f6)));
        measVal7=abs(sum(sum(block.*f7)));
        measVal8=abs(sum(sum(block.*f8)));
        totalMeasVal=measVal1+measVal2+measVal3+measVal4+measVal5+measVal6+measVal7+measVal8;
        maxValofKMins=max(minMeasValArr);
        if totalMeasVal<maxValofKMins  % the K most homogeneous blocks
            index=find(minMeasValArr==maxValofKMins);
            minMeasValArr(index(1))=totalMeasVal;
            varBlock=var(block(:));
            varArr(index(1))=varBlock;
        end
    end
end
min3vals=mink(minMeasValArr,3);
index1=find(minMeasValArr==min3vals(1));
index2=find(minMeasValArr==min3vals(2));
index3=find(minMeasValArr==min3vals(3));
index=[index1,index2,index3];
var1=varArr(index(1));
var2=varArr(index(2));
var3=varArr(index(3));
medianVar=median([var1,var2,var3]);
refPSNR=10*log10(255^2/(medianVar+0.0001));
sumVar=0;
num=0;
for i=1:K
    psnr=10*log10(255^2/(varArr(i)+0.0001));
    if abs(psnr-refPSNR)<3
        num=num+1;
        sumVar=sumVar+varArr(i);
    end
end
sigma=sqrt(sumVar/num);
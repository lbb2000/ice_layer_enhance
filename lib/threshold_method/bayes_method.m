function C_new=bayes_method(C)
[m,n] = size(C);
temp1 =reshape(C,1,m*n);
sigmahat=median(abs((temp1)))/0.6745;
len=length(temp1);
sigmay2=sum(temp1.^2)/len;
sigmax=sqrt(max(sigmay2-sigmahat^2,0));
if sigmax==0 
    threshold=max(abs(temp1));
else
    threshold=sigmahat^2/sigmax^1;
end
C(abs(C)<threshold)=0;
C_new=C;
end

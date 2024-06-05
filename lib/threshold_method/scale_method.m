function C_new=scale_method(C,scale)
[m,n] = size(C);
temp1 =reshape(C,1,m*n);
sigma=median(abs((temp1)))/0.6745;
N=m*n;
Th_j=sigma*sqrt(2*log(N))*log10(scale+1);
C(abs(C)<Th_j)=0;
C_new=C;
end
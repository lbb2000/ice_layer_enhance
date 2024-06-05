function SNR = computeSNR(I,J)
%I为原图
%J为处理后的图
dif = (I - J).^2;
E_n=sum(sum(dif));
E_s=sum(sum(I.^2));
SNR = 10*log10(E_s/E_n);
end


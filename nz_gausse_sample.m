function [X]=nz_gauss_sample(x,mu,sigma)



X=1/sqrt(2*pi*sigma)*exp(-(x-mu)^2/2*sigma^2);


end



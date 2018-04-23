function[data]=nz_generate(mu,sigma,dim)

%dim=[250 250];
R=randn(dim);

R1=chol(sigma)*R;

data=rand(dim).*sigma+mu;
end





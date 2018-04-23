clc;
clear all;



t=linspace(1,30,50);
%y=linspace(-1,1,500);
omu1=10;
omu2=15;
osigma1=5;
osigma2=3;

x=omu1+(osigma1*rand(1,500));
y=omu2+(osigma2*rand(1,500));

xp=normpdf(t,omu1,osigma1);
yp=normpdf(t,omu2,osigma2);

% Gaussian Mixture Generate
N=length(t);
p=0.2;
mu1=0.1;
mu2=0.1;
sigma1=0.5;
sigma2=0.5;
sum_gmm=0;
sum_resp=0;
sum_resp=0;
class=2;
p_k=[];

k=0;
while(k<100)

    
    sum_gmm=0;
    sum_resp=0;
    
for i=1:N
    

       q1=xp(i);%nz_gausse_sample(xp(i),mu1,sigma1);
       q2=yp(i);%nz_gausse_sample(yp(i),mu2,sigma2);
       
   
       %loglikelihood estimation
        gmm(i)=p*q1+(1-p)*q2;
        log_gmm(i)=log(gmm(i));
        sum_gmm=sum_gmm+gmm(i);
      
       %responsibility estimation
        resp(i)=p*q1/gmm(i);
        sum_resp=sum_resp+resp(i);
        
end

        %parameter estimation
         mu1=sum(p*xp)./sum_resp;
         mu2=sum((1-p).*yp)./sum_resp;
          

        diff1=bsxfun(@minus,xp,mu1);
        cov1=diff1*diff1';
        
        diff2=bsxfun(@minus,yp,mu2);
        cov2=diff2*diff2';
        
        sigma1=sqrt(sum(p*cov1)./sum_resp);
        
        sigma2=sqrt(sum((1-p)*cov2)./sum_resp);
    
        p=sum(resp)/N;
        p_k=[p_k;p];
   
   k=k+1;

end

figure, plot(t,xp,'b');
hold on;
plot(t,yp,'r');
plot(x, zeros(size(x)), 'bx', 'markersize', 5);
plot(y, zeros(size(y)), 'rx', 'markersize', 5);hold off;
set(gcf,'color','white');

mixture=p*x+(1-p)*y;
figure, plot(gmm);
% figure, plot(p_k);

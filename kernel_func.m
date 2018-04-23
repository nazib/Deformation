function [u,v]=kernal_func(X,Y,mu,sigma)




% u=X.*exp(-X.^2-Y.^2);
% v=u';
% mu=[0 0];
% sigma=[0.1 0.1];
u=mvnpdf([X(:) Y(:)],mu,sigma);
u = reshape(u,length(Y),length(X));
%surf(X,Y,u);
v=u';


end
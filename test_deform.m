clc;
clear all;
or=rgb2gray(imread('test.jpg'));
im=double(imresize(or,[500 500]));
[M,N]=size(im);

        %% Define Grid
        k=M/2;
        
        %1st quadrent
        xcor=linspace(-1,1,M/2);
        ycor=linspace(-1,1,M/2);
        [X,Y]=meshgrid(xcor,ycor);
        
        mu1=ones(1,2)*rand;
        sigma1=ones(1,2)*rand;
        [u1,v1]=kernel_func(X,Y,mu1,sigma1);
        im1=im(1:k,1:k);
        new_im1=interp2(X,Y,im1,X-u1, Y-v1);
        
        %2nd quadrent
        im2=im(1:k,k+1:M);
        mu2=ones(1,2)*rand;
        sigma2=ones(1,2)*rand;
        [u2,v2]=kernel_func(X,Y,mu2,sigma2);
        new_im2=interp2(X,Y,im2,X+u2, Y-v2);
        
        %3rd quadrent
        im3=im(k+1:M,1:k);
        mu3=ones(1,2)*rand;
        sigma3=ones(1,2)*rand;
        [u3,v3]=kernel_func(X,Y,mu3,sigma3);
        new_im3=interp2(X,Y,im3,X-u3, Y+v3);
        
        %4th Quadrent
        im4=im(k+1:M,k+1:M);
        mu4=ones(1,2)*rand;
        sigma4=ones(1,2)*rand;
        [u4,v4]=kernel_func(X,Y,mu4,sigma4);
        new_im4=interp2(X,Y,im4,X+u4, Y+v4);
        
        total_im=[new_im1 new_im2;new_im3 new_im4];
       
        %% Generating data
        data1=nz_generate(mu1(1),sigma1(1),k);
        data2=nz_generate(mu2(1),sigma2(1),k);
        data3=nz_generate(mu3(1),sigma3(1),k);
        data4=nz_generate(mu4(1),sigma4(1),k);
        Data=[data1;data2;data3;data4];
        
        [mu,sigma,phi]=nz_gmm(Data,4);
       %figure, imagesc(total_im);title('Local Gaussian');
        
        % Apply a global deformation for smoothing
%         xcor=linspace(-1,1,M);
%         ycor=linspace(-1,1,M);
%         [X,Y]=meshgrid(xcor,ycor);
%         mu=[0 0];
%         sigma=[1 1];
%         [u,v]=kernel_func(X,Y,mu,sigma);
%         g_im=interp2(X,Y,total_im,X+u, Y+v);
         
          
        %% Plot Vector Feild
        % quiver(xcor(1:20),ycor(1:20),u(1:20,1:20),v(1:20,1:20),0,'red','linewidth',1);        
        %% Apply Deformation to the grid
%         close all
%         figure(1)
%         mesh(X,Y,im); view([0,0,1]);title('Before')
%         figure(2)
%         mesh(X+U,Y+V,im);title('After')
%         view([0,0,1]);

       
        figure(3);
        subplot(1,2,1);
        imagesc(total_im);title('Local deformation');
        subplot(1,2,2)
        imagesc(g_im);title('Local+Global Deformation'); 
        
        
        
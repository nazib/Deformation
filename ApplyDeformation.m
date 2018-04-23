function [data]=ApplyDeformation(filepath, outputpath)

%% Loads nifti files from the given file path
% and apply deformation on the file
% filepath=full path of the nifti file including the file name
% outputpath=output file path and name


data=load_nifti(filepath);
vol=data.vol;

%% Display file info
fprintf('\n#############################################################\n');
fprintf('Loading %s',filepath);
fprintf('Dimension: %d %d %d\n',size(vol));
fprintf('\n ############################################################# \n');

%im=rgb2gray(imread('test.jpg'));
[M,N,C]=size(vol);

for i=1:C    
or=vol(:,:,i);
im=double(imresize(or,[500 500]));
[W,H]=size(im);

%{
        %% Define Grid
        xcor=linspace(-1,1,W/2);
        ycor=linspace(-1,1,H/2);
        [X,Y]=meshgrid(xcor,ycor);

        %% Defining Vector Feild by Gaussian distribution

          mu=[0 0];
          sigma=[0.1 0.1];
          [u,v]=kernel_func(X,Y,mu,sigma);
       

        k=H/2;
        
        %1st quadrent
        xcor=linspace(-1,1,H/2);
        ycor=linspace(-1,1,H/2);
        [X,Y]=meshgrid(xcor,ycor);
        
        mu=[0 0];
        sigma=[0.5 0.5];
        [u1,v1]=kernel_func(X,Y,mu,sigma);
        im1=im(1:k,1:k);
        new_im1=interp2(X,Y,im1,X-u1, Y-v1);
        
        %2nd quadrent
        im2=im(1:k,k+1:H);
        new_im2=interp2(X,Y,im2,X+u1, Y-v1);
        
        %3rd quadrent
        im3=im(k+1:H,1:k);
        new_im3=interp2(X,Y,im3,X-u1, Y+v1);
        
        %4th Quadrent
        im4=im(k+1:H,k+1:H);
        new_im4=interp2(X,Y,im4,X+u1, Y+v1);
        
        newim=[new_im1 new_im2;new_im3 new_im4];
        newim=imresize(newim,[M,N]);
%}

        % Apply a global deformation for smoothing
         xcor=linspace(-1,1,W);
         ycor=linspace(-1,1,H);
         [X,Y]=meshgrid(xcor,ycor);
         mu=[0 0];
         sigma=[0.7 0.7];
         [u,v]=kernel_func(X,Y,mu,sigma);
         newim=interp2(X,Y,im,X+u, Y+v,'cubic',100);
         newim=imresize(newim,[M,N]);

         %% Plot Vector Feild
        % quiver(xcor(1:20),ycor(1:20),u(1:20,1:20),v(1:20,1:20),0,'red','linewidth',1)
       
        figure(1);
        subplot(1,2,1);
        imagesc(im);title('Original Brain');
        subplot(1,2,2)
        imagesc(newim);title('Deformed Brain'); 
        pause(0.1);
        disp(sprintf('Processing Slice -%d',i));
        data.vol(:,:,i)=newim;
end

%vol3d('Cdata',data.vol);
save_nifti(data,outputpath);
%nz_save_img(data,outputpath);
end
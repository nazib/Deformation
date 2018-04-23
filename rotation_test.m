clc;
clear all;

im=double(imread('test.jpg'));
im=imresize(im,[600,600]);

r_im=im(:,:,1);
g_im=im(:,:,2);
b_im=im(:,:,3);

[m,n]=size(r_im);

%[m,n]=size(im);

theta=deg2rad(60);

mat=[cos(theta) -sin(theta) 0;
     sin(theta) cos(theta)  0;
        0           0       1];

xcor=linspace(-1,1,m);
ycor=linspace(-1,1,n);
[x,y]=meshgrid(xcor,ycor);

trans=mat*[x(:)';y(:)';ones(length(x(:)),1)'];
nX=reshape(trans(1,:),m,n);
nY=reshape(trans(2,:),m,n);


new_im=zeros(m,n,3);
new_im(:,:,1)=interp2(x,y,r_im,nX,nY);
new_im(:,:,2)=interp2(x,y,g_im,nX,nY);
new_im(:,:,3)=interp2(x,y,b_im,nX,nY);


subplot(2,1,1);imshow(uint8(im))
subplot(2,1,2);imshow(uint8(new_im));
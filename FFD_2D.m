clc;
clear all;

im=double(rgb2gray(imread('F.png')));

[M,N]=size(im);

x=linspace(-1,1,M);
y=linspace(-1,1,N);
[xx,yy]=meshgrid(x,y);

%% creating lattice






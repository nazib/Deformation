% load input image
clear all;
I = double(imread('test.jpg'));
[h w d] = size(I);
% show input image
figure; image(I/255); axis image;
title('input image');
% make transformation matrix (T)
s  = 1;
a  = 0*pi/180;
tx = 0;
ty = 0;
T  = [ s*cos(a) s*sin(a) tx ; -s*sin(a) s*cos(a) ty ; 0 0 1 ];
% warp incoming corners to determine the size of the output image
cp = T*[ 1 1 w w ; 1 h 1 h ; 1 1 1 1 ];
Xpr = min( cp(1,:) ) : max( cp(1,:) ); % min x : max x
Ypr = min( cp(2,:) ) : max( cp(2,:) ); % min y : max y
[Xp,Yp] = ndgrid(Xpr,Ypr);

%% test
Xp=Xp.*exp(Xp.^2+Yp.^2);
Yp=Xp';%.*exp(Xp.^2+Yp.^2);
%% 
[wp hp] = size(Xp); % = size(Yp)
% do backwards transform (from out to in)
n = wp*hp;
X = T \ [ Xp(:) Yp(:) ones(n,1) ]';  % warp
% re-sample pixel values with bilinear interpolation
clear Ip;
xI = reshape( X(1,:),wp,hp)';
yI = reshape( X(2,:),wp,hp)';
Ip(:,:,1) = interp2(I(:,:,1), xI, yI, '*bilinear'); % red
Ip(:,:,2) = interp2(I(:,:,2), xI, yI, '*bilinear'); % green
Ip(:,:,3) = interp2(I(:,:,3), xI, yI, '*bilinear'); % blue
% show the warping result
figure; image(Ip/255); axis image;
title('warped image');
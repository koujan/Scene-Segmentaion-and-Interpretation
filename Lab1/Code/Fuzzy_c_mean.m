%% FCM algorithm for gray images 
clear all;
clc;
im=imread('coins.png');
imtool(im);
R=4;                  % number of initial seeds (regions)
imhist(im); hold on;
s2=size(im);
im=double(im(:));
seg=zeros(size(im));
[CENTER, U, OBJ_FCN] = fcm(im, R);
maxU = max(U);
const=floor(255/R); 
% giving different lables to different regions
for i=1:R
    seg(U(i,:) == maxU)=const;
    const=const+floor(255/R);
end
%showing the different clusters(assumed as 5 here but can but changed as required) on the same figure of the image histogram
line(im(U(1,:)==maxU),zeros(size(im(U(1,:)==maxU))),'marker','*','color','g')
hold on;
line(im(U(2,:)==maxU),zeros(size(im(U(2,:)==maxU))),'marker','*','color','r');
line(im(U(3,:)==maxU),zeros(size(im(U(3,:)==maxU))),'marker','*','color','k');
line(im(U(4,:)==maxU),zeros(size(im(U(4,:)==maxU))),'marker','*','color','c');
line(im(U(5,:)==maxU),zeros(size(im(U(5,:)==maxU))),'marker','*','color','m');
scatter([CENTER(1) CENTER(2) CENTER(3) CENTER(4) CENTER(5) ],[0 0 0 0 0 ],500,'o');
title('Coins image histogram with R=5');hold off;
imtool(reshape(uint8(seg),s2)); % showing the segmented image

%% FCM algorithm for color images

clear all;
clc;

im=imread('gantrycrane.png');
imtool(im);
R=5;
%im=imread('woman.tif');
%im=imread('color.tif');
s1=size(im);
Red=im(:,:,1);
G=im(:,:,2);
B=im(:,:,3);
im=double([Red(:) G(:) B(:)]);
s2=size(im);
seg=uint8(zeros(s2));
const=floor(255/R);
options = [3 NaN NaN NaN]; % testing with higher value of 
[CENTER, U, OBJ_FCN] = fcm(im,R,options);
maxU = max(U);
% giving different lables to different regions
for i=1:R
    seg(U(i,:)==maxU,1)=const; seg(U(i,:)==maxU,2)=50; seg(U(i,:)==maxU,3)=200;
    const=const+floor(255/R);
end
%showing the different clusters(assumed as 5 here but can but changed as required) on the same figure of the image histogram
scatter3(im(U(1,:)==maxU,1),im(U(1,:)==maxU,2),im(U(1,:)==maxU,3),1.5,repmat( [1 0.5 0.8], [ length( im( U(1,:)==maxU)),1]));hold on;
scatter3(im(U(2,:)==maxU,1),im(U(2,:)==maxU,2),im(U(2,:)==maxU,3),1.5,repmat([0.5 1 0.1], [ length( im( U(2,:)==maxU)),1]));hold on;
scatter3(im(U(3,:)==maxU,1),im(U(3,:)==maxU,2),im(U(3,:)==maxU,3),1.5,repmat( [0.5 0.5 0.5], [ length( im( U(3,:)==maxU)),1]));hold on;
scatter3(im(U(4,:)==maxU,1),im(U(4,:)==maxU,2),im(U(4,:)==maxU,3),1.5,repmat([0 0.5 0.1], [ length( im( U(4,:)==maxU)),1]));hold on;
scatter3(im(U(5,:)==maxU,1),im(U(5,:)==maxU,2),im(U(5,:)==maxU,3),1.5,repmat([0 0 0.2], [ length( im( U(5,:)==maxU)),1]));hold on;
scatter3([CENTER([1 2 3 4 5],1)],[CENTER([1 2 3 4 5],2)], [CENTER([1 2 3 4 5 ],3)],400,'*')
title('RGB space of gantrycrane image (R=5)');
hold off;
imtool(reshape(uint8(seg),s1));













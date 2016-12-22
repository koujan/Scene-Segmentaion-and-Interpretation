function v = computeFeatureVector(A)
%
% Describe an image A using texture features.
%   A is the image
%   v is a 1xN vector, being N the number of features used to describe the
% image
%
off_vec=[0 1;-1 1;1 -1;-1 0];
Num=size(off_vec,1);
v=zeros(1,4*Num+1);
if size(A,3) > 1,
	A = rgb2gray(A);
end
GLCM=graycomatrix(A,'Offset',off_vec,'NumLevels',256,'symmetric',true);
A_feat=graycoprops(GLCM,{'contrast', 'Energy' ,'homogeneity','Correlation'});
v(1:Num)=A_feat.Energy;
v(Num+1:2*Num)=A_feat.Contrast;
v(2*Num+1:3*Num)=A_feat.Homogeneity;
v(3*Num+1:4*Num)=entropy(A);
v(4*Num+1:5*Num)=A_feat.Correlation;


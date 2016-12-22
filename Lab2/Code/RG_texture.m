function [seg,num_of_regions]=RG_texture(img,off_vec,window_size,NumLevels,delta)

%-img variable is the image to be segmented,e.g. image=imread('pingpong2.tif');
%-off_vec: is the offset vector that is used to determin the different
% orientaions in the GlCM matrix,e.g
%off_vec=[0 1]
%-window_size is the size of the window that will slide on the origianl
% image to calculate the local features for each pixel,e.g. window_size=11;
%-NumLevels: are the number of levels to be considered inside each local
%window,e.g. NumLevel=32;
%-delta is the segmentation threshold,e.g. delta=1.5

if size(img,3) > 1,
	im_f=rgb2gray(img);
end
Num=size(off_vec,1); %Num is the number of orientations to be taken into account while calculating the co-occurence matrix
energy_f=zeros([size(im_f),Num]); % the third dimension represents the various orientations
Contrast_f=zeros([size(im_f),Num]); % the third dimension represents the various orientations
Homogeneity_f=zeros([size(im_f),Num]); % the third dimension represents the various orientations
Entropy_f=zeros([size(im_f), Num]); % the third dimension represents the various orientations
im_f_padded=padarray(im_f,[floor(window_size/2) floor(window_size/2)],'symmetric');% putting a frame around the image
 for i=1:size(im_f,1)   
     for j=1:size(im_f,2)
        feli=graycomatrix(im_f_padded(i:i+window_size-1,j:j+window_size-1),'Offset',off_vec,'NumLevels',NumLevels,'symmetric',true);
        feli_feat=graycoprops(feli,{'contrast', 'Energy' ,'homogeneity','Correlation'});
        energy_f(i,j,:)=feli_feat.Energy;
        Contrast_f(i,j,:)=feli_feat.Contrast;
        Homogeneity_f(i,j,:)=feli_feat.Homogeneity;
        for c=1:Num % calculate the entropy for every co occurrence matrix that is the result of one possible orientation
            Entropy_f(i,j,c)=entropy(feli(:,:,c));
        end
     end
 end
 % Normalization step for each feature 
for i=1:Num
    energy_f(:,:,i)=(energy_f(:,:,i)-min(min(energy_f(:,:,i))))/(max(max(energy_f(:,:,i)))-min(min(energy_f(:,:,i))));
    Contrast_f(:,:,i)=(Contrast_f(:,:,i)-min(min(Contrast_f(:,:,i))))/(max(max(Contrast_f(:,:,i)))-min(min(Contrast_f(:,:,i))));
    Homogeneity_f(:,:,i)=(Homogeneity_f(:,:,i)-min(min(Homogeneity_f(:,:,i))))/(max(max(Homogeneity_f(:,:,i)))-min(min(Homogeneity_f(:,:,i))));
    Entropy_f(:,:,i)=(Entropy_f(:,:,i)-min(min(Entropy_f(:,:,i))))/(max(max(Entropy_f(:,:,i)))-min(min(Entropy_f(:,:,i))));
end
save('ping_4O_15W_64L','energy_f','Contrast_f','Homogeneity_f','Entropy_f','feli_feat','feli'); % to avoid repeated caculation of those features which time costly

            %%%% segmentation part %%%%
            
H = fspecial('gaussian',[5 5],5);
im=imfilter(img,H,'same'); % color version
% Image intensity normalization
im(:,:,1)=(im(:,:,1)-min(min(im(:,:,1))))./(max(max(im(:,:,1)))-min(min(im(:,:,1))));
im(:,:,2)=(im(:,:,2)-min(min(im(:,:,2))))./(max(max(im(:,:,2)))-min(min(im(:,:,2))));
im(:,:,3)=(im(:,:,3)-min(min(im(:,:,3))))./(max(max(im(:,:,3)))-min(min(im(:,:,3))));
s=size(im);
seg=zeros(s(1),s(2)); % matrix to store segmentation result
num_of_regions=0;     % variable used to label different region of the original image
Q=zeros(1,s(1)*s(2)); % queue to organize the segmentation procedure
for i=1:s(1)      % iterate on every pixel
        for j=1:s(2)
            if(seg(i,j)==0)
               %%region initialization
                num_of_regions=num_of_regions+1;    % start with label of value 1 for 1'st region and then increase it by one for every new region
                 seg(i,j)=num_of_regions;    % set region label 
                 mean=[squeeze(im(i,j,:));squeeze(energy_f(i,j,:));squeeze(Contrast_f(i,j,:));squeeze(Homogeneity_f(i,j,:));squeeze(Entropy_f(i,j,:))];    % initialize the mean of this region ----
                 num=1;            % number of pixels in the region under construction(helps to update the mean value)
                 que_iterator=0;    % queuing iterator
                 deq_iterator=1;    % dequeing iterator
                 n=GetNeighbors(i,j,s);  % get the numerical orders of all 4-neighbours of pixel (i,j) 
                 [not_checked_pix,bool]=isCheckedBefore(n,seg,Q,que_iterator+1,deq_iterator); % function to check if any of the neigbours is checked before in order not to queue it again
                if(bool==1)  % if there are not checked pixels yet
                    % queuing procedure             
                    for c=1:length(not_checked_pix)
                         que_iterator=que_iterator+1;
                         Q(que_iterator)=not_checked_pix(c);
                    end
                end
                while(deq_iterator<=que_iterator)   % while the queue contains pixels
                    pix=Q(deq_iterator); % retrieving the pixel from the queue
                    deq_iterator=deq_iterator+1;  % increasing the dequeuing iterator
                    in1=ceil(pix/s(2));           % calculating index i of the retrieved pixel
                    in2=pix-(in1-1)*s(2);         % calcuating index j of the retrieved pixel
                    if(norm(double([squeeze(im(in1,in2,:));squeeze(energy_f(in1,in2,:));squeeze(Contrast_f(in1,in2,:));squeeze(Homogeneity_f(in1,in2,:));squeeze(Entropy_f(in1,in2,:))])-double(mean) )<=delta) % aggregation crterion based on the Euclidian distance----
                        seg(in1,in2)=num_of_regions;       % assign region label
                        num=num+1;             % increasing the number of pixels in the region under construction     
                        mean=double(mean)*(double(num-1)/double(num))+(double([squeeze(im(in1,in2,:));squeeze(energy_f(in1,in2,:));squeeze(Contrast_f(in1,in2,:));squeeze(Homogeneity_f(in1,in2,:));squeeze(Entropy_f(in1,in2,:))])/double(num));  % updating the mean value---
                        n=GetNeighbors(in1,in2,s); % checking the neighbours of the newly added pixel
                        [not_checked_pix,bool]=isCheckedBefore(n,seg,Q,que_iterator,deq_iterator);   %removing previously checked pixels from variable n
                        if(bool==1)  % if there are not checked pixels yet
                            % queuing procedure 
                            for c=1:length(not_checked_pix)
                                que_iterator=que_iterator+1;
                                Q(que_iterator)=not_checked_pix(c);
                            end
                        end
                    end
                end

            end
            Q(1)=0;  % just to make sure that the iterator will not come back to pixel a checked but not assigned yet
        end
end
seg=255*( ( seg-min(min(seg)) )/( max(max(seg))-min(min(seg)) ) ); % contrast stretching, to recognize the different regions
seg=uint8(seg); % type casting
figure;imshow(seg);

end
function [seg,num_of_regions]=Region_Growing_seg(image,delta)
%this function is based on 4-neighbours relationship
im=imread(image);
s=size(im);
seg=zeros(s(1),s(2)); % matrix to store segmentation result
num_of_regions=0;               % variable used to label different region of the original image
Q=zeros(1,s(1)*s(2)); % queue to organize the segmentation procedure
if(length(s)==3)      % check if the image is colored 
    for i=1:s(1)      % iterate on every pixel
        for j=1:s(2)
            if(seg(i,j)==0)
               %%region initialization
                num_of_regions=num_of_regions+1;    % start with label of value 1 for 1'st region and then increase it by one for every new region
                seg(i,j)=num_of_regions;    % set region label 
                mean=im(i,j,:);    % initialize the mean of this region
                num=1;             % number of pixels in the region under construction(helps to update the mean value)
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
                    pix=Q(deq_iterator);  % retrieving the pixel from the queue
                    deq_iterator=deq_iterator+1;  % increasing the dequeuing iterator
                    in1=ceil(pix/s(2));           % calculating index i of the retrieved pixel
                    in2=pix-(in1-1)*s(2);         % calcuating index j of the retrieved pixel
                    if(norm(double([im(in1,in2,1);im(in1,in2,2);im(in1,in2,3)])-double([mean(1);mean(2);mean(3)]) )<=delta) % aggregation crterion based on the Euclidian distance
                        seg(in1,in2)=num_of_regions;       % assign region label
                        num=num+1;                % increasing the number of pixels in the region under construction     
                        mean=double(mean)*(double(num-1)/double(num))+(double(im(in1,in2,:))/double(num));  % updating the mean value
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
    
 
elseif(length(s)==2)   % check if the image is grey-level (the only difference here is in calculating the region validity condition) 
    for i=1:s(1)       % iterate on every pixel  
        for j=1:s(2)
            if(seg(i,j)==0)
               %%region initialization
                num_of_regions=num_of_regions+1;  % start with label of value 1 for 1'st region and then increase it by one for every new region  
                seg(i,j)=num_of_regions;    % set region label 
                mean=im(i,j);      % initialize the mean of this region
                num=1;             % number of pixels in the region under construction (helps to update the mean value)
                que_iterator=0;    % queuing iterator
                deq_iterator=1;    % dequeing iterator
                n=GetNeighbors(i,j,s); % get the numerical orders of all 4-neighbours of pixel (i,j)
                [not_checked_pix,bool]=isCheckedBefore(n,seg,Q,que_iterator+1,deq_iterator); % function to check if any of the neigbours is checked before in order not to queue it again     
                if(bool==1)        % if there are not checked pixels yet  
                    % queuing procedure
                    for c=1:length(not_checked_pix)
                         que_iterator=que_iterator+1;
                         Q(que_iterator)=not_checked_pix(c);
                    end
                end
                while(deq_iterator<=que_iterator)  % while the queue contains pixels
                    pix=Q(deq_iterator);           % retrieving the pixel from the queue
                    deq_iterator=deq_iterator+1;   % increasing the dequeuing iterator
                    in1=ceil(pix/s(2));            % calculating index i of the retrieved pixel
                    in2=pix-(in1-1)*s(2);          % calcuating index j of the retrieved pixel
                    if( abs(im(in1,in2)-mean)<=delta) % aggregation criterion
                        seg(in1,in2)=num_of_regions;           % assign region label
                        num=num+1;    % increasing the number of pixels in the region under construction     
                        mean=double(mean)*(double(num-1)/double(num))+(double(im(in1,in2))/double(num));   % updating the mean value
                        n=GetNeighbors(in1,in2,s);   % checking the neighbours of the newly added pixel
                        [not_checked_pix,bool]=isCheckedBefore(n,seg,Q,que_iterator,deq_iterator);   % removing previously checked pixels from variable n 
                        if(bool==1)   % if there are not checked pixels yet 
                            %[Q,que_iterator]=queue(not_checked_pix,Q,que_iterator);
                            % queuing procedure 
                            for c=1:length(not_checked_pix)
                                que_iterator=que_iterator+1;
                                Q(que_iterator)=not_checked_pix(c);
                            end
                        end
                    end
                end
            end
            Q(1)=0;      % just to make sure that the iterator will not come back to pixel a checked but not assigned yet
        end
    end

end
seg=255*( ( seg-min(min(seg)) )/( max(max(seg))-min(min(seg)) ) ); % contrast stretching, to be recognize the different regions
seg=uint8(seg); % type casting

end

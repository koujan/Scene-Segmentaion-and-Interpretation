function [neigh]=GetNeighbors(i,j,s)
% The purpose of this function is to return the numerical orders of the four
% neighbours of a pixel in an image, given its index (i,j) and the size of
% the image (s)
if(i==1)
        if(j==1)
            neigh(1)=(i-1)*s(2)+j+1;    %%second neigh
            neigh(2)=((i-1)+1)*s(2)+j;  %%third neigh 
        elseif(j==s(2))
            neigh(2)=(i-1)*s(2)+j-1;    %%fourth neigh
            neigh(1)=((i-1)+1)*s(2)+j;  %%third neigh 
        else
            neigh(1)=(i-1)*s(2)+j+1;    %%second neigh
            neigh(2)=((i-1)+1)*s(2)+j;  %%third neigh 
            neigh(3)=(i-1)*s(2)+j-1;    %%fourth neigh 
        end
                    
elseif(i==s(1))
        if(j==1)
            neigh(1)=((i-1)-1)*s(2)+j;  %%first neigh
            neigh(2)=(i-1)*s(2)+j+1;    %%second neigh 
       elseif(j==s(2))
            neigh(1)=((i-1)-1)*s(2)+j;  %%first neigh
            neigh(2)=(i-1)*s(2)+j-1;    %%fourth neigh 
        else
            neigh(2)=(i-1)*s(2)+j+1;    %%second neigh
            neigh(1)=((i-1)-1)*s(2)+j;  %%first neigh 
            neigh(3)=(i-1)*s(2)+j-1;    %%fourth neigh 
        end  
elseif(j==1)
        neigh(1)=((i-1)-1)*s(2)+j;      %%first neigh
        neigh(3)=((i-1)+1)*s(2)+j;      %%third neigh 
        neigh(2)=(i-1)*s(2)+j+1;        %%second neigh 

    
elseif(j==s(2))
        neigh(1)=((i-1)-1)*s(2)+j;      %%first neigh
        neigh(2)=((i-1)+1)*s(2)+j;      %%third neigh 
        neigh(3)=(i-1)*s(2)+j-1;        %%fourth neigh
else
       neigh(1)=((i-1)-1)*s(2)+j;       %%first neigh
       neigh(3)=((i-1)+1)*s(2)+j;       %%third neigh 
       neigh(4)=(i-1)*s(2)+j-1;         %%fourth neigh  
       neigh(2)=(i-1)*s(2)+j+1;         %%second neigh  
    
end

end
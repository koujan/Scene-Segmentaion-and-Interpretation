function [not_checked_pix,bool]=isCheckedBefore(n,seg,Q,que_iterator,deq_iterator)
s=size(seg);
j=1; % to check if not_checked_pix variable contains at least one pixel
bool=1; %true by default
not_checked_pix(1)=0;
for i=1:length(n)
    in1=ceil(n(i)/s(2));  %calculating index i
    in2=n(i)-(in1-1)*s(2);   %calcuating index j
    dup=find(Q(1,deq_iterator:que_iterator)==n(i),1);  % check whether if it is being processed in the queue
    if(seg(in1,in2)==0 && isempty(dup))
          not_checked_pix(j)=n(i);
          j=j+1;
    end
end
if(j==1)   %which means "not_checked_pix" variable is empty
    bool=0;
end

end
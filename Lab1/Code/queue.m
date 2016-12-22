%% queue
function [strc,que_iterator]=queue(pixs,strc,que_iterator)

for i=1:length(pixs)
        que_iterator=que_iterator+1;
        strc(que_iterator)=pixs(i);
end

end
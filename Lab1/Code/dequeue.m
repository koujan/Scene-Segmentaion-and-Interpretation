%% dequeue
function [pix,strc,deq_iterator]=dequeue(strc,deq_iterator)
         pix=strc(deq_iterator);
         deq_iterator=deq_iterator+1;
end

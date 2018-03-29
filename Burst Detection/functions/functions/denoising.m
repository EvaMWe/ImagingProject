function [deviation,baseLine] = denoising (dataset, show_image,rate)
% Estimation of standard deviation of noise by high pass filtering
%%
%Filter Generation

%Evaluation of cutoff frequency

fc =  (0.1 + 0.1523*(rate^0.5))^2;
fc_norm = fc/rate;
[b,a]=butter(4,fc_norm,'low');
baseLine = filtfilt(b,a,dataset);

deviation = std(baseLine); 

if show_image == 1
    figure (1)
    plot(baseLine,'k'), hold on, plot (dataset);
end
end

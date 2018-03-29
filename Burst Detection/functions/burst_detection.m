function [burst_cal, shape] = burst_detection (data)
 % Determination of burst position
 % input: array representing signal trace 
[burst_cal,shape] = InitCalc_burst(data);

if (strcmp(burst_cal.type,'burst'))
    data_smoothed = smooth(burst_cal.data, 10);
    [~,data_denoised] = denoising(data_smoothed, 0, burst_cal.rate);
    burst_cal.base =data_denoised;
elseif (strcmp(burst_cal.type,'peak'))
    data_smoothed = smooth(burst_cal.data, 10);
    burst_cal.base = data_smoothed;
end

[norm] = normalizing(burst_cal);

while (strcmp(burst_cal.detection,'on'))
    burst_cal_temp = Cond1_threshold(burst_cal, norm);%condition: threshold
    burst_cal = burst_cal_temp;
    if (strcmp(burst_cal.detection,'on'))
        if (strcmp(burst_cal.flag,'bursteval_on'))
        [burst_cal_temp,shape_temp] = burst_data_norm(burst_cal,norm,shape); %maximum, burst end, continuity
        burst_cal = burst_cal_temp;
        shape = shape_temp;
        end
   end
end
end
    
    
    
    




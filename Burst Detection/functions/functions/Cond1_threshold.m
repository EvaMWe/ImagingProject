function [base_cal] = Cond1_threshold(base_cal,normTrace)

onset_time = base_cal.onset;
big_win = base_cal.winbig;
small_win = base_cal.winsmall;
num_frames = base_cal.frames;
data = base_cal.base;
data_raw = base_cal.data';
rate = base_cal.rate;
x_norm = normTrace.x;
y_norm = normTrace.y;


% search for threshold
if onset_time <= big_win
    onset_time = big_win+1;
elseif onset_time >= num_frames-big_win
    base_cal.flag = 'bursteval_off';
    base_cal.detection = 'off';
    base_cal.onset = big_win+1;
    return
end
%%
%threshold pre - calculation
    %-------------------------------------
    %when type is 'peak', threshold is fixed
    [~,mins] = Minimum_median(data,0.1);
    ref_val = median(mins);
    threshold = noise_std(data,0,rate);
    threshold = 2*threshold;
    SP = ref_val + threshold;
%%---------------------------------------
% start search for values exceeding threshold; burst = dynamical threshold , peak =
% fixed threshold (SP)
sliding_win = 1;
startim = onset_time;
while sliding_win == 1
    if startim + big_win >= length(data);
        base_cal.detection = 'off';
        base_cal.flag = 'bursteval_off';
        return
    end
%-------------------------------------   
    switch base_cal.type
        case 'burst' %if strcmp (base_cal.type,'burst') %generate sliding basevalue
            if startim <= onset_time+big_win
                if startim  <= onset_time+2*small_win
                    startim = onset_time+2*small_win;
                end
                dataBase = data(onset_time:startim);
            else
                dataBase = data(startim-big_win:startim);
            end
            [~,mins] = Minimum_median(dataBase,0.3);
            ref_val = median(mins);
            % generate sliding threshold
            dataBaseThresh = data_raw(startim-big_win:startim);
            threshold = noise_std(dataBaseThresh, 0,rate);
            threshold = 2.7*threshold;
            S = ref_val + threshold;
        case 'peak' %with a fix threshold
            S = SP;
    end
%%  compare (dynamic [in case of burst]) threshold with sliding trace value          
    if startim+5*small_win >= num_frames
        base_cal.flag = 'bursteval_off';
        base_cal.detection = 'off';
        return
    end
    chal = median(data(startim+3*small_win:startim + 5*small_win)); % current value
    if chal >= S;
        Sidx = startim; 
        sliding_win = 0;
    else
        startim= startim + small_win;
    end
end

% proceed with found burst start candidate Sidx
temp = Sidx;
incline = 95;

%refine burst_start
sliding_win = 1;
while sliding_win == 1
    while incline  > 5
         if (temp-small_win) >= base_cal.frames
             base_cal.detection = 'off';
             base_cal.flag = 'bursteval_off';
             return
         end
       
       if temp-small_win <= 0;
           base_cal.flag = 'bursteval_off';
           return
       end
       
       if mean(data(temp-small_win)) <= ref_val;
            burst_start = temp;
            break
        end
        x = x_norm(1:small_win);
        Y = y_norm(temp-small_win+1:temp);
        f = fit(x,Y,'poly2');
        incline = differentiate(f, x);
        incline = mean(incline);    
        temp = temp-small_win;
        if temp >= base_cal.frames - small_win
            base_cal.detection = 'off';
            return
        end
    end
    
    if median(data(temp-small_win:temp+small_win)) <= ref_val+0.2*S %baseline level already reached
        burst_start = temp-1;
        base_cal.onset = burst_start;
        sliding_win = 0;
    else
        temp = temp-small_win;
        if (temp-2*small_win) >= base_cal.frames 
            base_cal.detection = 'off';
            return
        elseif (temp-2*small_win)<=0
            burst_start = temp;
            break
        end
        x = x_norm(1:2*small_win);    
        Y = y_norm(temp-2*small_win+1:temp);
        f = fit(x,Y,'poly2');
        incline = differentiate(f, x);
        incline = mean(incline);  
        temp = temp-1;
        if incline >= -1
            burst_start = temp-1;
            base_cal.onset = burst_start;
            sliding_win = 0;
        end
    end
end


base_cal.burst_on = burst_start;
base_cal.threshold_start = S;
base_cal.thresholdfactor = threshold;
base_cal.threshold_start_idx = startim; 
base_cal.onset = Sidx;
base_cal.flag = 'bursteval_on';
end





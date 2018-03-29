function [struct_max] = double_peak_2(struct_max,struct_data,struct_norm,numb_burst)
%search for double peak
%init value = burst_end; reverse sliding window
init = struct_data.onset;
threshold = struct_data.threshold_start;
if numb_burst == 1
   max1_idx = struct_max.idx;
else
   max1_idx = struct_max(numb_burst).idx;
end

if numb_burst == 1
   max_1 = struct_max.max;
else
   max_1 = struct_max(numb_burst).max;
end

x_norm = struct_norm.x;
y_norm = struct_norm.y;
incline = -1;
win_small = struct_data.winsmall;
data = struct_data.data';
base = struct_data.base;
num_max = 1;

%until first maximum is reached
sliding_win = 1;
while sliding_win == 1;
    while incline < 0
        %pre_incline = incline;
        %spline
        if (init-win_small-1) <= 0;
           return
        end
        x = x_norm(1:win_small);
        xx = x;
        Y = y_norm(init-win_small-1:init);
        intp = spline(x,Y,xx);
        incline = mean(atand(diff(intp)./diff(x)));
        init = init-1;
    end
    
    %calculate previous derivative
    x = x_norm(1:win_small);
    xx = x;
    if (init-win_small-1) <= 0;
        return
    end
    Y = y_norm(init-win_small-1:init);    
    intp = spline(x,Y,xx);
    incline = mean(atand(diff(intp)./diff(x)));
    init = init-1;
    
    if incline <= -5 %curve starts declining again, check previous behaviour
        %go on in while loop, sliding_win remains 1;
        init = init - win_small;
        
    elseif incline >= 5 %maximum found
        [struct_max_temp,finished,init]= find_shape(struct_max, init, win_small, base, num_max, numb_burst, threshold,max1_idx,max_1, incline,x_norm,y_norm, data);
        struct_max = struct_max_temp;
        if numb_burst == 1
        num_max = length(struct_max.idx);   
        else
        num_max = length(struct_max(numb_burst).idx);
        end
        if finished == 1
            return
        end
        
    else %incline -5<x<5
        while incline > -5 && incline < 5; %--> between-5% und 5% slope
            if init-win_small-1 <= 0
                return
            end
            x = x_norm(1:win_small);
            xx = x;
            Y = y_norm(init-win_small-1:init);
            intp = spline(x,Y,xx);
            incline = mean(atand(diff(intp)./diff(x)));
            init = init-1;
        end
        %case one, derivative becomes zero and local maximum is detected
        %check derivative in previous window
        init = init-win_small; %search in previous window
        x = x_norm(1:win_small);
        xx = x;
        if init-win_small <= 0
           return
        end
        Y = y_norm(init-win_small-1:init);
        intp = spline(x,Y,xx);
        incline = mean(atand(diff(intp)./diff(x)));
        init = init-1;
        
        if incline >= 10 %maximum found
            [struct_max_temp,finished,init]= find_shape(struct_max,init, win_small, base, num_max, numb_burst, threshold, max1_idx,max_1, incline,x_norm,y_norm, data);
            struct_max = struct_max_temp;
            if numb_burst == 1
            num_max = length(struct_max.idx);
            else
            num_max = length(struct_max(numb_burst).idx);
            end            
            if finished == 1
               return
            end
        end
    end
end
end



function[shape, finished, temp]=find_shape(shape, temp, window, data, nMax, nBurst,S,pos_max1,max_1, slope, x,y,data_raw)
finished = 0;
[maximum, idx_max] = max(data_raw(temp-window:temp+window));
idx_max = temp-window + idx_max;
if idx_max <= pos_max1 - 5;
    finished = 1;
end
if (idx_max >= pos_max1 - 20) && (idx_max <= pos_max1 + 20); %found maximum is equal to first maximum in the peak
    if maximum >= max_1
       shape(nBurst).max(1) = maximum;
       shape(nBurst).idx_max(1) = idx_max;
       finished = 1;
    end
    return
else
    search_min = 1;
    while search_min == 1;
        while slope > 0;
            x_temp = x(1:window);
            xx = x_temp;
            if temp-window-1 <= 0
                return
            end
            Y = y(temp-window-1:temp);
            intp = spline(x_temp,Y,xx);
            slope = mean(atand(diff(intp)./diff(x_temp)));
            temp = temp-1;
        end
        %calculate previous slope to confirm declining behaviour
        temp = temp - window;
        x_temp = x(1:window);
        xx = x_temp;
        if temp-window-1 <= 0
           return
        end
        Y = y(temp-window-1:temp);
        intp = spline(x_temp,Y,xx);
        slope = mean(atand(diff(intp)./diff(x_temp)));
        temp = temp-1;
        
        if data(temp) <= maximum - S && slope <= 0; %true minimum, search for next maximum
            [minimum, idx_min] = min(data_raw(temp-window:temp+window));
            idx_min = temp-window + idx_min;
            nMax = nMax + 1;
            shape(nBurst).max(nMax)= maximum;
            shape(nBurst).idx(nMax)= idx_max;
            shape(nBurst).min(nMax)= minimum;
            shape(nBurst).min_idx(nMax)= idx_min;
            search_min = 0;
        elseif slope > 0
            continue
        elseif data(temp) > maximum - S && slope <= 0
            search_min = 0;
        end
    end
end

end
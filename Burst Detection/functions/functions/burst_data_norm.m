function [base_cal, shape] = burst_data_norm(base_cal, norm, shape)
%initial values
base = base_cal.base;
data = base_cal.data;
start_idx = base_cal.onset;
thresholdStart = base_cal.threshold_start;
thresholdFactor = base_cal.thresholdfactor;

win_small = base_cal.winsmall;
win_big = base_cal.winbig;
burst_start = start_idx;
x_norm = norm.x;
y_norm = norm.y;

%%
%find local maxima
%------------------------------------------------------------------------
sliding_win = 1;
temp = burst_start;
while sliding_win == 1;
    %find max candidate
    incline = 1;
    while incline > 0
        x = x_norm(1:win_small);
        if (temp+win_small-1)>=base_cal.frames
            base_cal.detection = 'off';
            return
        end
        Y = y_norm(temp:temp+win_small-1);
        f = fit(x,Y,'poly2');
        incline = differentiate(f, x);
        incline = mean(incline);                 
        temp = temp+1;
    end
    
    value1 = base(temp); %value of candidate
    
    %first check in a small range after candidate
    x = x_norm(1:win_small); 
    if (temp+2*win_small-1)>= base_cal.frames
        base_cal.detection = 'off';
        return
    end
    Y = y_norm(temp+win_small:temp+2*win_small-1);
    f = fit(x,Y,'poly2');
    incline = differentiate(f, x);
    decline = mean(incline);  
       
    value2 = base(temp+2*win_small);
    if decline < 0 && value2 <= value1 - thresholdFactor/2  %if value fall below threshold value, confirm candidate as max
        [maximum, max_idx] = max(data(temp:temp+win_small-1));
        sliding_win = 0;
        max_idx = temp + max_idx;
    else        %threshold is not undercut, check for broader range if decline remains
        x = x_norm(1:4*win_small);
        if (temp+5*win_small-1)>= base_cal.frames
            base_cal.detection = 'off';
            return
        end
        Y = y_norm(temp+win_small:temp+5*win_small-1);
        f = fit(x,Y,'poly2');
        incline = differentiate(f, x);
        decline = mean(incline);     
        temp = temp+1;
        if decline < 0  %confirm as maximum
            temp = temp-1;
            [maximum, max_idx] = max(data(temp:temp+5*win_small-1));
            sliding_win = 0;
            max_idx = temp + max_idx;
        end
    end
end


%%
% find end of burst
%-----------------------------------------------------------------------------
if (strcmp(base_cal.type,'burst'));
threshold_stop = thresholdStart-thresholdFactor*0.7 ;
elseif (strcmp(base_cal.type,'peak'));
    threshold_stop = thresholdStart;
else
    disp ('type is not indicated, please insert valid value');
    return
end

temp = max_idx;
S_post = maximum;

if (temp+win_big) >= base_cal.frames
     base_cal.detection = 'off';
     return
end

while S_post > threshold_stop
      S_post = mean(base(temp : temp+win_small));
      temp = temp+1;
      if (temp+win_small) >= base_cal.frames
          base_cal.detection = 'off';
          return
      end
end

stop_idx = temp + win_small;
temp = stop_idx;

%searching for burst end
incline = -90;
sliding_win = 1;
while sliding_win == 1
    while incline < -1
        if (temp+win_small) >= base_cal.frames
            base_cal.detection = 'off';
            return
        end
        x = x_norm(1:win_small);        
        Y = y_norm(temp:temp+win_small-1);
        f = fit(x,Y,'poly2');
        incline = differentiate(f, x);
        incline = mean(incline);     
        temp = temp+1;
        if temp >= base_cal.frames - win_small
            base_cal.detection = 'off';
            return
        end
    end
    
    if base(temp) <= thresholdStart-thresholdFactor %baseline level already reached
        burst_end = temp-1;
        base_cal.onset = burst_end;
        sliding_win = 0;
    else
        temp = temp+win_small;
        if (temp+win_small) >= base_cal.frames
            base_cal.detection = 'off';
            return
        end
        x = x_norm(1:win_small);       
        Y = y_norm(temp:temp+win_small-1);
        f = fit(x,Y,'poly2');
        incline = differentiate(f, x);
        decline = mean(incline);   
        temp = temp+1;
        if decline >= -1
            burst_end = temp;
            base_cal.onset = burst_end;
            sliding_win = 0;
        end
    end
end

%shape contains information about maxima, minima and plateau
if isfield(base_cal,'burst')
    numb_burst = length (base_cal.burst.burst_start)+1;
    shape(numb_burst).max = maximum;
    shape(numb_burst).idx = max_idx;
else
    numb_burst = 1;
    shape(1).max = maximum;
    shape(1).idx = max_idx;
end

if strcmp(base_cal.type,'burst') && strcmp(base_cal.shape,'on');
    [shape] = double_peak_2(shape,base_cal,norm,numb_burst);
end

%save data in struct
base_cal.burst_on = burst_start;
if ~isfield(base_cal,'burst')
    base_cal.burst.burst_start = burst_start;
    else
    base_cal.burst.burst_start = [base_cal.burst.burst_start burst_start];
end

%new initial value
if ~isfield(base_cal.burst,'maximum') %maximum and max_idx are calculated simultaneously
    base_cal.burst.maximum = maximum;
    base_cal.burst.index_maximum = max_idx;
else
    base_cal.burst.maximum = [base_cal.burst.maximum maximum];
    base_cal.burst.index_maximum = [base_cal.burst.index_maximum max_idx];
end

if burst_end >= base_cal.frames - base_cal.winbig
    base_cal.detection = 'off';
end
if ~isfield(base_cal.burst,'burst_end')
    base_cal.burst.burst_end = burst_end;
else
    base_cal.burst.burst_end = [base_cal.burst.burst_end burst_end];
end

end





function [base_cal] = Cond_2_threshold(base_cal)

data = base_cal.base;
onset_time = base_cal.burst_on;
small_win = base_cal.winsmall;
if onset_time <= small_win
   onset_time = small_win+1;
end
big_win = base_cal.winbig;
small_win = base_cal.winsmall;
num_frames = base_cal.frames;

count = 1;
if onset_time >= num_frames-big_win 
   base_cal.flag = 'bursteval_off';
   base_cal.onset = onset_time+1;
   return
end

ref_val = median(data(onset_time-small_win:onset_time));

S = thresholdDetection(data,ref_val);

sliding_win = 1;
startim = onset_time;
while count <= 30 && sliding_win == 1
      if startim + small_win >= num_frames;
          base_cal.detection = 'off';
          return
      end
      chal = median(data(startim:startim + small_win));
          if chal >= S;
             burst_start = onset_time;
             sliding_win = 0;
          else
             count = count+1;
             startim= startim + small_win;            
          end
end

base_cal.burst_on = onset_time;
       
if exist ('burst_start','var');
    base_cal.threshold_start = S;
    base_cal.threshold_start_idx = startim;
    base_cal.flag = 'bursteval_on';  %go on in burst analysis

else
    base_cal.flag = 'bursteval_off'; %go to searche for next event
    base_cal.onset = startim;
end

end


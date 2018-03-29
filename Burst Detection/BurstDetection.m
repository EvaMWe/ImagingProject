function [ resultCell ] = BurstDetection( dataCell )
%%
%===========================================================================
% BURST DETECTION
%===========================================================================% 
% peak detection on smoothed and denoised dff data;
% threshold-based method
% peak start and endpoints refined by search for derivative with ploynomial
% regression
% can be used for a set of measurements;
% input data: cell arrays containing
% row 1: raw_data
% row 2: background
% row 3: delta f/f
% row 4: baseline
% column: experiment


dispstat('','init')
n_measurement = size(dataCell,2);
resultCell = cell(4,n_measurement);
for measure = 1:n_measurement
    a = sprintf('measurement nr %i out of %i is running' ,measure,n_measurement);
    disp (a);
    
    dff = dataCell {3,measure};
    n_ROI = size(dff,1);
    n_ROI_s = num2str(n_ROI);    
    burst_info=cell(n_ROI,2);
    for i = 1:n_ROI
        val = num2str(i);   
        
        dff_temp = dff(i,:);
        [burst_cal,shape] = burst_detection(dff_temp);
        burst_info{i,1} = burst_cal;
        burst_info{i,2} = shape;
    end
    resultCell{1,measure} = burst_info;
    resultCell{2,measure} = dataCell{1,measure}; %raw data, not dff;
    resultCell{3,measure} = dataCell{4,measure}; %baseline, for f0 calculation
    resultCell{4,measure} = dataCell{2,measure}; %background
end

end




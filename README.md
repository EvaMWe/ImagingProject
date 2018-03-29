# ImagingProject

Signals were detected by an event detection algorithm that uses a dynamic threshold calculated by sliding window.
Since the signals in the fluorescence traces may differ in their characteristics depending on type, age, densitity and activity of the cell
culture, the algorithm automatically distinguishes between ‘peak’ and ‘burst’ detection by thresholding in the frequency spectrum. 
Thereby ‘peak’-mode is selected if events are narrow and frequent, while ‘burst’ mode is on, if events are mostly wide. 
During detection, first a signal candidate is detected by thresholding using the two fold standard deviation in a defined region in 
and before the current window.  Taking the first derivative into account, the algorithm confirms signal candidates as signals and 
respectively refines start and end points of the signals. In contrast to algorithm estimating APs or firing rate, our algorithm is 
focused on detecting fluorescence events caused by calcium transients.
The relevant output of the software package includes the evaluation parameters to value image quality comprising background, 
base fluorescence, ratio of both and signal to noise. 

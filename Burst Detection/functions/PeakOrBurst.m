function [ relA ] = PeakOrBurst(trace,display)
%decide about 'peak' o 'burst' by fft
% input: trace = signal array(1D), display = 1 --> show plot
Fs = 5;
FTtrace = fft(trace);
L = size(trace,2);
P2 = abs(FTtrace/L);
P1 = P2(1:ceil(L/2));
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(1:ceil(L/2))/L;
P3 = fftshift(P1);

if display == 1
    plot(f,P3)
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
end

lim1 = 30; 
lim2 = lim1 + 300;
if lim2 >= length(P1)
   lim2 = length(P1);
end
A1 = median(P1(lim1:lim2));
A2 = max(P1(1:lim1));
relA = A2/A1;

end


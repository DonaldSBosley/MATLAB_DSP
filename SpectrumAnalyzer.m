%2013 Don Bosley -www.bosleymusic.com-
%
%Spectrum Analyzer accepts an input wavefile and calculates the FFT of 
%   the signal in successive slices, with various options for window type
%   and overlap. Displays the results of analysis in a spectrogram
%
%Arguments: 
%   wavinput (string) : the name of the wavefile to read in
%   fftlen (integer, > 2) : fft analysis frame length, rounds to next power of 2
%   overlap (integer, > 0) : the overlap of the analysis frames 
%          - This result will be fftlen/overlap, i.e. Inputing 512 for 
%           fftlen and 8 for overlap will start a new analysis frame 
%           every 64 samples. 1 will give no overlap
%   window(optional / string) : selects windowing function
%       - correct types : 'bartlett','blackman', 'hamming', 'hann',
%       'rectwin', 'triang' - stringcompare will still match if case is
%       incorrect, otherwise defaults to hamming

function SpectrumAnalyzer(wavinput, fftlen, overlap, wintype)
%% ERROR CHECKING
if nargin < 3 || nargin > 4
    error('Incorrect Number of Arguments. Type help SpectrumAnalyzer');
elseif ischar(wintype) == 0
    error('wintype must be a string');    
elseif fftlen < 2
    error('fftlen must be greater than 0, preferably a power of 2');
elseif overlap < 1 || overlap > fftlen
    error('overlap must be at least 0, but no greater than fftlen');  
elseif wavfinfo(wavinput) == 0
    error('Not a valid wave file format. Please try a different file.')
end
%% SELECTING WINDOW TYPE
%Array of valid window types
wintypes = char('bartlett','blackman', 'hamming', 'hann', 'rectwin','triang');
comparison = 0; %Boolean, when true while loop below will stop
k = 1;          %Counter so that the while loop doesn't overflow
if nargin == 4
    while (comparison == 0 && k < 7)
        spaceeliminate = isspace(wintypes(k,:));    %Check for space 
        wintemp = wintypes(k, spaceeliminate == 0); %Remove spaces
        if strcmpi(wintype, wintemp) == 1           %Compare and if true...
            wintype = wintemp;                      %Place temp into type
            comparison = 1;                         %Comparison True, Break
        end  
        k = k + 1;                                  %Index++
    end
elseif (comparison == 0 || nargin == 3)             %Default to Hamming
   wintype = 'hamming';                             %Assigns string
end

%% WAV READ AND MONO SUM
[wavin, fs, ~] = wavread(wavinput);     %Read wave file
wavin = mean(wavin, 2);                 %Sum to mono by averaging

%% CHECK FFTLEN AND OVERLAP FACTOR
pow2 = nextpow2(fftlen);                        %Find next power of 2
fftlen = 2^pow2;                                %Round up to that power
overlap = ceil(fftlen - (fftlen / overlap));    %Set value for overlap

%% PLACE WAVE FILE INTO BUFFER
wavbuff = buffer(wavin, fftlen, overlap, 'nodelay'); %Buffer wav file
[~,y] = size(wavbuff);                               %Find size
%% CREATE A BUFFER OF WINDOWS (Same Size as wavbuff)
winbuff = repmat(window(wintype, fftlen), 1,y);      
%% FFT
wavbuff = wavbuff .* winbuff;   %Dot multiply windows by buffered wav
winbuff = [];                   %Conserve Memory
fftwav = fft(wavbuff, fftlen);  %Calculate the FFT
wavbuff = [];                   %Conserve Memory

%% CALCULATE MAGNITUDES (THE HARD WAY)
% This methods uses Pythagorean Theorem : mag = sq.root(real^2 + imag^2)
%imagesc(sqrt(real(fftwav).^2 + imag(fftwav).^2))           %W/out Decibels 
%imagesc(20*log10(sqrt(real(fftwav).^2 + imag(fftwav).^2))) %W/Decibels

%% CALCULATE MAGNITUDS (THE EASY WAY)
% The absolute value of a complex number yields the same result as Pyth.
%imagesc(abs(fftwav));               %W/out Decibels
imagesc(20*log10(abs(fftwav(1:fftlen/2, :))));  %W/Decibels, 0:Nyquist
set(gca, 'YDir', 'normal');                     %Sets direction to Normal
%% GRAPH WITH LABELING ON TIME SCALE AND AXIS
binresolution = fs / fftlen;        %Calculate Bin Width in Hz
totaltime = length(wavin) / fs;     %Calculate Total Time in Seconds

%Global
title('Spectrum Analysis')          %Plot title
colorbar                            %Show colorbar

%X-Axis label + ticks
xlabel('Time in Seconds');                              %Label X-Axis
xtick = 0:y/10:y;                                       %Make ticks
xticklabel = 0: totaltime / 10 :totaltime;              %Make tick vals
set(gca,'XTick',xtick)                                  %Set ticks
set(gca,'XTickLabel',xticklabel)                        %Label ticks

%Y-Axis label + ticks
ylabel('Frequency in Hz')                               %Label Y-Axis
ytick = 0:sqrt(fftlen):fftlen;                          %Make ticks
yticklabel = (0: binresolution * sqrt(fftlen): fs);     %Make tick vals
set(gca,'YTick',ytick)                                  %Set ticks
set(gca,'YTickLabel',yticklabel)                        %Label Ticks


end


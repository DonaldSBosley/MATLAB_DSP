%2013 Don Bosley - www.bosleymusic.com -
%
%Filter_Simple_Sweep : sweeps the cutoff frequency of a high or lowpass
%   filter based on parameters of an input envelope. This process
%   calculates new filter coefficients for each sample, while extremely
%   accurate, there may be better ways of block processing for the same
%   results.
%
%Parameters/Arguments : 
%   input : vector or matrix of samples
%   fs (integer) :  sampling rate of the signal
%   cutoff (float, > 0, < fs/4) : the cutoff frequency for the particular
%       filter type, this will be the max/min frequency of the filter at
%       the peak of the envelope; 
%   OR
%   cutoff [float, float] : the minimum and maximum values for the cutoff
%       can both be set using a two number vector
%   type (string) : 'lp' = low-pass filter
%                   'hp' = high-pass filter
%   envelope (vector, floats between 0-1) : shapes the behavior of the
%       sweep itself. If length is different from signal, zero padding will
%       be added to the shorter signal
%   direction (optional, boolean 0 or 1) : 0)sweeps up (default); 
%                                          1)sweeps down
%
%Outputs :
%   output : NORMALIZED filtered output, same as length of input but always 
%       in a column per channel format
%


function [output] = Filter_Simple_Sweep(input, fs, cutoff, type, envelope, direction)
%% ERROR CHECKING : 
if nargin ~= 5 && nargin ~= 6; 
    error('Filter_Simple_Sweep: incorrect number of arguments');
elseif fs < 1
    error('Filter_Simple_Sweep : fs should be a positive integer'); 
elseif ischar(type) == 0
    error('Filter_Simple_Sweep : type should be a string');
elseif nargin == 6 && (direction ~= 1 && direction ~= 0)
    error('Filter_Simple_Sweep : direction should be 0 (up) or 1 (down)');
end

%% DEAL WITH CUTOFF ERROR CHECKING
[~,y] = size(cutoff);
if y == 1                  %Single Cutoff
    lowcutoff = 1;         %Set Low Cutoff
    if cutoff > fs/4    
    highcutoff = fs/4-1;   %If input is out of bounds, set highcutoff
    else
    highcutoff = cutoff;      %Else, set high cut
    end
elseif y == 2 %Lower and Upper Cutoff Set
   if cutoff(1,1) < 1 || cutoff(1,1) > fs/4
       lowcutoff = 1;
   else
       lowcutoff = cutoff(1,1);
   end
   if cutoff(1,2) < 1 || cutoff(1,2) > fs/4
       highcutoff = fs/4-1;
   else 
       highcutoff = cutoff(1,2);   
   end
else 
    error('Filter_Simple_Sweep : cutoff input invalid. See help')
end


%% CHECK FILTER TYPES

%Array of valid filter types
filttypes = char('lp','hp');
comparison = 0; %Boolean, when true while loop below will stop
k = 1;          %Counter so that the while loop doesn't overflow

while (comparison == 0 && k < 3)
    spaceeliminate = isspace(filttypes(k,:));       %Check for space 
    filttemp = filttypes(k, spaceeliminate == 0);   %Remove spaces
    if strcmpi(type, filttemp) == 1                 %Compare and if true...
        comparison = 1;                             %Comparison True, Break
    end  
    k = k + 1; %Index++
end

type = k - 1; % Set numeric value for switch case / type


%% GET INPUT INFORMATION, ESTABLISH OUTPUT VECTOR, ENSURE INPUT IS COLUMN
[numSamps, numChannels] = size(input); 

if numChannels > numSamps              %Check for column orientation
    input = input';                    %Rotate
    [numSamps, numChannels] = size(input);    %Re-Id the number of channels
end

output = zeros(numSamps, numChannels); 

%% ENSURE OUTPUT AND ENVELOPE ARE SAME LENGTHS
if size(envelope) > numSamps %Append Zeros to output
    output = [output; zeros(size(envelope)-numSamps, numChannels)];
elseif numSamps > size(envelope) %Append ones to filtfreq
    filtfreq = [filtfreq; ones(size(envelope) - numSamps, 1)]'; 
end

[numSamps, numChannels] = size(output);     %Correct numbers

%% APPLY CUTOFF VALUES TO ENVELOPE
if nargin == 6 && direction == 1                %Sweeps down
    range = highcutoff - lowcutoff;             %Sets range of effect
    envelope = -1 * envelope + 1;               %Invert the Envelope
    filtfreq = range * envelope + lowcutoff;    %Scales/offset envelope to freq
else
    range = highcutoff - lowcutoff;             %Sets range of effect
    filtfreq = range * envelope + lowcutoff;    %Scales/offset envelope to freq
end


%% APPLY FILTER, COEFFICIENTS WILL CHANGE EACH LOOP
for k = 1:numChannels %Process each channel

    y_n_1 = 0;     %Set Placeholder for Initial "Output"
    
    for n = 1:numSamps %Process, sample by sample
        cutoff = filtfreq(n); %Current position of filter cutoff
        switch type 
        case 1 %Low pass
            b = sqrt((2-cos(2*pi*cutoff/fs)^2 - 1)) - 2 + cos(2*pi*cutoff/fs);
            a = 1 + b;
        
        case 2 %High pass
            b = 2 - cos(2*pi*cutoff/fs) - sqrt((2-cos(2*pi*cutoff/fs)^2 - 1)) ;
            a = 1 - b;
        end

        x_n = input(n,k);                 %Place Feedforward Sample
        output(n,k) = a * x_n - b * y_n_1;%Calculate filter ouput        
        y_n_1 = output(n,k);              %Place Feedback Sample   
    end   
               
end

%% NORMALIZE OUTPUT


end


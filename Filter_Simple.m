%2013 Don Bosley - www.bosleymusic.com -
%
%Filter_Simple : implements a first-order IIR low or hi pass filter and
%   applies it to each channel of a signal (Direct Form I)
%
%Parameters/Arguments : 
%   input : vector or matrix of samples
%   fs (integer) :  sampling rate of the signal
%   cutoff (float, > 0, < fs/4) : the cutoff frequency for the particular
%       filter type
%   type (string) : 'lp' = low-pass filter
%                   'hp' = high-pass filter
%
%Outputs :
%   output : filtered output, same as length of input but always in a 
%       column per channel format
%
% NOTE : NO NORMALIZATION OR ADDITIONAL GAIN IS UTILIZED IN THIS FILTER


function [output] = Filter_Simple(input, fs, cutoff, type)

%% ERROR CHECKING : 
if nargin ~= 4 
    error('Filter_Simple: incorrect number of arguments');
elseif fs < 1
    error('Filter_Simple : fs should be a positive integer'); 
elseif cutoff > fs/4 || cutoff < 1
    error('Filter_Simple : cutoff should be between 1 and fs/2');
elseif ischar(type) == 0
    error('Filter_Simple : type should be a string');
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

%% FILTER SELECTION AND COEFFICIENT GENERATION
%Creates a and b coefficients for use in a Direct Form I difference
%equation, for the respective filter and parameters selected.

switch type 
    case 1 %Low pass
        b = sqrt((2-cos(2*pi*cutoff/fs)^2 - 1)) - 2 + cos(2*pi*cutoff/fs);
        a = 1 + b;
        
    case 2 %High pass
        b = 2 - cos(2*pi*cutoff/fs) - sqrt((2-cos(2*pi*cutoff/fs)^2 - 1)) ;
        a = 1 - b;
        
end
      
%% APPLY FILTER

for k = 1:numChannels %Process each channel

    y_n_1 = 0;     %Set Placeholder for Initial "Output"
    
    for n = 1:numSamps                        %Process sample, by sample 
     x_n = input(n,k);                        %Place Feedforward Sample
     output(n,k) = a * x_n - b * y_n_1;       %Calculate filter ouput        
     y_n_1 = output(n,k);                     %Place Feedback Sample   
    end
    
end

        

end


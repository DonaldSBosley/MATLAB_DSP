%2013 Don Bosley - www.bosleymusic.com -
%
%Filter_Butterworth creates one of four second order butterworth filters
%   and applies it to each channel of a signal (Direct Form I)
%
%Parameters/Arguments : 
%   input : vector or matrix of samples
%   fs (integer) :  sampling rate of the signal
%   cutoff (float, > 0, < fs/4) : the cutoff frequency for the particular
%       filter type
%   type (string) : 'lp' = low-pass filter
%                   'hp' = high-pass filter
%                   'bp' = band-pass filter
%                   'br' = band-reject filter
%   BW (optional, 'bp' and 'br' only, >0, < 10): specifies bandwidth, 
%       or Q of filter
%
%Outputs :
%   output : filtered output, same as length of input but always in a 
%       column per channel format
%
% NOTE : NO NORMALIZATION OR ADDITIONAL GAIN IS UTILIZED IN THIS FILTER
% *NOTE : BW PARAMETER STILL NEEDS TUNING bp/br cutoffs are extremely steep
%


function [output] = Filter_Butterworth(input, fs, cutoff, type, BW)


%% ERROR CHECKING : 
if nargin ~= 4 && nargin ~= 5
    error('Filter_Butterworth : incorrect number of arguments');
elseif fs < 1
    error('Filter_Butterworth : fs should be a positive integer'); 
elseif cutoff > fs/4 || cutoff < 1
    error('Filter_Butterworth :  cutoff should be between 1 and fs/2');
elseif ischar(type) == 0
    error('Filter_Butterworth :  type should be a string');
elseif nargin == 5 && (BW <= 0 || BW > 10)
    error('Filter_Butterworth : BW should be between 0-10'); 
end


%% CHECK FILTER TYPES

%Array of valid filter types
filttypes = char('lp','hp', 'bp', 'br');
comparison = 0; %Boolean, when true while loop below will stop
k = 1;          %Counter so that the while loop doesn't overflow

while (comparison == 0 && k < 5)
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
        lambda = 1/tan(pi*cutoff/fs);
        %theta = X;
        a_0 = 1 / (1 + 2*lambda + lambda^2);
        a_1 = 2*a_0;
        a_2 = a_0;
        b_1 = 2 * a_0 * (1 - lambda^2);
        b_2 = a_0 * (1- 2*lambda + lambda^2);

    case 2 %High pass
        lambda = tan(pi * cutoff / fs);
        %theta = X;
        a_0 = 1 / ( 1 + 2*lambda + lambda^2);
        a_1 = 2*a_0;
        a_2 = a_0;
        b_1 = 2 * a_0 * (lambda^2 -1);
        b_2 = a_0 * (1- 2*lambda + lambda^2);
        
    case 3 %Band pass
        BW = BW .* cutoff;
        lambda = 1/tan(pi*BW/fs);
        theta = 2*cos(2*pi*cutoff/fs);
        a_0 = 1 / ( 1 + lambda);
        a_1 = 0;
        a_2 = -a_0;
        b_1 = -lambda * theta * a_0;
        b_2 = a_0 * (lambda-1);
        
    case 4 %Band reject
        BW = BW .* cutoff;
        lambda = tan(pi*BW/fs);
        theta = 2*cos(2*pi*cutoff/fs);
        a_0 = 1 / ( 1 + lambda);
        a_1 = -theta * a_0;
        a_2 = a_0;
        b_1 = -theta * a_0;
        b_2 = a_0 * (lambda - 1);
        
end
        %If you want to view the frequency/phase, etc...info use fvtool:
        %fvtool([1,b_1,b_2],[a_0,a_1,a_2]); %View results of the filter

%% APPLY FILTER

for k = 1:numChannels %Process each channel
    
    % PLACEHOLDER SAMPLES
    x_n = 0;
    x_n_1 = 0;
    %x_n_2 = 0;
    y_n_1 = 0;
    y_n_2 = 0;

    for n = 1:numSamps %Process sample, by sample
     %Shift feedforward samples
     x_n_2 = x_n_1;   
     x_n_1 =  x_n;    
     x_n = input(n,k); 
     %Calculate filter ouput
     output(n,k) = a_0 * x_n + a_1 * x_n_1 + a_2 * x_n_2...
                    - b_1 * y_n_1 - b_2 * y_n_2;  
     %Shift Feedback Samples           
     y_n_2 = y_n_1;
     y_n_1 = output(n,k);
    end
    
end

end


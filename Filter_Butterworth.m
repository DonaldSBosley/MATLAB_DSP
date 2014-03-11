%Filter_Butterworth Summary of this function goes here
%   Detailed explanation goes here


function [output] = Filter_Butterworth(input, fs, cutoff, type, BW)


%% ERROR CHECKING : 
if nargin ~= 4 || nargin ~= 5
    error('Filter_Butterworth : incorrect number of arguments');
elseif fs < 1
    error('Filter_Butterworth : fs should be a positive integer'); 
elseif cutoff > fs/2 || cutoff < 1
    error('Filter_Butterworth :  cutoff should be between 1 and fs/2');
elseif ischar(type) == 0
    error('Filter_Butterworth :  type should be a string');
elseif nargin == 5 || (BW <= 0 || BW > 10)
    error('Filter_Butterworth : BW should be between 0-10'); 
end


%% CHECK FILTER TYPES

%Array of valid window types
filttypes = char('lp','hp', 'bp', 'hr');
comparison = 0; %Boolean, when true while loop below will stop
k = 0;          %Counter so that the while loop doesn't overflow

while (comparison == 0 && k < 4)
    spaceeliminate = isspace(filttypes(k,:));       %Check for space 
    filttemp = filttypes(k, spaceeliminate == 0);   %Remove spaces
    if strcmpi(type, filttemp) == 1                 %Compare and if true...
        comparison = 1;                             %Comparison True, Break
    end  
    k = k + 1; %Index++
end

type = k; % Set numeric value for switch case / type
%% GET INPUT INFORMATION, ESTABLISH OUTPUT VECTOR 
[numSamps, numChans] = size(input); 
output = zeros(numSamps, numChans); 

%% FILTER SELECTION AND COEFFICIENT GENERATION
switch type 
    case 1 %Low pass
        lambda = 1/tan*(pi*cutoff/fs);
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
        lambda = 1/tan(pi*BW/fs);
        theta = 2*cos(2*pi*cutoff/fs);
        a_0 = 1 / ( 1 + lambda);
        a_1 = 0;
        a_2 = -a_0;
        b_1 = -lambda * theta * a_0;
        b_2 = a_0 * (lambda-1);
        
    case 4 %Band reject
        lambda = tan(pi*BW/fs);
        theta = 2*cos(2*pi*cutoff/fs);
        a_0 = 1 / ( 1 + lambda);
        a_1 = -theta * a_0;
        a_2 = a_0;
        b_1 = -theta * a_0;
        b_2 = a_0 * (lambda-1);
        
end

%% PLACEHOLDER SAMPLES
x_n = 0;
x_n_1 = 0;
%x_n_2 = 0;
y_n_1 = 0;
y_n_2 = 0;

%% APPLY FILTER

for k = 1:numChans %Process each channel
    
    % PLACEHOLDER SAMPLES
    x_n = 0;
    x_n_1 = 0;
    %x_n_2 = 0;
    y_n_1 = 0;
    y_n_2 = 0;

    for n = 1:numsamps %Process sample, by sample
     %Shift feedforward samples
     x_n_2 = x_n_1;   
     x_n_1 =  x_n;    
     x_n = input(k,n); 
     %Calculate filter ouput
     output(k,n) = a_0 * x_n + a_1 * x_n_1 + a_2 * x_n_2...
                    + b_1 * y_n_1 + b_2 * y_n_2;  
     %Shift Feedback Samples           
     y_n_2 = y_n_1;
     y_n_1 = output(k,n);
    end
    
end

end


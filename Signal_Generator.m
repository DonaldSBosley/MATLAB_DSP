%2013 Don Bosley - www.bosleymusic.com -
%
% Function_Generator uses additive synthesis (sum of sines), bandlimited by
%   a user established sampling rate to create a wavefile
%
%Parameters/Arguments : 
%   freq (float, 0 - fs/2) : the frequency of the wave in Hz
%   type (integer, 1-6): 1)sine, 2)cosine, 3)triangle, 4)square, 5)sawtooth, 5)white noise
%   time (float, > 0) : number of seconds
%   fs (integer, < 0) : the sampling rate
%   outputfile (string) : the name of the file to be written

function [output] = Signal_Generator(freq, type, time, fs)
%% ERROR CHECKING
Nyquist = fs/2;
% Number of arguments
if nargin ~= 5
    error('Incorrect Number of Arguments. Please type help SigGen for parameters and arguments');
elseif (type > 6 || type < 1) % Type
    error('type must be an integer between 1 and 6. Type help SigGen for type description');
elseif (time < 0) % Time
    error('time should be greater than 0 seconds');
elseif (freq < 0 || freq > Nyquist) % Freq
    error('freq should be greater than zero, but less than fs/2');
elseif (ischar(outputfile) == 0) % Output File 
    error('The output file name should be a string')
end

%% ESTABLISH NUMBER OF OVERTONES
timevec = 0:1/fs:time-(1/fs);   %Time vector 
outputvec = zeros(size(timevec));      %Preallocate memory for output
n = 1;                          %Counter
otone = freq;
p = 1;
switch type 
    case 1 %Sine
       outputvec =  sin(2*pi*freq .* timevec);
    case 2 %Cosine
       outputvec =  cos(2*pi*freq .* timevec);
    case 3 %Triangle
        while otone < Nyquist
            outputvec = outputvec + (1 / (n)^2 ) .* sin(2* pi* otone .* timevec);
            p = p * -1;
            n = n + 2;
            otone = n * p * freq;
        end      
    case 4 %Square
        while otone < Nyquist
            outputvec = outputvec + (1/(n)) .* sin(2*pi*otone .* timevec);
            n = n+2;
            otone = n * freq; 
        end 
    case 5 %Saw Tooth
        while otone < Nyquist
            outputvec = outputvec + (1/(n)) .* sin(2*pi*otone .* timevec);
            n = n+1;
            otone = n * freq; 
        end   
    case 6 %White Noise
        outputvec = 2 * rand(size(outputvec)) - 1; 
end

%% NORMALIZE (sometimes .* .99 - which prevents a "clipping error")
output = outputvec ./ max(abs(outputvec));
%outputvec = outputvec ./ max(abs(outputvec)) .* .9999;



end


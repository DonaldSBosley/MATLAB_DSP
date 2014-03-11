%2013 Don Bosley - www.bosleymusic.com -
%
% Delay_Simple accepts an signal (any number of channels) and adds 
%   a delay to the signal to produce various effects. Experiment with
%   single sample delays for simple FIR filtering effects, and longer
%   delays for effects like comb filtering. "phaseinv" will select whether 
%   delay is added or subtracted from the original signal, giving more 
%   varied results.
%
%Parameters/Arguments : 
%   input : input vector
%   delaymode (boolean, 0-1): 0)specify delay time in samples, 
%                             1)specify delay time in seconds
%   delay (int / float > 0): if delay is in samples, floats will be rounded
%       to the nearest integer value; if delay is in seconds, conversion
%       from seconds to samples will take place, and be rounded to the 
%       nearest integer value
%   phaseinv (optional, boolean, 0-1): 0)sample values normal, 1)reversed

function [output] = Delay_Simple(input, delaymode, delay, phaseinv)

%% ERROR CHECKING
if nargin < 3 || nargin > 4
    error('Delay_Simple : Incorrect Number of Arguments.'); 
elseif delaymode ~= 0 || delaymode ~= 1
    error('Delay_Simple : delaymode must equal 0 or 1');
elseif delay <= 0
    error('Delay_Simple : delay must be a positive value');
elseif nargin == 5 && (phaseinv ~= 0 || phaseinv ~=1)
    error('Delay_Simple : phaseinv must equal 0 or 1');
end

%% GET INPUT INFO
[~, numChannels] = size(input);    %Id the number of channels

%% CALCULATE DELAY IN SAMPLES

switch delaymode
    case 0 %Delay is in samples, ensure it is an integer value
       delay = round(delay);        %Ensures delay in samples is an integer
    case 1 %Delay is in seconds
       delay = round(fs/delay);     %Convert seconds to samples
end

%% CREATE A COPY, ZEROPAD

inputdelay = input;     %Create a copy
inputdelay = [zeros(delay, numChannels);inputdelay]; %Create delayed signal
input = [input; zeros(delay, numChannels)];          %Zeropad original signal

%% IF PHASEINV IS ON, PHASE INVERT THE DELAYED SAMPLES
if nargin == 5 || phaseinv == 1
    inputdelay = inputdelay .* -1;
end

%% SUM THE SIGNALS TOGETHER
output = input + inputdelay;         %Sums signals



end


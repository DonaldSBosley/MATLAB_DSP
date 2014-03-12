%2013 Don Bosley - www.bosleymusic.com -
%
%ADSR - create an "ADSR" - Attack, Decay, Sustain, Release
%Parameters/Arguments : 
%   attack (float, > 0) : attack time in seconds
%   decay (float, > 0) :  decay time in seconds
%   sustain (float, > 0) : sustain time in seconds
%   sustain_value (float, > 0, < 1) : sustain amplitude value
%   release (float, > 0) : release time in seconds
%   fs (integer, >  0, optional) : if no FS is specified, values are
%       assumed to be in samples rather than seconds
%
%Outputs :
%   envelope : vector with scalar values for envelope (0-1)


function [envelope] = ADSR(attack, decay, sustain, sustain_value, release, fs)
%% ERROR CHECKING (Remember that error checking exists in the subfunction)
if nargin < 5 || nargin > 6
    error('ADSR : Incorrect number of arguments. ');
elseif (attack < 0 || decay < 0 || sustain < 0 || release < 0)
    error('ADSR : (arguments 1-4) must be greater than 0');
elseif sustain_value < 0 || sustain_value > 1
    error('ADSR : sustain_value must be between 0 and 1');
end

if nargin == 6
    if fs < 1
        error('ADSR: fs must be an integer greater than 1'); 
    end
else %nargin == 4
    fs = 1; %This will make each segment equal to the number of samples
end

%% GENERATE ENVELOPE
attackvec = linspace(0,1,ceil(fs*attack)); 
decayvec = linspace(1,sustain_value, ceil(fs*decay));
sustainvec = sustain_value * ones(1, ceil(fs*sustain));
releasevec = linspace(sustain_value,0,ceil(fs*release));
envelope = [attackvec, decayvec, sustainvec, releasevec];
   

end


%2013 Don Bosley - www.bosleymusic.com -
%
%ADSR - create an "ADSR" - Attack, Decay, Sustain, Release
%Parameters/Arguments : 
%   attack (float, > 0) : attack time in seconds
%   decay (float, > 0) :  decay time in seconds
%   sustain (float, > 0) : sustain time in seconds
%   sustain_value (float, > 0, < 1) : sustain amplitude value
%   release (float, > 0) : release time in seconds
%
%Outputs :
%   envelope : vector with scalar values for envelope


function [envelope] = ADSR(fs, attack, decay, sustain, sustain_value, release)
%% ERROR CHECKING (Remember that error checking exists in the subfunction)
if nargin ~=4 || nargin ~= 5
    error('ADSR : Incorrect number of arguments. ');
elseif (attack < 0 || decay < 0 || sustain < 0 || release < 0)
    error('ADSR : (arguments 1-4) must be greater than 0');
end


%% GENERATE ENVELOPE
attackvec = linspace(0,1,round(fs*attack)); 
decayvec = linspace(1,sustain_value, round(fs*decay));
sustainvec = sustain_value * ones(1, round(fs*sustain));
releasevec = linspace(sustain_value,0,round(fs*release));
envelope = [attackvec, decayvec, sustainvec, releasevec];
   

end


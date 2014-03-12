%2013 Don Bosley - www.bosleymusic.com -
%
%NORMALIZER : Normalizes a signal to a range of values between 99.99% of 
%   -1, and 1.
%
%Parameters/Arguments : 
%   input : vector of samples (use in a loop to individually normalize
%           channels)
%
%Outputs : normalized output

function [output] = Normalizer(input)

    output = .9999 * input ./ max(abs(input));

end


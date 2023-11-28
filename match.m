function score = match(image, reg_temp, maxdispx, maxdispy)
%% Matching of extracted vein images - Tolesh Pathak
% This function was created as part of Major Project "Finger Vein
% Recognition System." This method is based on the one described by N.
% Miura, A. Nagasaka, and T. Miyatake in their paper "Feature Extraction of
% Finger Vein Patterns based on line tracking and its application to
% personal identification."[1] The slight difference in this one is that it
% calculates match ratio instead of mismatch ratio. This function was
% developed with the study of the one created by Bram Ton.[2] This was also
% used in the experimentation for the research paper "Enhancing Finger Vein
% Recognition through Composite Feature Extraction Method."
%
% Logic:
% The value of match is the similarity between the registered data and
% input data at the positions where registered template overlaps with the
% image.
%
% Parameters:
% image - The vascular image as input
% reg_temp - Registered Image Template
% maxdispx - Maximum search displacement in x-direction
% maxdispy - Maximum search displacement in y-direction
%
% Returns:
% score - a percentage value depicting the match between registered data
% and input data. Larger is the value, better is the match.
%
% References:
% [1] N. Miura, A. Nagasaka, and T. Miyatake
% "Feature Extraction of Finger Vein Patterns based on repeated line
% tracking and its application to personal identification"
% Machine Vision and Applications.
% doi: 10.1007/s00138-004-0149-2
%
% [2] Bram Ton (2022).
% Miura et al. vein extraction methods
% (https://www.mathworks.com/matlabcentral/fileexchange/35716-miura-et-al-vein-extraction-methods),
% MATLAB Central File Exchange.
% Retrieved May 17, 2022.

%% Code:
% Getting height and width of registered data
[h, w] = size(reg_temp);

% Determination of match value using cross-correlation through two
% dimensional convulation
val = conv2(image, rot90(reg_temp(maxdispy+1:h-maxdispy, ...
    maxdispx+1:w-maxdispx),2), 'valid');

% Determination of Maximum Value of Match
[val_max,idx] = max(val(:));
[t0,s0] = ind2sub(size(val),idx);

% Normalization of Score
score = ...
val_max/(sum(sum(reg_temp(maxdispy+1:h-maxdispy,maxdispx+1:w-maxdispx)))...
+sum(sum(image(t0:t0+h-2*maxdispy-1, s0:s0+w-2*maxdispx-1))));

% Conversion of Score into percentage
score = score*200;
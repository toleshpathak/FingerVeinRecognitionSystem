function [region, edges] = lregion(image, maskH, maskW)
%% Localize Finger Vein Region - Tolesh Pathak
% This function was created as part of Major Project "Finger Vein
% Recognition System." This method is based on the one described by E.C.
% Lee, H.C. Lee and K.R. Park in their paper "Finger Vein Recognition using
% Minutia-based alignment and local binary pattern-based feature
% extraction."[1] This function was developed with the study of the one
% created by Bram Ton.[2] This was also used in the experimentation for the
% research paper "Enhancing Finger Vein Recognition through Composite
% Feature Extraction Method."
%
% Logic:
% This method filters the image using a simple mask that gives large
% responses upon transition from background to finger region. The locations
% of these large responses are recorded as finger edges. Hence, a binary
% mask is calculated that indicates the finger region.
%
% Parameters:
% image - The vascular image as input
% maskH - Height of the mask
% maskW - Width of the mask
%
% Returns:
% region - Binary mask indicating the finger region
% edges - A matrix with two row where the first row contains the
% y-positions of the upper finger edge and the second row contains the
% y-positions of the lower finger edge.
%
% References:
% [1] Lee, Eui Chul & Lee, Hyeonchang & Park, Kang.(2009).
% Finger Vein Recognition Using Minutia-Based Alignment and Local Binary
% Pattern-Based Feature Extraction.
% International Journal of Imaging Systems and Technology.
% 19. 179 - 186. 10.1002/ima.20193.
%
% [2] Bram Ton (2022).
% Finger region localization
% (https://www.mathworks.com/matlabcentral/fileexchange/35752-finger-region-localisation),
% MATLAB Central File Exchange.
% Retrieved May 17, 2022.

%% Code:

[imageH, imageW] = size(image);

% Determination of lower half starting point
if mod(imageH,2) == 0
    half_imageH = imageH/2 + 1;
else
    half_imageH = ceil(imageH/2);
end

% Construction of filter mask
mask = zeros(maskH,maskW);
mask(1:(maskH/2),:) = -1;
mask((maskH/2)+1:end,:) = 1;

% Filtering Image using Mask
image_filt = imfilter(image, mask,'replicate'); 

% Upper part of filtred image is taken
image_filt_up = image_filt(1:floor(imageH/2),:);
[~, y_up] = max(image_filt_up); 

% Lower part of filtred image is taken
image_filt_lo = image_filt(half_imageH:end,:);
[~,y_lo] = min(image_filt_lo);

% Region between upper and lower edges is filled
region = zeros(size(image));
for i=1:imageW
    region(y_up(i):y_lo(i)+size(image_filt_lo,1), i) = 1;
end

% y-position of finger edges is saved
edges = zeros(2,imageW);
edges(1,:) = y_up;
edges(2,:) = round(y_lo + size(image_filt_lo,1));
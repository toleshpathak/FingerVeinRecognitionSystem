function veins = widline(image, rad, nthres, sumthres)
%% Wide Line Tracking Method - Tolesh Pathak
% This function was created as part of Major Project "Finger Vein
% Recognition System." This method is based on the one described by B.
% Huang, Y. Dai, R. Li, D. Tang, and W. Li in their paper "Finger Vein
% Authentication Based on Wide Line Detector and Pattern Normalization."[1]
% This was also used in the experimentation for the research paper
% "Enhancing Finger Vein Recognition through Composite Feature Extraction 
% Method."
%
% Logic:
% This method is implemented by employing a non-linear filter without using
% any derivative. Isotropic responses are obtained by using circular masks
% which contain either a normalized constant weighting or a Gaussian
% profile. The size of these circular masks is restricted to extract lines
% of different widths in their entirety.
%
% Parameters:
% image - The vascular image as input
% rad - The radius of the circular neighborhood region
% nthres - Neighborhood Threshold
% sumthres - Sum of Neighborhood Threshold
%
% Returns:
% veins - Binary Vein Image
%
% References:
% [1] B. Huang, Y. Dai, R. Li, D. Tang, and W. Li
% Finger Vein Authentication Based on Wide Line Detector and Pattern
% Normalization
% 2010 20th International Conference on Pattern Recognition, 2010
% pp. 1269-1272
% DOI:10.1109/ICPR.2010.316.

%% Code:
H = size(image , 1);
W = size(image , 2);
veins=zeros(size(image));
for x0 = 1 : W
    for y0 = 1:H
       m = 0;
       cnt = 0;
       for i=-rad:rad
          for j=-rad:rad
              x=x0+i;
              y=y0+j;
              if x < 1 || x > W || y < 1 || y > H 
                  continue
              elseif (x-x0)*(x-x0)+(y-y0)*(y-y0) > rad*rad 
                  continue;
              end
              cnt = cnt + 1;
              if image(y,x) - image(y0,x0) > sumthres
                  s=0;
              else
                  s=1;
              end
              m = m+s;       
          end
       end
       if m/cnt > nthres
           veins(y0,x0) = 0;
       else
           veins(y0,x0) = 1;
       end
    end
end
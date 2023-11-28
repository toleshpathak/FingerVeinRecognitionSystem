function veins = maxcurv(image, fvr, sigma)
%% Maximum Curvature Method - Tolesh Pathak
% This function was created as part of Major Project "Finger Vein
% Recognition System." This method is based on the one described by N.
% Miura, A. Nagasaka, and T. Miyatake in their paper "Feature Extraction of
% Finger Vein Patterns based on line tracking and its application to
% personal identification."[1] This function was developed with the study
% of the one created by Bram Ton.[2] This was also used in the
% experimentation for the research paper "Enhancing Finger Vein Recognition
% through Composite Feature Extraction Method."
%
% Logic:
% This method checks the curvature of the image profile and emphasizes only
% the midline present inside each particular vein. These midlines are
% detected by tracking the points where the curvature of a cross-sectional
% profile of the vein image is locally maximum. The vein pattern is
% obtained after connecting these points.
%
% Parameters:
% image - The vascular image as input
% fvr - Finger vein region
% sigma - Sigma used for determining derivatives
%
% Returns:
% veins - Vein Image
%
% References:
% [1] Miura, Naoto, et al. Extraction of Finger-Vein Patterns Using Maximum
% Curvature Points in Image Profiles.
% IEICE Trans.
% Inf. Syst. 90-D (2005):1185-1194.
%
% [2] Bram Ton (2022).
% Miura et al. vein extraction methods
% (https://www.mathworks.com/matlabcentral/fileexchange/35716-miura-et-al-vein-extraction-methods)
% MATLAB Central File Exchange.
% Retrieved May 17, 2022.

%% Code:
% Construction of Filter Kernels
winsize = ceil(4*sigma);
[X,Y] = meshgrid(-winsize:winsize, -winsize:winsize);

h = (1/(2*pi*sigma^2)).*exp(-(X.^2 + Y.^2)/(2*sigma^2));
hx = (-X/(sigma^2)).*h;
hxx = ((X.^2 - sigma^2)/(sigma^4)).*h;
hy = hx';
hyy = hxx';
hxy = ((X.*Y)/(sigma^4)).*h;

% Actual Filteration
fx  = imfilter(image, hx,  'replicate', 'conv');
fxx = imfilter(image, hxx, 'replicate', 'conv');
fy  = imfilter(image, hy,  'replicate', 'conv');
fyy = imfilter(image, hyy, 'replicate', 'conv');
fxy = imfilter(image, hxy, 'replicate', 'conv');
f1  = 0.5*sqrt(2)*(fx + fy); % \
f2  = 0.5*sqrt(2)*(fx - fy); % /
f11 = 0.5*fxx + fxy + 0.5*fyy; % \\
f22 = 0.5*fxx - fxy + 0.5*fyy; % //

[imageH, imageW] = size(image); % Image height and width

% Calculation of Curvatures
k = zeros(imageH, imageW, 4);
k(:,:,1) = (fxx./((1 + fx.^2).^(3/2))).*fvr; % Horizontal
k(:,:,2) = (fyy./((1 + fy.^2).^(3/2))).*fvr; % Vertical
k(:,:,3) = (f11./((1 + f1.^2).^(3/2))).*fvr; % \
k(:,:,4) = (f22./((1 + f2.^2).^(3/2))).*fvr; % / 

% Scores
Vt = zeros(imageH, imageW, 4);
Wr = 0;

% Horizontal Direction
bla = k(:,:,1) > 0;
for y=1:imageH
    for x=1:imageW
        if(bla(y,x))
            Wr = Wr + 1;
        end
        
        if ( Wr > 0 && (x == imageW || ~bla(y,x)) )
            if (x == imageW)
                % Edge of Image is reached
                pos_end = x;
            else
                pos_end = x - 1;              
            end
            
            pos_start = pos_end - Wr + 1; % Starting Position of concave      
            [~, I] = max(k(y, pos_start:pos_end,1));
            pos_max = pos_start + I - 1;
            Scr = k(y,pos_max,1)*Wr;
            Vt(y,pos_max) = Vt(y,pos_max) + Scr;
            Wr = 0; 
        end
    end
end

% Vertical Direction
bla = k(:,:,2) > 0;
for x=1:imageW
    for y=1:imageH
        if(bla(y,x))
            Wr = Wr + 1;
        end
        
        if ( Wr > 0 && (y == imageH || ~bla(y,x)) )
            if (x == imageH)
                % Edge of image is reached
                pos_end = y;
            else
                pos_end = y - 1;              
            end
            
            pos_start = pos_end - Wr + 1; % Starting position of concave
            [~, I] = max(k(pos_start:pos_end,x,2));
            pos_max = pos_start + I - 1;
            Scr = k(pos_max,x,2)*Wr;
            Vt(pos_max,x) = Vt(pos_max,x) + Scr;
            Wr = 0;
        end
    end
end

% Direction: \
bla = k(:,:,3) > 0;
for start=1:(imageW+imageH-1)
    % Initial values
    if (start <= imageW)
        x = start;
        y = 1;
    else
        x = 1;
        y = start - imageW + 1;        
    end
    done = false;
    
    while ~done
        if(bla(y,x))
            Wr = Wr + 1;
        end
        
        if ( Wr > 0 && (y == imageH || x == imageW || ~bla(y,x)) )
            if (y == imageH || x == imageW)
                % Edge of image is reached
                pos_x_end = x;
                pos_y_end = y;
            else
                pos_x_end = x - 1;              
                pos_y_end = y - 1;
            end
            pos_x_start = pos_x_end - Wr + 1;
            pos_y_start = pos_y_end - Wr + 1;
            
            d = k(((pos_x_start-1)*imageH + pos_y_start + ...
                2*imageW*imageH):(imageH + 1):((pos_x_end-1)*imageH + ...
                pos_y_end + 2*imageW*imageH));
            [~, I] = max(d);
            pos_x_max = pos_x_start + I - 1;
            pos_y_max = pos_y_start + I - 1;
            Scr = k(pos_y_max,pos_x_max,3)*Wr;
            Vt(pos_y_max,pos_x_max) = Vt(pos_y_max,pos_x_max) + Scr;
            Wr = 0;
        end
        
        if((x == imageW) || (y == imageH))
            done = true;
        else
            x = x + 1;
            y = y + 1;
        end
    end
end

% Direction: /
bla = k(:,:,4) > 0;
for start=1:(imageW+imageH-1)
    % Initial values
    if (start <= imageW)
        x = start;
        y = imageH;
    else
        x = 1;
        y = imageW+imageH-start;        
    end
    done = false;
    
    while ~done
        if(bla(y,x))
            Wr = Wr + 1;
        end
        
        if ( Wr > 0 && (y == 1 || x == imageW || ~bla(y,x)) )
            if (y == 1 || x == imageW)
                % Edge of image is reached
                pos_x_end = x;
                pos_y_end = y;
            else
                pos_x_end = x - 1;              
                pos_y_end = y + 1;
            end
            pos_x_start = pos_x_end - Wr + 1;
            pos_y_start = pos_y_end + Wr - 1;
            
            d = k(((pos_x_start-1)*imageH + pos_y_start + ...
                3*imageW*imageH):(imageH - 1):((pos_x_end-1)*imageH + ...
                pos_y_end + 3*imageW*imageH));
            [~, I] = max(d);
            pos_x_max = pos_x_start + I - 1;
            pos_y_max = pos_y_start - I + 1;
            Scr = k(pos_y_max,pos_x_max,4)*Wr;
            Vt(pos_y_max,pos_x_max) = Vt(pos_y_max,pos_x_max) + Scr;
            Wr = 0;
        end
        
        if((x == imageW) || (y == 1))
            done = true;
        else
            x = x + 1;
            y = y - 1;
        end
    end
end

% Connection of vein centres
Cd = zeros(imageH, imageW, 4);
for x=3:imageW-3
    for y=3:imageH-3
        Cd(y,x,1) = min(max(Vt(y,x+1),  Vt(y,x+2))  ,...
            max(Vt(y,x-1),  Vt(y,x-2)));   % Horizontal
        Cd(y,x,2) = min(max(Vt(y+1,x),  Vt(y+2,x))  ,...
            max(Vt(y-1,x),  Vt(y-2,x)));   % Vertical         
        Cd(y,x,3) = min(max(Vt(y-1,x-1),Vt(y-2,x-2)),...
            max(Vt(y+1,x+1),Vt(y+2,x+2))); % \
        Cd(y,x,4) = min(max(Vt(y+1,x-1),Vt(y+2,x-2)),...
            max(Vt(y-1,x+1),Vt(y-2,x+2))); % /
    end
end

veins = max(Cd,[],3);
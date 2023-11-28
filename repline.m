function veins = repline(image, fvr, itr, dist, width)
%% Repeated Line Tracking Method - Tolesh Pathak
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
% This method, based on line-tracking, starts at multiple positions,
% identifies local dark lines, and then pixel by pixel moves along them.
% When it no longer detects a dark line, a new tracking operation takes
% place at some other position. All the dark lines, representing finger
% veins in the image, can be tracked by executing this routine repeatedly.
% Ultimately, the loci of the detected lines overlap, and vein patterns are
% obtained statistically
%
% Parameters:
% image - The vascular image as input
% fvr - Finger vein region
% itr - Maximum number of iterations
% dist - Distance between the tracking point and cross section of the profile
% width - Width of profile
%
% Returns:
% veins - Vein image
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
p_lr = 0.5;  % Probability of goin left or right
p_ud = 0.25; % Probability of going up or down

% Locus space
locus = zeros(size(image));
bla = [-1,-1; -1,0; -1,1; 0,-1; 0,0; 0,1; 1,-1; 1,0; 1,1];

% Checking if width is even
if (mod(width,2) == 0)
    disp('Error: W must be odd')
end
dist_o = round(dist*sqrt(2)/2); % dist for oblique directions
widthH = (width-1)/2; % half width for horz. and vert. directions
widthHO = round(widthH*sqrt(2)/2); % half width for oblique directions

% Omission of unreachable borders
fvr(1:dist+widthH,:) = 0;
fvr(end-(dist+widthH-1):end,:) = 0;
fvr(:,1:dist+widthH) = 0;
fvr(:,end-(dist+widthH-1):end) = 0;

% Uniformly distributed starting points
indices = find(fvr > 0);
a = randperm(length(indices));
a = a(1:itr); % Limit to number of iterations
[ys, xs] = ind2sub(size(image), indices(a));

% Iterating through all starting points
for it = 1:size(ys,1)
    xc = xs(it); % Current tracking point, x
    yc = ys(it); % Current tracking point, y
 
    % Determinnation of the moving-direction attributes
    % Going left or right ?
    if rand() >= 0.5
        Dlr = -1;  % Going left
    else
        Dlr = 1; % Going right 
    end

    % Going up or down ?
    if rand() >= 0.5
        Dud = -1;  % Going up
    else
        Dud = 1; % Going down 
    end
    
    % Initialization of locus-positition table Tc
    table_locus = false(size(image));

    %Dlr = -1; Dud=-1;% LET OP
    Vl = 1;
    while Vl > 0
        % Determination of the moving candidate point set Nc
        Nr = false(3);
        Rnd = rand();
        if Rnd < p_lr
            % Going left or right
            Nr(:,2+Dlr) = true;
        elseif (Rnd >= p_lr) && (Rnd < p_lr + p_ud)  
            % Going up or down
            Nr(2+Dud,:) = true;
        else
            % Going any direction
            Nr = true(3);
            Nr(2,2) = false;
        end

        tmp = find( ~table_locus(yc-1:yc+1,xc-1:xc+1) & Nr & fvr(yc-1:yc+1,xc-1:xc+1) );
        Nc =[xc + bla(tmp,1), yc + bla(tmp,2)];
        
        if size(Nc,1)==0
            Vl=-1;
            continue
        end

        % Detection of dark line direction near current tracking point
        Vdepths = zeros(size(Nc,1),1); % Valley depths
        for i = 1:size(Nc,1)
            % Horizontal or vertical 
            if Nc(i,2) == yc
                % Horizontal plane
                yp = Nc(i,2);
                if Nc(i,1) > xc
                    % Right direction
                    xp = Nc(i,1) + dist;
                else
                    % Left direction
                    xp = Nc(i,1) - dist;
                end

                Vdepths(i) = image(yp + widthH, xp) - ...
                    2*image(yp,xp) + ...
                    image(yp - widthH, xp);
            elseif Nc(i,1) == xc
                % Vertical plane
                xp = Nc(i,1);
                if Nc(i,2) > yc
                    % Down direction
                    yp = Nc(i,2) + dist;
                else
                    % Up direction
                    yp = Nc(i,2) - dist;
                end

                Vdepths(i) = image(yp, xp + widthH) - ...
                    2*image(yp,xp) + ...
                    image(yp, xp - widthH);
            end
            
            % Oblique directions
            if ((Nc(i,1) > xc) && (Nc(i,2) < yc)) || ((Nc(i,1) < xc) && (Nc(i,2) > yc))
                % Diagonal, up /
                if Nc(i,1) > xc && Nc(i,2) < yc
                    % Top right
                    xp = Nc(i,1) + dist_o;
                    yp = Nc(i,2) - dist_o;
                else
                    % Bottom left
                    xp = Nc(i,1) - dist_o;
                    yp = Nc(i,2) + dist_o;
                end

                Vdepths(i) = image(yp - widthHO, xp - widthHO) - ...
                    2*image(yp,xp) + ...
                    image(yp + widthHO, xp + widthHO);
            else
                % Diagonal, down \
                if Nc(i,1) < xc && Nc(i,2) < yc
                    % Top left
                    xp = Nc(i,1) - dist_o;
                    yp = Nc(i,2) - dist_o;
                else
                    % Bottom right
                    xp = Nc(i,1) + dist_o;
                    yp = Nc(i,2) + dist_o;
                end
                
                Vdepths(i) = image(yp + widthHO, xp - widthHO) - ...
                    2*image(yp,xp) + ...
                    image(yp - widthHO, xp + widthHO);
            end
        end % End search of candidates

        [~, index] = max(Vdepths); % Determination of best candidate

        % Registering tracking information
        table_locus(yc, xc) = true;

        % Increasing the value of tracking space
        locus(yc, xc) = locus(yc, xc) + 1;
        
        % Move tracking point
        xc = Nc(index, 1);
        yc = Nc(index, 2); 
    end
end
veins = locus;
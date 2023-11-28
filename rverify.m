%% Finger Vein Recognition System - Tolesh Pathak
% This script was created as part of Major Project "Finger Vein Recognition
% System." This was also used in the experimentation for the research paper
% "Enhancing Finger Vein Recognition through Composite Feature Extraction 
% Method." This script contains three finger vein feature extraction 
% algorithms, i.e. Maximum Curvature Method, Repeated Line Tracking Method, 
% and Wide Line Tracking Method. This Script utilizes the three of them to
% produce the desire results.
%
% Working: This Script allows the user to input their finger vein data in
% the form of image, and then have the vein features extracted and verified
% against the previously stored data, for the purpose of authentication.

%% Reading User data
userid=input("Enter your User Id: ","s");
[imagename, imagepath] = uigetfile('.database/*.png', 'Select Vascular Images');
image = im2double(imread(strcat(imagepath,imagename)));
image = imresize(image, [189 390]);

%% Image ROI Extraction using lee_region
[fvr, edges] = lregion(image,4,40);

%% Maximum Curvature Method
savedbinmaxcurv = im2double(imread(strcat('.extractedbin/',userid,'.maxcurv.png')));
sigma = 3;
v_maxcurv=maxcurv(image,fvr,sigma);

% Binarization of the vein image
md = median(v_maxcurv(v_maxcurv>0));
v_maxcurv_bin = v_maxcurv > md;

% Match
cw = 80; ch=70;
score = match(double(savedbinmaxcurv), double(v_maxcurv_bin), cw, ch);
%fprintf('Match score: %6.4f %%\n', score);
if score<23
    fprintf('Imposter Detected.\n')
    return;
end

%% Repeated Line Tracking Method
savedbinrepline = im2double(imread(strcat('.extractedbin/',userid,'.repline.png')));
max_iterations = 3000; r=1; W=17; % Parameters
v_repline = repline(image,fvr,max_iterations,r,W);

% Binarization of the vein image
md = median(v_repline(v_repline>0));
v_repline_bin = v_repline > md;
        
% Match
cw = 80; ch=30;
score = match(double(savedbinrepline), double(v_repline_bin), cw, ch);
%fprintf('Match score: %6.4f %%\n', score);
if score<31
    fprintf('Imposter Detected.')
    return;
end

%% Wide Line Tracking Method
savedbinwidline = im2double(imread(strcat('.extractedbin/',userid,'.widline.png')));
r = 7;g = 0.50;t = 1;            
v_widline = widline(im2uint8(image) ,r,g,t);
v_widline = min(v_widline,fvr);

% Binarization of the vein image
v_widline_bin = v_widline > 0;
        
% Match
cw = 80; ch=30;
score = match(double(savedbinwidline), double(v_widline_bin), cw, ch);
%fprintf('Match score: %6.4f %%\n', score);
if score<22
    fprintf('Imposter Detected.')
    return;
end

%% Final Message
fprintf('User is Verified.\n');
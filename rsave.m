%% Finger Vein Recognition System - Tolesh Pathak
% This script was created as part of Major Project "Finger Vein Recognition
% System." This was also used in the experimentation for the research paper
% "Enhancing Finger Vein Recognition through Composite Feature Extraction 
% Method." This script contains three finger vein feature extraction
% algorithms, i.e. Maximum Curvature Method, Repeated Line Tracking Method,
% and Wide Line Tracking Method. This Script utilizes the three of them to 
% produce the desired results.
%
% Working: This Script allows the user to input their finger vein data in
% the form of image, and then have the vein features extracted and saved
% through the proposed composite method.

%% Reading the input image from the file system.
% User ID Prompt
fname=input("Enter your username: ", "s");
fprintf('Select your input file.\n');
% File Dialog
[imagename, imagepath] = uigetfile('.database/*.png', 'Select Vascular Images');
% Image is read and converted to double precision
image = im2double(imread(strcat(imagepath,imagename)));

%% Image ROI Extraction using Localize Region Method
image = imresize(image, [189 390]);
[fvr, edges] = lregion(image,4,40);

%% Maximum Curvature Method
sigma = 3;
v_maxcurv=maxcurv(image,fvr,sigma);

% Binarization of the vein image
md = median(v_maxcurv(v_maxcurv>0));
v_maxcurv_bin = v_maxcurv > md;
imwrite(v_maxcurv_bin,strcat('.extractedbin/',fname,'.maxcurv.png'));    

%% Repeated Line Tracking Method
max_iterations = 3000; r=1; W=17; % Parameters
v_repline = repline(image,fvr,max_iterations,r,W);

% Binarization of the vein image
md = median(v_repline(v_repline>0));
v_repline_bin = v_repline > md;
imwrite(v_repline_bin,strcat('.extractedbin/',fname,'.repline.png'));

%% Wide Line Tracking Method
r = 7;g = 0.50;t = 1;            
v_widline = widline(im2uint8(image) ,r,g,t);
v_widline = min(v_widline,fvr);

% Binarization of the vein image
v_widline_bin = v_widline > 0;
imwrite(v_widline_bin,strcat('.extractedbin/',fname,'.widline.png'));

%% Final Message
fprintf('You are registered.\n');
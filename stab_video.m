close all
clear 
hVideoSrc = VideoReader('images/MAH01462.MP4');

imgA = rgb2gray(im2single(readFrame(hVideoSrc))); % Read first frame into imgA
imgB = rgb2gray(im2single(readFrame(hVideoSrc))); % Read second frame into imgB

figure; imshowpair(imgA, imgB, 'montage');
title(['Frame A', repmat(' ',[1 70]), 'Frame B']);

figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
title('Color composite (frame A = red, frame B = cyan)');

ptThresh = 0.1;
pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);

% Display corners found in images A and B.
figure; imshow(imgA); hold on;
plot(pointsA);
title('Corners in A');


figure; imshow(imgB); hold on;
plot(pointsB);
title('Corners in B');

% Extract FREAK descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA);
[featuresB, pointsB] = extractFeatures(imgB, pointsB);

indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
legend('A', 'B');

[tform, inlierIdx] = estimateGeometricTransform2D(...
    pointsB, pointsA, 'affine');
pointsBm = pointsB(inlierIdx, :);
pointsAm = pointsA(inlierIdx, :);
imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
pointsBmp = transformPointsForward(tform, pointsBm.Location);

figure;
showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
legend('A', 'B');

% Extract scale and rotation part sub-matrix.
H = tform.T;
R = H(1:2,1:2);
% Compute theta from mean of two possible arctangents
theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% Compute scale from mean of two stable mean calculations
scale = mean(R([1 4])/cos(theta));
% Translation remains the same:
translation = H(3, 1:2);
% Reconstitute new s-R-t transform:
HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
  translation], [0 0 1]'];
tformsRT = affine2d(HsRt);

imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));

figure(2), clf;
imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
title('Color composite of affine and s-R-t transform outputs');


% Reset the video source to the beginning of the file.
read(hVideoSrc, 1);
                      
hVPlayer = vision.VideoPlayer; % Create video viewer

% Process all frames in the video
movMean = rgb2gray(im2single(readFrame(hVideoSrc)));
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
ii = 2;
Hcumulative = eye(3);
while hasFrame(hVideoSrc) 
    % Read in new frame
    imgA = imgB; % z^-1
    imgAp = imgBp; % z^-1
    imgB = rgb2gray(im2single(readFrame(hVideoSrc)));
    movMean = movMean + imgB;

    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = helper(imgA,imgB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

    % Display as color composite with last corrected frame
    step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgBp;
    
    ii = ii+1;
end
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);

% Here you call the release method on the objects to close any open files
% and release memory.
release(hVPlayer);


function H = helper(leftI,rightI,ptThresh)
%Get inter-image transform and aligned point features.
%  H = cvexEstStabilizationTform(leftI,rightI) returns an affine transform
%  between leftI and rightI using the |estimateGeometricTransform|
%  function.
%
%  H = cvexEstStabilizationTform(leftI,rightI,ptThresh) also accepts
%  arguments for the threshold to use for the corner detector.

% Copyright 2010 The MathWorks, Inc.

% Set default parameters
if nargin < 3 || isempty(ptThresh)
    ptThresh = 0.1;
end

%% Generate prospective points
pointsA = detectFASTFeatures(leftI, 'MinContrast', ptThresh);
pointsB = detectFASTFeatures(rightI, 'MinContrast', ptThresh);

%% Select point correspondences
% Extract features for the corners
[featuresA, pointsA] = extractFeatures(leftI, pointsA);
[featuresB, pointsB] = extractFeatures(rightI, pointsB);

% Match features which were computed from the current and the previous
% images
indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

%% Use MSAC algorithm to compute the affine transformation
tform = estimateGeometricTransform(pointsB, pointsA, 'affine');
H = tform.T;
end

function [H,s,ang,t,R] = cvexTformToSRT(H)
%Convert a 3-by-3 affine transform to a scale-rotation-translation
%transform.
%  [H,S,ANG,T,R] = cvexTformToSRT(H) returns the scale, rotation, and
%  translation parameters, and the reconstituted transform H.

% Extract rotation and translation submatrices
R = H(1:2,1:2);
t = H(3, 1:2);
% Compute theta from mean of stable arctangents
ang = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% Compute scale from mean of two stable mean calculations
s = mean(R([1 4])/cos(ang));
% Reconstitute transform
R = [cos(ang) -sin(ang); sin(ang) cos(ang)];
H = [[s*R; t], [0 0 1]'];
end


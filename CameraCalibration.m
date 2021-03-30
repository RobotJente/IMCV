function [cameraParams]=CameraCalibration(cal_images)

im1=read(cal_images,1); %save image 1 as im1
image_loc=cal_images.ImageLocation;

% Now we want to get the camera parameters so we can get the lens distortion
% Detect calibration pattern.
[imagePoints, boardSize] = detectCheckerboardPoints(image_loc);

% Generate world coordinates of the corners of the squares.
squareSize = 40; %millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
imageSize = [size(im1, 1), size(im1, 2)];
[cameraParams, imagesUsed, estimationErrors] = ...
 estimateCameraParameters(imagePoints, worldPoints,'ImageSize', imageSize);

% %% Run dit voor visualisatie van wat ie doet
% % Visualize camera extrinsics.
% figure;
% showExtrinsics(cameraParams);
% drawnow;
% 
% % Plot detected and reprojected points.
% figure; 
% imshow(cal_images.ImageLocation{1}); 
% hold on
% plot(imagePoints(:, 1, 1), imagePoints(:, 2, 1), 'go');
% plot(cameraParams.ReprojectedPoints(:, 1, 1), cameraParams.ReprojectedPoints(:, 2, 1), 'r+');
% legend('Detected Points', 'ReprojectedPoints');
% hold off

% lens distortion visualisation
ut_plot_lens_distortion(cameraParams,imageSize)



    
    
   
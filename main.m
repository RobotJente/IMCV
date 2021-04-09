%% Project 2: Man on Board
%% Course: Image processing and computer vision
%% Group: 1
%% Authors: Dionne Ariens, Jesse van Werven, Roxane Munsterman
%% Date: 29-03-2021

clear all; close all; clc;
videoReader = VideoReader('images/MAH01462.MP4');

%% Camera calibration by checkerboard calibration images
%Load calibration images from zip file
cal_images=imageSet('./images/calibration images');

[cameraParams] = CameraCalibration(cal_images);
% videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

% tracked = ImageTracker(videoReader)

stabilized = stabilize_video(videoReader);




   
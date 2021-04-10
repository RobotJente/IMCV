%% Project 2: Man on Board
%% Course: Image processing and computer vision
%% Group: 1
%% Authors: Dionne Ariens, Jesse van Werven, Roxane Munsterman
%% Date: 29-03-2021

clear; close all; clc;
videoReader = VideoReader('images/MAH01462.MP4');

%% Camera calibration by checkerboard calibration images
%Load calibration images from zip file
% cal_images=imageSet('./images/calibration images');
% 
% [cameraParams] = CameraCalibration(cal_images);
% % videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);
% 
% % tracked = ImageTracker(videoReader)
% 
% stabilized = stabilize_video(videoReader);
% v = VideoWriter("images/stabilized_vid_1");
% open(v)
% 
% writeVideo(v,stabilized);
% close(v)
% 
%    

%% Tracking
% videoReader = VideoReader('images/stab_1.avi');
% v = ImageTracker(videoReader);
% 
% originalVid = VideoReader('images/stab_1.avi');
% release(originalVid)

videoReader = VideoReader('images/stab_1.avi');
v = track_template(videoReader)


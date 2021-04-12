%% Project 2: Man on Board
%% Course: Image processing and computer vision
%% Group: 1
%% Authors: Dionne Ariens, Jesse van Werven, Roxane Munsterman
%% Date: 29-03-2021

clear; close all; clc;

%% Camera calibration by checkerboard calibration images
% Load calibration images from zip file
% cal_images=imageSet('./images/calibration images');
% [cameraParams] = CameraCalibration(cal_images);
% save cameraParams cameraParams

%% Open video reader and load video
videoReader = VideoReader('images/MAH01462.MP4');

% write video file to images/stab_final.avi
stabVidPath = 'images/stab_final.avi';
stabilize_video(videoReader, stabVidPath);

%% Template Tracking

% access camera parameters used to determine distance to the buoy
c = load('cameraParams');
principalPoint = c.cameraParams.PrincipalPoint;
focalLength = c.cameraParams.FocalLength;

% finally, open video reader to track the template 
videoReader = VideoReader(stabVidPath);

s = load('template_data');
template = s.data{1,1};
template = rgb2gray(im2double(template));

% Since we have no initial information about the speed of the buoy except
% that its motion is almost purely horizontal due to the stabilization, we
% make some guess at the motion model
motionModel = [1, 0]; % [x, y]

% Initialize pos, utility struct for template matching. Used
% for determining the initial ROI and the width and height of the search
% box. 
pos.template_orig = [650 527]; % [x y] upper left corner, found by manual pinpointing of the buoy
pos.template_size = [10 10];   % [width height]
pos.search_border = [15 10];   % max horizontal and vertical displacement
pos.template_center = floor((pos.template_size-1)/2);
pos.template_center_pos = (pos.template_orig + pos.template_center - 1);

% select file to write video output to
filePath = "images/tracked_buoy.avi";

% Track the given template in the video, given the motion model, and return
% the distances
videoReader = VideoReader(stabVidPath);

v = track_template(videoReader, filePath, template, motionModel, principalPoint, focalLength, pos);







%%
% % Old implementation for stabilization using LK tracker
% % Tracking
% stab_vid_link = 'images/stab_final.avi';
% videoReader = VideoReader(stab_vid_link);
% v = ImageTracker(videoReader);

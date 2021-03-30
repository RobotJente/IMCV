%% Project 2: Man on Board
%% Course: Image processing and computer vision
%% Group: 1
%% Authors: Dionne Ariens, Jesse van Werven, Roxane Munsterman
%% Date: 29-03-2021

clear all; close all; clc;
v = VideoReader('MAH01462.MP4')

%% Camera calibration by checkerboard calibration images
%Load calibration images from zip file
cal_images=imageSet('C:\Users\Roxan\Desktop\IPCV_Project\calibration_images');

[cameraParams]=CameraCalibration(cal_images)
   
   
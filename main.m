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

% [cameraParams] = CameraCalibration(cal_images);
% videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

%tracked = ImageTracker(videoReader)

% stab_video(videoReader)



hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                            'BestMatchNeighborhoodOutputPort', true);
hVideoOut = vision.VideoPlayer('Name', 'Video Stabilization');

                        
                        

W = videoReader.Width; % Width in pixels
H = videoReader.Height; % Height in pixels

sz = [W, H];

SearchRegion = [W, H]
Offset = [0 0];
Target = zeros(18,22);
firstTime = true;
while hasFrame(videoReader)
    input = rgb2gray(im2double(readFrame(videoReader)));

    % Find location of Target in the input video frame
    if firstTime
      Idx = int32([18, 0])  
      MotionVector = [0 0];
      firstTime = false;
    else
      IdxPrev = Idx;

      ROI = [SearchRegion, 18, 0];
      Idx = hTM(input,Target,ROI);

      MotionVector = double(Idx-IdxPrev);
    end

    % Translate video frame to offset the camera motion
    Stabilized = imtranslate(input, Offset, 'linear');
    hVideoOut([input(:,:,1) Stabilized]);
end


function [Offset, SearchRegion] = updatesearch(sz, MotionVector, SearchRegion, Offset, pos)
% Function to update Search Region for SAD and Offset for Translate

  % check bounds
  A_i = Offset - MotionVector;
  AbsTemplate = pos.template_orig - A_i;
  SearchTopLeft = AbsTemplate - pos.search_border;
  SearchBottomRight = SearchTopLeft + (pos.template_size + 2*pos.search_border);

  inbounds = all([(SearchTopLeft >= [1 1]) (SearchBottomRight <= fliplr(sz))]);

  if inbounds
      Mv_out = MotionVector;
  else
      Mv_out = [0 0];
  end

  Offset = Offset - Mv_out;
  SearchRegion = SearchRegion + Mv_out;

end % function updatesearch

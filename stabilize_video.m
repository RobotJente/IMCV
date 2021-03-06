% STABILIZE_VIDEO stabilizes a video, removing shakiness/motion from holding the
% camera from the video. Uses template matching on a stationary point in
% the background to determine translation between frames. The translation
% is used to map consecutive images to each other, stabilizing the image
%
% [distance] = STABILIZE_VIDEO(videoReader, filePath);
%
% @param videoReader: video reader object containing video to be stabilized
% @param filePath: location to save the stabilized video
%
% code adapted from and inspired by https://nl.mathworks.com/help/vision/ref/vision.templatematcher-system-object.html

function [] = stabilize_video(videoReader, filePath) % Input video file which needs to be stabilized.
    % instantiate video reader, player, and template matcher
    vid_player = vision.VideoPlayer('Name', 'Video Stabilization');
    matcher = vision.TemplateMatcher('ROIInputPort', true, 'BestMatchNeighborhoodOutputPort', true);
    videoFWriter = vision.VideoFileWriter(filePath, 'FrameRate',videoReader.FrameRate);

    % read first frame and use it to select the template to be matched by
    % manual cropping
%     im = readFrame(videoReader);
%     [sub_im, rectout] = imcrop(im);
%     data = {sub_im, rectout};
%     save stabilization_template data

    % alternatively, you can use the saved template we used to reproduce
    % our results exactly
    s = load('data/stabilization_template');
    sub_im = s.data{1,1};
    sub_im = rgb2gray(im2double(sub_im));
    rectout = s.data{1,2};
    % initialize pos, utility struct for the initial position of the template
    pos.template_orig = [rectout(1) rectout(2)]; % [x y] upper left corner
    pos.template_size = [30 30];   % [width height]
    pos.search_border = [15 10];   % max horizontal and vertical displacement
    pos.template_center = floor((pos.template_size-1)/2);
    pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
    
    W = videoReader.Width; % Width in pixels
    H = videoReader.Height; % Height in pixels
    sz = [W, H];
    BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
    BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
    
    SearchRegion = pos.template_orig - pos.search_border - 1;
    Offset = [0 0];
    
    % template to track
    Target = im2gray(im2double(sub_im));
    firstTime = true;



    while hasFrame(videoReader)
        input = im2gray(im2double(readFrame(videoReader)));

        % Find location of Target in the input video frame
        if firstTime
          Idx = int32(pos.template_center_pos);
          MotionVector = [0 0];
          firstTime = false;
        else
          IdxPrev = Idx;

          ROI = [SearchRegion, pos.template_size+2*pos.search_border];
          Idx = matcher(input,Target,ROI);

          MotionVector = double(Idx-IdxPrev);
        end

        [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
            SearchRegion, Offset, pos);

        % Translate video frame to offset the camera motion
        stabilized = imtranslate(input, Offset, 'linear');

        % Add black border for display
        stabilized(:, BorderCols) = 0;
        stabilized(BorderRows, :) = 0;

        TargetRect = [pos.template_orig-Offset, pos.template_size];
        SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

        % Draw rectangles on input to show target and search region
        input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                            'Color', 'white');

        % Display video
        vid_player([input(:,:,1) stabilized]);
        % save frame
        step(videoFWriter, stabilized); % saves video

    end
    release(videoFWriter); % close the videoWriter

end % function stabilize_video




% Helper function from Matlab to update Search Region for SAD and Offset for Translate
function [Offset, SearchRegion] = updatesearch(sz, MotionVector, SearchRegion, Offset, pos)

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


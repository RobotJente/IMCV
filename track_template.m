% TRACK_TEMPLATE tracks a template in a video sequence, estimating
% distances based on camera parameters. Writes tracked video to file 
%
% [distance] = TRACK_TEMPLATE(videoReader, template, motionModel, principalPoint, focalLength);
%
% @param videoReader: video reader object containing video to be inspected
% for template
% 
% @param template: image template to be matched in video frames
%
% @param motionModel: initial estimate of the motion of the tracked object\
%
% @param principalPoint: camera parameter used to estimate distance to
% template, obtained from camera calibration
%
% @param focalLength: camera parameter used to estimate distance to
% template, obtained from camera calibration
%
% @returns distances: list, contains distances between camera and matched
% template at each frame
% 
% code adapted from and inspired by https://nl.mathworks.com/help/vision/ref/vision.templatematcher-system-object.html

function [distances] = track_template(videoReader, filePath, template, motionModel, principalPoint, focalLength, pos) % Input video file which needs to be stabilized.

    % instantiate video reader, player, and template matcher
    vidPlayer = vision.VideoPlayer('Name', 'Video Tracking');
    
    % if more computational speed is desired, the setting 3-step can
    % be used. This setting defaults to exhaustive, but the 3-step search 
    % criterion sacrifices accuracy of match for computational efficiency
    % usage:  'SearchMethod', 'Three-step'
    matcher = vision.TemplateMatcher('ROIInputPort', true, 'BestMatchNeighborhoodOutputPort', true, 'Metric', 'Sum of squared differences', 'SearchMethod', 'Exhaustive');
    
    % Write video to file
    videoFWriter = vision.VideoFileWriter(filePath, 'FrameRate',videoReader.FrameRate);
    W = videoReader.Width; % Width in pixels
    H = videoReader.Height; % Height in pixels
    sz = [W, H];
  
    searchRegion = pos.template_orig - pos.search_border - 1;
    offset = [0 0];
    distances = [];

    
    % used for moving average filter over previous motionvectors for the
    % motion model
    prevMotionVectorsX = [];
    prevMotionVectorsY = [];        % current implementation only uses X (see report)
    Idx = int32(pos.template_center_pos);
    window = 7;                     % window size for Moving Average Filter

    while hasFrame(videoReader)
        input = readFrame(videoReader);
        input = rgb2gray(im2double(input));
        
        % Update previous location 
        IdxPrev = Idx;
        
        % Create ROI using searchregion and border size from pos struct
        ROI = [searchRegion, pos.template_size+2*pos.search_border];
        
        % Find location of best match and metrics around this point. A low 
        % metric means better fitness for that position
        [Idx, metrics] = matcher(input,template,ROI);

        ychange = abs(Idx(2) - IdxPrev(2));
        xchange = abs(Idx(1) - IdxPrev(1));
           
        % The metric at the best location is thresholded, so that when the
        % buoy is not visible due to the waves, the matching algorithm does
        % not match a different object. Y change is also bounded since we 
        % know the change in y must be small once we have found the buoy.
        if metrics(2,2) > 0.2 || ychange > 1 %|| xchange > 4
            % no match found, use model
            detected = false;
            Idx = IdxPrev + int32(motionModel);
            motionVector = double(Idx-IdxPrev);

        else 
            % match found, use position of template matcher
            detected = true;
            motionVector = double(Idx-IdxPrev);
            
            % save velocities for motion model moving average filter
            xVels = [prevMotionVectorsX motionVector(1)];
            %yVels = [prevMotionVectorsY motionVector(2)];
            
            % adjust motion model to be the current change in pixels with
            % window size 7
            filterRange = max(1,length(xVels) - window) : length(xVels);
            motionModel(1) = mean(filterRange);
            
            % No motion model in y direction since any motion in that
            % direction is pure noise, since the stabilized video can only
            % have x direction motion
            
            % motionModel(2) = mean(yVels(length(yVels) - window : length(yVels)));

        end
        prevMotionVectorsX = [prevMotionVectorsX motionVector(1)];
        prevMotionVectorsY = [prevMotionVectorsY motionVector(1)];

        if detected
            c = 'green';
            txt = sprintf('There was a match');
        else
            c = 'red';
            txt = sprintf('There was no match');

        end
        [offset, searchRegion] = updateSearch(sz, motionVector, searchRegion, offset, pos);

        TargetRect = [pos.template_orig-offset, pos.template_size];
        SearchRegionRect = [searchRegion, pos.template_size + 2*pos.search_border];

           
        % Draw rectangles on input to show target and search region
        input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect], 'Color', c);
        % Display the offset (displacement) values on the input image
        input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, 'TextColor', c, 'BoxOpacity', 0);            
        % Display video
        vidPlayer(input);
        % save frame
        
        %videoFWriter(input);
        step(videoFWriter, input); % saves video
        distances = [distances, calc_distance(Idx, principalPoint, focalLength)];


    end
    release(videoFWriter); % close the videoWriter

end % function stabilize_video




% Helper function from Matlab to update Search Region for SAD and Offset for Translate
function [Offset, SearchRegion] = updateSearch(sz, MotionVector, SearchRegion, Offset, pos)

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
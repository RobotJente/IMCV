function [stabilized] = track_template(videoReader) % Input video file which needs to be stabilized.
    % instantiate video reader, player, and template matcher
    vid_player = vision.VideoPlayer('Name', 'Video Tracking');
    matcher = vision.TemplateMatcher('ROIInputPort', true, 'BestMatchNeighborhoodOutputPort', true);
    %matcher = vision.TemplateMatcher('ROIInputPort', false, 'BestMatchNeighborhoodOutputPort', true);

    videoFWriter = vision.VideoFileWriter('images/track_1.avi', 'FrameRate',videoReader.FrameRate);

    % read first frame and use it to select the template to be matched
%     im = readFrame(videoReader);
%     [sub_im, rectout] = imcrop(im);
%     [sub_im] = imcrop(sub_im);
    s = load('template_data');
    sub_im = s.data{1,1};
    rectout = s.data{1,2};


    
    % initialize pos, utility struct for template matching
    pos.template_orig = [rectout(1) rectout(2)]; % [x y] upper left corner
    pos.template_size = [30 30];   % [width height]
    pos.search_border = [15 10];   % max horizontal and vertical displacement
    pos.template_center = floor((pos.template_size-1)/2);
    pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
    
    W = videoReader.Width; % Width in pixels
    H = videoReader.Height; % Height in pixels
    sz = [W, H];
  
    SearchRegion = pos.template_orig - pos.search_border - 1;
    Offset = [0 0];
    Target = rgb2gray(im2double(sub_im));
    firstTime = true;


    while hasFrame(videoReader)
        input = rgb2gray(im2double(readFrame(videoReader)));

        % Find location of Target in the input video frame
        if firstTime
          Idx = int32(pos.template_center_pos);
          MotionVector = [0 0];
          firstTime = false;
        else
          IdxPrev = Idx;

          ROI = [SearchRegion, pos.template_size+2*pos.search_border];
          %Idx = matcher(input,Target);
          Idx = matcher(input,Target,ROI);

          MotionVector = double(Idx-IdxPrev);
        end

        [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
            SearchRegion, Offset, pos);


        TargetRect = [pos.template_orig-Offset, pos.template_size];
        SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

        % Draw rectangles on input to show target and search region
        input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                            'Color', 'white');
        % Display the offset (displacement) values on the input image
        txt = sprintf('(%+05.1f,%+05.1f)', Offset);
        input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, ...
                        'TextColor', 'white', 'BoxOpacity', 0);
        % Display video
        vid_player([input(:,:,1)]);
        % save frame
        step(videoFWriter, input); % saves video
        stabilized = input;
        

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
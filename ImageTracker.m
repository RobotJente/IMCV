% Adapted from https://nl.mathworks.com/help/vision/ref/vision.pointtracker-system-object.html

function [trackedVideo] = ImageTracker(videoReader)
    for i = 1:100
       readFrame(videoReader); 
    end
    % create videoplayer and reader to iterate through video images
    videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

    objectFrame = readFrame(videoReader);
    % Bound ROI
    s = load('template_data');
    rectout = s.data{1,2};
%     objectRegion = [,300,680,520];
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
    objectRegion = [SearchRegion, pos.template_size+2*pos.search_border*2];

    objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');

    % visual representation of ROI
    figure;
    imshow(objectImage);
    title('Red box shows object region');

    % Find interest points using Shi-Tomasi corner detection
    points = detectMinEigenFeatures(rgb2gray(objectFrame),'ROI',objectRegion);

    % Visual representation of interest points
    pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
    figure;
    imshow(pointImage);
    title('Detected interest points');

    % create tracker using Kanade-Lucas-Tomasi algorithm
    tracker = vision.PointTracker('MaxBidirectionalError',1);
    initialize(tracker,points.Location,objectFrame);

    % loop through video frames  
    while hasFrame(videoReader)
          frame = readFrame(videoReader);
          [points,validity] = tracker(frame);
          out = insertMarker(frame,points(validity, :),'+');
          videoPlayer(out);
    end

    release(videoPlayer);
    trackedVideo = videoPlayer
end

    
    
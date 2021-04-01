% Adapted from https://nl.mathworks.com/help/vision/ref/vision.pointtracker-system-object.html

function [trackedVideo] = ImageTracker(videoReader)
    % create videoplayer and reader to iterate through video images
    videoPlayer = vision.VideoPlayer('Position',[100,100,680,520]);

    objectFrame = readFrame(videoReader);
    % Bound ROI
    objectRegion = [400,300,680,520];
    objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');

    % visual representation of ROI
    figure;
    imshow(objectImage);
    title('Red box shows object region');

    % Find interest points using Shi-Tomasi corner detection
    points = detectMinEigenFeatures(im2gray(objectFrame),'ROI',objectRegion);

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

    
    
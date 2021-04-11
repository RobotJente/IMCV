function [Offset, Idx, SearchRegion, input] = track_template_per_frame(Target, frame, pos, SearchRegion, sub_im, Offset, Idx) % Input video file which needs to be stabilized.
    matcher = vision.TemplateMatcher('ROIInputPort', true, 'BestMatchNeighborhoodOutputPort', true, 'Metric', 'Sum of squared differences');
    %matcher = vision.TemplateMatcher('ROIInputPort', false, 'BestMatchNeighborhoodOutputPort', true);
    
    input = rgb2gray(im2double(frame));    
    IdxPrev = Idx;
    sz = size(input);

    % determine ROI and find location and metrics for best template match using template matcher
    ROI = [SearchRegion, pos.template_size+2*pos.search_border];
    %input = inc_contrast(input, 5, mean(Target, 'all'));
    %Target = inc_contrast(Target, 5, mean(Target, 'all'));
    [Idx, metrics] = matcher(input, Target,ROI);
    
    % find change in x and y to bound the object motion
    ychange = abs(Idx(1) - IdxPrev(1));
    xchange = abs(Idx(2) - IdxPrev(2));
    c = 'blue';
    % if the change is too big for the object's motion model, or the metric
    % score is too weak, we discard the observation and step using the
    % motion model
%     if metrics(2,2) > 0.2 || ychange > 1 || xchange > 1
    if metrics(2,2) > 7
      %Idx = int32([IdxPrev(1)+0.8, IdxPrev(2)]);
      Idx = int32([IdxPrev(1), IdxPrev(2)]);
      c = 'red';
      txt = sprintf('There was no match');
    else 
      txt = sprintf('There was a match');

    end
    metrics(2,2)
    MotionVector = double(Idx-IdxPrev);
    [Offset, SearchRegion] = updatesearch(sz, MotionVector, SearchRegion, Offset, pos);

    % determine rectangle bounds for visualization
    TargetRect = [pos.template_orig-Offset, pos.template_size];
    SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];
    
    % Draw rectangles on input to show target and search region
    input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                        'Color', c);
    % Display the offset (displacement) values on the input image
    input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, ...
                    'TextColor', c, 'BoxOpacity', 0);

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

function [im] = inc_contrast(im, thresh, mean)
    im = im - mean;

    im(im >= thresh) = im(im>=thresh) + 100;
    im(im < thresh) = im(im<thresh) - 100;

end
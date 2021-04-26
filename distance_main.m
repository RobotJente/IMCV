
videoReader = VideoReader('images/stab_1.avi');
videoFWriter = vision.VideoFileWriter('images/track-bg.avi', 'FrameRate',videoReader.FrameRate);

% initialize pos, utility struct for template matching
pos.template_orig = [650 527]; % [x y] upper left corner
pos.template_size = [10 10];   % [width height]
pos.search_border = [15 10];   % max horizontal and vertical displacement
pos.template_center = floor((pos.template_size-1)/2);
pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
Offset = [0 0];
Idx = int32(pos.template_center_pos);
SearchRegion = pos.template_orig - pos.search_border - 1;


s_bg = load('template_data_background');
sub_im_bg = s_bg.data{1,1};
rectout_bg = s_bg.data{1,2};
s = load('template_data');
sub_im = s.data{1,1};
rectout = s.data{1,2};

Target = rgb2gray(im2double(sub_im_bg));
Target_bg = rgb2gray(im2double(sub_im_bg));
  
% initialize pos, utility struct for template matching
pos_bg.template_orig = [1200 520]; % [x y] upper left corner
pos_bg.template_size = fliplr(size(Target_bg));   % [width height]
pos_bg.search_border = [25 25];   % max horizontal and vertical displacement
pos_bg.template_center = floor((pos_bg.template_size-1)/2);
pos_bg.template_center_pos = (pos_bg.template_orig + pos_bg.template_center - 1);
Offset = [0 0];
Idx = int32(pos_bg.template_center_pos);
SearchRegion = pos_bg.template_orig - pos_bg.search_border - 1;

i = 0
while hasFrame(videoReader) && i < 160
    frame = readFrame(videoReader);

    i = i + 1
    [Offset, Idx, SearchRegion, input] = track_template_per_frame(Target_bg, frame, pos_bg, SearchRegion, sub_im_bg, Offset, Idx);
    %[Offset, Idx, SearchRegion] = track_template_per_frame(Target, frame, pos, SearchRegion, sub_im, Offset, Idx);
    step(videoFWriter, input); % saves video
end
release(videoFWriter); % close the videoWriter





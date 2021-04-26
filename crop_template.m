% script used for template creation

% read first frame and use it to select the template to be matched
videoReader = VideoReader('images/stab_1.avi');

% choose frame where template is easily visible
frameNumber = 68;
im = read(videoReader, frameNumber);

% crop the image
[sub_im, rectout] = imcrop(im);
% [sub_im] = imcrop(sub_im);            % uncomment if you want to crop the
%                                       % cropped image 


data = {sub_im, rectout};
save stab_template data


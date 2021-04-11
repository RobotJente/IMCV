% make template

% read first frame and use it to select the template to be matched
videoReader = VideoReader('images/stab_1.avi');
% 
% for i = 1:100
%     i+25
%     im = read(videoReader, 25+i);
% %     [sub_im, rectout] = imcrop(im);
% %     [sub_im] = imcrop(sub_im);
%     imshow(im)
%     pause(0.5)
%     
% end
im = read(videoReader, 68);
imshow(im)

[sub_im, rectout] = imcrop(im);
[sub_im] = imcrop(sub_im);
data = {sub_im, rectout}
save template_data_background data
% videoReader = VideoReader('images/stabilized_vid_1.avi');
% I = readFrame(videoReader);
s_bg = load('template_data_background');
sub_im_bg = s_bg.data{1,1};
rectout_bg = s_bg.data{1,2};
J = sub_im_bg;
thresh = 5;

J = J - mean(J, 'all')

J(J >= thresh) = J(J>=thresh) + 100;
J(J < thresh) = J(J<thresh) - 100;

figure; 
imshow(sub_im_bg - mean(J, 'all'))
figure
imshow(J)
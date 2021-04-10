videoReader = VideoReader('images/stabilized_vid_1.avi');
I = readFrame(videoReader);
thresh = 255;

J(J > thresh) = 255;%J(J>thresh) + 40;
J(J < thresh) = 0;%J(J<thresh) - 100;

figure; 
imshow(I)
figure
imshow(J)
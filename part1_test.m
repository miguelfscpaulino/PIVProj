imgs_folder = 'images';

img_rgb=dir(fullfile(imgs_folder,'*.jpg'));
img_depth=dir(fullfile(imgs_folder,'*.mat'));



imgseq1=repmat(struct('rgb',fullfile(imgs_folder,img_rgb(1).name),'depth',fullfile(imgs_folder,img_depth(2).name)), length(img_rgb), 1);

for i=2:length(img_rgb)

    imgseq1(i)=struct('rgb',fullfile(imgs_folder,img_rgb(i).name),'depth',fullfile(imgs_folder,img_depth(i).name));

end

load('cameraparametersAsus.mat');

% 	% Convert RGB image to HSV
% 	hsvImage = rgb2hsv(imread(imgseq1(1).rgb));
% 	% Extract out the H, S, and V images individually
% 	hImage = hsvImage(:,:,1);
% 	sImage = hsvImage(:,:,2);
% 	vImage = hsvImage(:,:,3);
% 	
% 	% Display the hue image.
%     figure
%     imagesc(imread(imgseq1(1).rgb));
%     
% 	figure
%     subplot(1,2,1);
% 	imagesc(hImage);
%     subplot(1,2,2);
%     imhist(hImage)
%     
%     figure
%     subplot(1,2,1);
% 	imagesc(sImage);
%     subplot(1,2,2);
%     imhist(sImage)
%     
%     figure
%     subplot(1,2,1);
% 	imagesc(vImage);
%     subplot(1,2,2);
%     imhist(vImage)

[obj]=track3D_part1(imgseq1, cam_params);

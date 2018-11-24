imgs_folder = 'images';

img_rgb=dir(fullfile(imgs_folder,'*.jpg'));
img_depth=dir(fullfile(imgs_folder,'*.mat'));



imgseq1=repmat(struct('rgb',fullfile(imgs_folder,img_rgb(1).name),'depth',fullfile(imgs_folder,img_depth(2).name)), length(img_rgb), 1);

for i=2:length(img_rgb)

    imgseq1(i)=struct('rgb',fullfile(imgs_folder,img_rgb(i).name),'depth',fullfile(imgs_folder,img_depth(i).name));

end

load('cameraparametersAsus.mat');

[obj]=track3D_part1(imgseq1, cam_params);

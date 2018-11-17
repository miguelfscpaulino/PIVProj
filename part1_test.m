
img_rgb=dir('*.jpg');
img_depth=dir('*.mat');

imgseq1=repmat(struct('rgb',img_rgb(1).name,'depth',img_depth(2).name), length(img_rgb), 1);

for i=2:length(img_rgb)

    imgseq1(i)=struct('rgb',img_rgb(i).name,'depth',img_depth(i).name);

end

load('cameraparametersAsus.mat');

[obj]=track3D_part1(imgseq1, cam_params);

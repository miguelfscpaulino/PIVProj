function [objects] = track3D_part1(imgseq1, cam_params)
%
%   

imgs=zeros(480,640,length(imgseq1));
imgsd=zeros(480,640,length(imgseq1));
for i=1:length(imgseq1)
    imgs(:,:,i)=rgb2gray(imread(imgseq1(i).rgb));
    load(imgseq1(i).depth);
    imgsd(:,:,i)=double(depth_array)/1000;
    figure(1)
    imshow(uint8(imgs(:,:,i)));
    figure(2);
    imagesc(imgsd(:,:,i));
    %colormap(gray);
    pause(0.01);
end

    
    bgdepth=median(imgsd,3);
    bggray=median(imgs,3);
    figure();
    imagesc(bgdepth);
    figure();
    imagesc(bggray);



for i=1:(length(imgseq1))
    imdiff=abs(imgsd(:,:,i)-bgdepth)>.2;
    imgdiffiltered=imopen(imdiff,strel('disk',5));
    figure(1);
    imagesc([imdiff imgdiffiltered]);
    title('Difference image and morph filtered');
    colormap(gray);
    figure(2);
    imagesc([imgsd(:,:,i) bgdepth]);
    title('Depth image i and background image');
    figure(3);   
    bw2=bwareaopen(imgdiffiltered,1500);
    [bw3,M]=bwlabel(bw2);
    imagesc(bw3);
    title('Connected components');
    
    figure(4);
    imagesc(imread(imgseq1(i).rgb));
   
    
        
    for j=1:M
        [row,col]=find(bw3==j);
        
        y=[min(row) max(row) max(row) min(row) min(row)];
        x=[min(col) min(col) max(col) max(col) min(col)];
        hold on
        plot(x,y,'r');
    end
    
   
    
    pause(0.1);
    
end
% for i=1:(length(imgseq1))
%    
%     load(imgseq1(i).depth);
%     xyz1=get_xyz_asus(depth_array(:),[480 640],(1:640*480)', cam_params.Kdepth,2,1);
%     rgbd1 = get_rgbd(xyz1, imread(imgseq1(i).rgb), cam_params.R, cam_params.T, cam_params.Krgb);
%     figure(9);
%     imagesc(rgbd1);
%     pc1=pointCloud(xyz1,'Color',reshape(rgbd1,[480*640 3]));
%     figure(10); 
%     showPointCloud(pc1);
%     pause(0.05);
%     
% end

objects=1;

end


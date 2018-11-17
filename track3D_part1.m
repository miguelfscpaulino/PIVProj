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
%     figure(1);
%     imagesc([imgdiffiltered]);
%     title('Difference image and morph filtered');
%     colormap(gray);
%     figure(2);
%     imagesc([imgsd(:,:,i) bgdepth]);
%     title('Depth image i and background image');
    figure(3);    
    bw2=bwareaopen(imgdiffiltered,2000);
    [bw3,M]=bwlabel(bw2);
    imagesc(bw3);
    
    for j=1:M
        [row,col]=find(bw3==j);
        mask(j)=struct('x',col,'y',row);
        yy=[min(row) max(row) max(row) min(row) min(row)];
        xx=[min(col) min(col) max(col) max(col) min(col)];
        hold on
        plot(xx,yy,'r');
        
    end
    
    
    title('Connected components');
    pause(0.1);
    
end
% for i=1:(length(imgseq1))
    load(imgseq1(8).depth);
    aux1=max(mask(1).x)-min(mask(1).x);
    aux2=max(mask(1).y)-min(mask(1).y);
    aux3(:,1)=[depth_array(mask(1).x);depth_array(mask(1).y)];
    xyz1=get_xyz_asus(aux3(:),[aux1 aux2],(1:length(aux3))', cam_params.Kdepth,2,1);
    rgbd1 = get_rgbd(xyz1, imread(imgseq1(8).rgb), cam_params.R, cam_params.T, cam_params.Krgb);
    figure(4);
    imagesc(rgbd1);
    pc1=pointCloud(xyz1,'Color',reshape(rgbd1,[480*640 3]));
    figure(5); 
    showPointCloud(pc1);
    pause(0.05);
    
% end


objects=1;

end


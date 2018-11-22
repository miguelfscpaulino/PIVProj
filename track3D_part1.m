function [objects] = track3D_part1(imgseq1, cam_params)



imgs=zeros(480,640,length(imgseq1));
imgsd=zeros(480,640,length(imgseq1));
for i=1:length(imgseq1)
    imgs(:,:,i)=rgb2gray(imread(imgseq1(i).rgb));
    load(imgseq1(i).depth);
    imgsd(:,:,i)=double(depth_array)/1000;
    %figure(1)
    %imshow(uint8(imgs(:,:,i)));
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
    imgdiffiltered=imopen(imdiff,strel('disk',9));
    %     figure(1);
    %     imagesc([imgdiffiltered]);
    %     title('Difference image and morph filtered');
    %     colormap(gray);
    %     figure(2);
    %     imagesc([imgsd(:,:,i) bgdepth]);
    %     title('Depth image i and background image');
%     figure(3);
    bw2=bwareaopen(imgdiffiltered,2000);
%     imagesc(bw2);
    figure(3);
    [bw3,M]=bwlabel(bw2);
    imagesc(bw3);
    
    for j=1:M        
        ind=find(bw3==j);
        load(imgseq1(i).depth);
        aux=zeros(480,640);
        aux(ind)=depth_array(ind);
        xyz1=get_xyz_asus(aux(:),[480 640],(1:640*480)', cam_params.Kdepth,2,1);
        pc1=pointCloud(xyz1);
        figure(6);
        showPointCloud(pc1);
        pause(0.5);
        
    end
    
    
    
    
    %title('Connected components');
    pause(0.1);
    
end



objects=1;

end


function [objects,cam2toW] = track3D_part2(imgseq1, imgseq2, cam_params)



imgs1=zeros(480,640,length(imgseq1));
imgsd1=zeros(480,640,length(imgseq1));
imgs2=zeros(480,640,length(imgseq2));
imgsd2=zeros(480,640,length(imgseq2));

    for i=1:length(imgseq1)
        imgs1(:,:,i)=rgb2gray(imread(imgseq1(i).rgb));
        imgs2(:,:,i)=rgb2gray(imread(imgseq2(i).rgb));
        load(imgseq1(i).depth);
        imgsd1(:,:,i)=double(depth_array)/1000;
        figure(1);
        imagesc(imgsd1(:,:,i));
        load(imgseq2(i).depth);
        imgsd2(:,:,i)=double(depth_array)/1000;
        figure(2);
        imagesc(imgsd2(:,:,i));
        pause(0.1);

    end
    
    % Calculate BackGround
    bgdepth_cam1=median(imgsd1(:,:,:),3);
    bgrgb_cam1=median(imgs1(:,:,:),3);
    bgrgb_cam2=median(imgs2(:,:,:),3);
    bgdepth_cam2=median(imgsd2(:,:,:),3);
    figure(3);
    subplot(2,2,1);
    imagesc(bgdepth_cam1);
    subplot(2,2,2);
    imagesc(bgdepth_cam2);
    subplot(2,2,3);
    imagesc(bgrgb_cam1);
    subplot(2,2,4);
    imagesc(bgrgb_cam2);
    
    [f1,d1]=vl_sift(im2single(bgrgb_cam1));
    [f2,d2]=vl_sift(im2single(bgrgb_cam2));
    
    matches=vl_ubcmatch(d1,d2);
    figure(4);
    subplot(1,2,1);
    imagesc(bgrgb_cam1);
    hold on;
    vl_plotframe(f1(:,matches(1,:)),'r');
    hold off;
    subplot(1,2,2);
    imagesc(bgrgb_cam2);
    hold on;
    vl_plotframe(f2(:,matches(2,:)),'r');
    hold off;
    
    
    
    
    
    
    
    
    objects=1;
    cam2toW=1;
end
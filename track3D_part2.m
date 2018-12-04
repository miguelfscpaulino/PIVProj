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
    f_cam1=round(f1(1:2,matches(1,:)));
    f_cam2=round(f2(1:2,matches(2,:)));
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
   
    inliers=[];
    np=6;
    xyz_cam1=zeros(np,3);
    xyz_cam2=xyz_cam1;
    xyz_cam1=get_xyz_asus(bgdepth_cam1(:)*1000,[480 640],(1:size(bgdepth_cam1)),cam_params.Kdepth,1,0);
    xyz_cam2=get_xyz_asus(bgdepth_cam2(:)*1000,[480 640],(1:size(bgdepth_cam2)),cam_params.Kdepth,1,0);
    rgbd_cam1=get_rgbd(xyz_cam1,imread(imgseq1(1).rgb),cam_params.R, cam_params.T, cam_params.Krgb);
    rgbd_cam2=get_rgbd(xyz_cam2,imread(imgseq2(1).rgb),cam_params.R, cam_params.T, cam_params.Krgb);  
   
   %for n=1:100
   %try uncomment the for and replace ind_cam's with the commented ones
   %ind_cam1=sub2ind(size(bgrgb_cam1),f_cam1(2,p),f_cam1(1,p));
   %ind_cam2=sub2ind(size(bgrgb_cam2),f_cam2(2,p),f_cam2(1,p));
       p = randperm(length(f_cam1),np);
       ind_cam1=sub2ind(size(bgrgb_cam1),f_cam1(2,:),f_cam1(1,:));
       ind_cam2=sub2ind(size(bgrgb_cam2),f_cam2(2,:),f_cam2(1,:));
       xyz_rand1=xyz_cam1(ind_cam1,:);
       xyz_rand2=xyz_cam2(ind_cam2,:);
       inds=find(xyz_rand1(:,3).*xyz_rand2(:,3)>0);
       xyz_rand1=xyz_rand1(inds,:);
       xyz_rand2=xyz_rand2(inds,:);
       [d,z,transform]=procrustes(xyz_rand1,xyz_rand2,'scaling',false, 'reflection',false);
       xyz21=xyz_cam2*transform.T+ones(length(xyz_cam2),1)*transform.c(1,:);
       pc1=pointCloud(xyz_cam1,'Color',reshape(rgbd_cam1,[480*640 3]));
       pc2=pointCloud(xyz_cam2,'Color',reshape(rgbd_cam2,[480*640 3]));
       pc3=pointCloud(xyz21,'Color',reshape(rgbd_cam2,[480*640 3]));
       figure(5);
       showPointCloud(pc1);
       figure(6);
       showPointCloud(pc2);
       figure(7);
       showPointCloud(pc3);
   %end
   
    
    
    
    
    
    
    objects=1;
    cam2toW=1;
end
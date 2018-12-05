function [objects,cam2toW] = track3D_part2(imgseq1, imgseq2, cam_params)

% sift parameter
edge_thresh=100;

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
        subplot(1,2,1);
        imagesc(imgsd1(:,:,i));
        load(imgseq2(i).depth);
        imgsd2(:,:,i)=double(depth_array)/1000;
        subplot(1,2,2);
        imagesc(imgsd2(:,:,i));
        pause(0.1);

    end
    
    % Calculate BackGround
    bgdepth_cam1=median(imgsd1(:,:,:),3);
    bgrgb_cam1=median(imgs1(:,:,:),3);
    bgrgb_cam2=median(imgs2(:,:,:),3);
    bgdepth_cam2=median(imgsd2(:,:,:),3);
    figure(2);
    subplot(2,2,1);
    imagesc(bgdepth_cam1);
    subplot(2,2,2);
    imagesc(bgdepth_cam2);
    subplot(2,2,3);
    imagesc(bgrgb_cam1);
    subplot(2,2,4);
    imagesc(bgrgb_cam2);
    
%     % Harris corner detector (good points)
%     figure(4);
%     subplot(1,2,1);
%     [cim1, r1, c1] = harris(bgrgb_cam1, 2, 300, 2, 0);
%     imagesc(bgrgb_cam1);
%     hold on;
%     plot(c1,r1,'r+');
%     subplot(1,2,2);
%     [cim2, r2, c2] = harris(bgrgb_cam2, 2, 300, 2, 0);
%     imagesc(bgrgb_cam2);
%     hold on;
%     plot(c2,r2,'r+');
    
    % Another Harris implemations same results
%     figure();
%     corners = detectHarrisFeatures(bgrgb_cam2, 'FilterSize', 3);
%     imshow(bgrgb_cam2); hold on;
%     plot(corners.selectStrongest(300));

    % find matching points using SIFT
    for i=1:length(imgseq1)
        load(imgseq1(i).depth);
        xyz_cam1=get_xyz_asus(depth_array(:),[480 640], 1:480*640, cam_params.Kdepth ,1,0);
        rgbd_cam1=get_rgbd(xyz_cam1,imread(imgseq1(i).rgb), cam_params.R, cam_params.T, cam_params.Krgb);
        load(imgseq2(i).depth);
        xyz_cam2=get_xyz_asus(depth_array(:),[480 640], 1:480*640, cam_params.Kdepth ,1,0);
        rgbd_cam2=get_rgbd(xyz_cam2,imread(imgseq2(i).rgb), cam_params.R, cam_params.T, cam_params.Krgb);
     
        [~,d1]=vl_sift(im2single(rgb2gray(rgbd_cam1)),'edgethresh', edge_thresh);
        [~,d2]=vl_sift(im2single(rgb2gray(rgbd_cam2)),'edgethresh', edge_thresh);
        [matches, ~]= vl_ubcmatch(d1,d2);
        num_matches(i)=length(matches);        
    end
    
    %Matching for the image with the most matches
    [~,index]=max(num_matches);
    
    load(imgseq1(index).depth);
    xyz_cam1=get_xyz_asus(depth_array(:),[480 640], 1:480*640, cam_params.Kdepth ,1,0);
    rgbd_cam1=get_rgbd(xyz_cam1,imread(imgseq1(i).rgb), cam_params.R, cam_params.T, cam_params.Krgb);
    
    load(imgseq2(index).depth);
    xyz_cam2=get_xyz_asus(depth_array(:),[480 640], 1:480*640, cam_params.Kdepth ,1,0);
    rgbd_cam2=get_rgbd(xyz_cam2,imread(imgseq2(i).rgb), cam_params.R, cam_params.T, cam_params.Krgb);
    
    [f1,d1]=vl_sift(im2single(rgb2gray(rgbd_cam1)),'edgethresh', edge_thresh);
    [f2,d2]=vl_sift(im2single(rgb2gray(rgbd_cam2)),'edgethresh', edge_thresh);
    [matches, ~]= vl_ubcmatch(d1,d2);
    
    cam1=[(fix(f1(1,matches(1,:))))' (fix(f1(2,matches(1,:))))'];
    cam2=[(fix(f2(1,matches(2,:))))' (fix(f2(2,matches(2,:))))'];
    
    % good points in each image
    figure(3);
    subplot(1,2,1);
    imagesc(imgs1(:,:,index));
    hold on;
    plot(cam1(:,1),cam1(:,2),'*r');
    hold off;
    subplot(1,2,2);
    imagesc(imgs2(:,:,index));
    hold on;
    plot(cam2(:,1),cam2(:,2),'*r');
    hold off;
    
    % matched points
    figure(4);
    ax = axes;
    showMatchedFeatures(bgrgb_cam1, bgrgb_cam2, cam1, cam2,'montage','Parent',ax);
    
    
    
    %Ransac
    
    ind_cam1=sub2ind([480 640],cam1(:,2),cam1(:,1));
    ind_cam2=sub2ind([480 640],cam2(:,2),cam2(:,1));
    xyz_points1=xyz_cam1(ind_cam1,:);
    xyz_points2=xyz_cam2(ind_cam2,:);
    
    %choose the good points
    inds=find((xyz_points1(:,3).*xyz_points2(:,3))>0);
    xyz_points1=xyz_points1(inds,:);
    xyz_points2=xyz_points2(inds,:);
    
    %Test random sets of 4 points
    niter=500;
    error_thresh=0.10;
    aux=fix(rand(4*niter,1)*length(xyz_points1)+1);
    
    for i=1:niter-4
        xyz_aux1=xyz_points1(aux(4*i:4*i+3),:);
        xyz_aux2=xyz_points2(aux(4*i:4*i+3),:);
        [d,z,trans]=procrustes(xyz_aux1,xyz_aux2,'scaling',false,'reflection',false);
        R(:,:,i)=trans.T; T(:,:,i)=trans.c;
        error=xyz_points1-xyz_points2*trans.T-ones(length(xyz_points2),1)*trans.c(1,:);
        numinliers(i)=length(find(sum(error.*error,2)<error_thresh^2));
    end
    
    [value index]= max(numinliers);
    R=R(:,:,index);
    T=T(:,:,index);
    error=xyz_points1-xyz_points2*R-ones(length(xyz_points2),1)*T(1,:);
    inds=find(sum(error.*error,2)<error_thresh^2);
    xyz_points1=xyz_points1(inds,:);
    xyz_points2=xyz_points2(inds,:);
    [d,z,trans]=procrustes(xyz_points1,xyz_points2,'scaling',false,'reflection',false);
    cam2toW=struct('R',trans.T,'T', trans.c);
    xyz21=xyz_cam2*cam2toW.R+ones(length(xyz_cam2),1)*cam2toW.T(1,:);
    pc1=pointCloud(xyz_cam1,'Color',reshape(rgbd_cam1,[480*640 3]));
    pc2=pointCloud(xyz_cam2,'Color',reshape(rgbd_cam2,[480*640 3]));
    pc3=pointCloud(xyz21,'Color',reshape(rgbd_cam1,[480*640 3]));
    figure(5);
    showPointCloud(pc1);
    figure(6);
    showPointCloud(pc2);
    figure(7);
    showPointCloud(pc3);
    
    objects=1;
end
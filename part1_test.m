close all;
clear;

imgs_folder = 'images1';

img_rgb=dir(fullfile(imgs_folder,'*.jpg'));
img_depth=dir(fullfile(imgs_folder,'*.mat'));

imgseq1=repmat(struct('rgb',fullfile(imgs_folder,img_rgb(1).name),'depth',fullfile(imgs_folder,img_depth(1).name)), length(img_rgb), 1);

for i=1:length(img_rgb)

    imgseq1(i)=struct('rgb',fullfile(imgs_folder,img_rgb(i).name),'depth',fullfile(imgs_folder,img_depth(i).name));

end

load('cameraparametersAsus.mat');


[obj]=track3D_part1(imgseq1, cam_params);


%% Function

% img_size = size(imread(imgseq1(1).rgb));
% imgs_len = length(imgseq1);
% 
% imgs = zeros(img_size(1), img_size(2), imgs_len);
% imgsrgb = zeros(img_size(1), img_size(2), 3*imgs_len);
% imgsd = zeros(img_size(1), img_size(2), imgs_len);
% objects = struct('X', zeros(1,8), 'Y', zeros(1,8), 'Z', zeros(1,8), 'frames_tracked', [0]);
% 
% % f_im = figure; 
% % f_imdepth = figure;
% for i = 1:imgs_len
% %     figure(f_im);
%     % RGB Image
%     imgsrgb(:,:,(3*(i-1)+1):(3*(i-1)+3)) = imread(imgseq1(i).rgb);
% %     subplot(1,2,1);
% %     imshow(uint8(imgsrgb(:,:,(3*(i-1)+1):(3*(i-1)+3))));
% %     title(['RGB Image ', num2str(i)]);
%     % Grayscale Image
%     imgs(:,:,i) = rgb2gray(imread(imgseq1(i).rgb));
% %     subplot(1,2,2);
% %     imshow(uint8(imgs(:,:,i)));
% %     title(['Gray Image ', num2str(i)]);
%     % Depth Image
%     load(imgseq1(i).depth);
%     imgsd(:,:,i) = double(depth_array)/1000;
% %     figure(f_imdepth);
% %     imagesc(imgsd(:,:,i));
% %     title(['Depth image ', num2str(i)]);
% end
% 
% 
% %%
% % Calculate BackGround
% bgdepth = median(imgsd(:,:,1:30), 3);
% bgrgb = median(imgs(:,:,1:30), 3);
% figure;
% title('Background');
% s1 = subplot(1, 2, 1);
% imagesc(bgrgb);
% title(s1, 'Background RGB image');
% s2 = subplot(1, 2, 2);
% imagesc(bgdepth);
% title(s2, 'Background depth image');
% 
% %%
% 
% % f_im = figure;
% f_imdepth = figure;
% % f_imdiff = figure;
% % f_imdiff_fil = figure;
% % f_grad = figure;
% % f_gradient = figure;
% % f_gradval = figure;
% f_imdiff_fil2 = figure;
% f_label = figure;
% f_pc = figure;
% for i = 1:imgs_len
% 
% %     figure(f_im);
% %     imshow(imgs(:,:,i));
% %     title(['GrayImage ', num2str(i)]);
%     figure(f_imdepth);
%     imagesc(imgsd(:,:,i));
%     title(['Depth image ', num2str(i)]);
% 
%     %BackGround Subtraction
%     imdiff = abs(imgsd(:,:,i)-bgdepth) > 0.2;
% %     figure(f_imdiff);
% %     imagesc(imdiff);
% %     title(['Background subtraction image, ', num2str(i)]);
% 
%     % Morfological Filter
%     imgdiffiltered = imopen(imdiff, strel('disk',9));
% %     figure(f_imdiff_fil);
% %     imagesc(imgdiffiltered);
% %     title(['Filtered background subtraction image, ', num2str(i)]);
% 
%     value = find(imgdiffiltered == 1);
%     grad = zeros(img_size(1), img_size(2));
%     dept = imgsd(:,:,i);
%     grad(value) = dept(value);
%     
% %     figure(f_grad);
% %     imagesc(grad);
% %     title(['Grad ', num2str(i)])
% 
%     [FX,FY] = gradient(grad);
% %     figure(f_gradient);
% %     s1 = subplot(1,2,1);
% %     imagesc(FX);
% %     title(s1, ['FX ', num2str(i)])
% %     s2 = subplot(1,2,2);
% %     imagesc(FY);
% %     title(s2, ['FY ', num2str(i)])
%     
%     gradValX = abs(FX);
%     gradValY = abs(FY);
% %     figure(f_gradval);
% %     s1 = subplot(1,2,1);
% %     imagesc(gradValX);
% %     title(s1, ['gradValX ', num2str(i)])
% %     s2 = subplot(1,2,2);
% %     imagesc(gradValY);
% %     title(s2, ['gradValY ', num2str(i)])
% 
%     figure(f_imdiff_fil2);
%     s1 = subplot(1,2,1);
%     imagesc(imgdiffiltered);
%     title(['Filtered before, ', num2str(i)]);
%     
%     [I, J] = ind2sub(img_size(1:2), find(imgdiffiltered == 1));
%     r = I(I > 1 & I < img_size(1) & J > 1 & J < img_size(2));
%     c = J(I > 1 & I < img_size(1) & J > 1 & J < img_size(2));
%     for ind = 1:length(r)
%         neigh_v = [gradValX(r(ind)-1,c(ind)-1)
%                    gradValX(r(ind)-1,c(ind))
%                    gradValX(r(ind)-1,c(ind)+1)
%                    gradValX(r(ind),c(ind)-1)
%                    gradValX(r(ind),c(ind)+1)
%                    gradValX(r(ind)+1,c(ind)-1)
%                    gradValX(r(ind)+1,c(ind))
%                    gradValX(r(ind)+1,c(ind)+1)];
%         v = abs(gradValX(r(ind),c(ind)) - neigh_v);
%         neigh_u = [gradValY(r(ind)-1,c(ind)-1)
%                    gradValY(r(ind)-1,c(ind))
%                    gradValY(r(ind)-1,c(ind)+1)
%                    gradValY(r(ind),c(ind)-1)
%                    gradValY(r(ind),c(ind)+1)
%                    gradValY(r(ind)+1,c(ind)-1)
%                    gradValY(r(ind)+1,c(ind))
%                    gradValY(r(ind)+1,c(ind)+1)];
%         u = abs(gradValY(r(ind),c(ind)) - neigh_u);
%         
%         if(~isempty(find(v > 0.2)>0) || ~isempty(find(u > 0.2)>0))
%             imgdiffiltered(r(ind),c(ind)) = 0;
%         end
%     end
%     
%     s2 = subplot(1,2,2);
%     imagesc(imgdiffiltered);
%     title(['Filtered after, ', num2str(i)]);
% 
% 
%     bw2 = bwareaopen(imgdiffiltered, 1000);
%     [bw3,M] = bwlabel(bw2);
%     figure(f_label);
%     imagesc(bw3);
%     title(['Img bwlabel, ', num2str(i)]);
% 
%     figure(f_pc);
%     clf;
%     grid on;
%     hold on;
%     xlabel('x');
%     ylabel('y');
%     zlabel('z');
%     for j = 1:M
%         ind = find(bw3 == j);
%         aux = zeros(img_size(1:2));
%         auxd = imgsd(:,:,i);
%         aux(ind) = auxd(ind)*1000;
%         xyz = get_xyz_asus(aux(:), img_size(1:2), find(aux > 0.2 & aux < 6000), cam_params.Kdepth, 1, 0);
%         pc = pointCloud(xyz);
%         showPointCloud(pc);
%         
%         auxLoc = pc.Location ~= 0;
%         X = pc.Location(auxLoc(:,1));
%         Y = pc.Location(auxLoc(:,2));
%         Z = pc.Location(auxLoc(:,3));
%         
%         
%         pause();
%     end
% %     for j=1:M        
% %         ind=find(bw3==j);
% %         load(imgseq1(i).depth);
% %         aux=zeros(480,640);
% %         aux(ind)=depth_array(ind);
% %         xyz1=get_xyz_asus(aux(:),[480 640], find(aux>0.2 & aux<6000), cam_params.Kdepth,1,0);
% %         pc1=pointCloud(xyz1);
% % 
% % 
% %         showPointCloud(pc1);
% % 
% %         Z=pc1.Location(:,3);
% %         zmax=max(Z)
% %         zmin=min(Z(Z~=0))
% % 
% %         Y=pc1.Location(:,2);
% %         ymax=max(Y)
% %         ymin=min(Y(Y~=0))
% % 
% %         X=pc1.Location(:,1);
% %         xmax=max(X(X~=0))
% %         xmin=min(X)
% % 
% %         if zmax==0
% %            continue; 
% %         end
% % 
% % 
% %         % draw box
% %         X = [xmin;xmin;xmin;xmin;xmin];
% %         Y = [ymin;ymin;ymax;ymax;ymin];
% %         Z = [zmin;zmax;zmax;zmin;zmin];
% %         hold on;
% %         plot3(X,Y,Z,'r');   
% %         X = [xmax;xmax;xmax;xmax;xmax];
% %         hold on;
% %         plot3(X,Y,Z,'r'); 
% % 
% %         Z = [zmin;zmin;zmin;zmin;zmin];
% %         X = [xmin;xmin;xmax;xmax;xmin];
% %         Y = [ymin;ymax;ymax;ymin;ymin];
% %         hold on;
% %         plot3(X,Y,Z,'r');   
% %         Z = [zmax;zmax;zmax;zmax;zmax];
% %         hold on;
% %         plot3(X,Y,Z,'r'); 
% %         %hold off;
% % 
% %         pause(0.2);
% % 
% %     end
%     pause();
% end



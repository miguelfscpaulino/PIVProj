function [objects] = track3D_part1(imgseq1, cam_params)


    imgs=zeros(480,640,length(imgseq1));
    imgsd=zeros(480,640,length(imgseq1));
    objects=struct('X', [], 'Y', [], 'Z', []);

    for i=1:length(imgseq1)
        imgs(:,:,i)=rgb2gray(imread(imgseq1(i).rgb));
        load(imgseq1(i).depth);
        imgsd(:,:,i)=double(depth_array)/1000;
        figure(1);
        imagesc(imgsd(:,:,i));
        pause(0.01);
    end

    % Calculate BackGround
    bgdepth=median(imgsd(:,:,1:30),3);
    bgrgb=median(imgs(:,:,1:30),3);
    figure(2);
    subplot(1,2,1);
    imagesc(bgrgb);
    subplot(1,2,2);
    imagesc(bgdepth);


    for i=1:(length(imgseq1))
    
        figure(1);
        imagesc(imgsd(:,:,i));

        %BackGround Subtraction
        imdiff=abs(imgsd(:,:,i)-bgdepth)>.2;

        % Morfological Filter
        imgdiffiltered=imopen(imdiff,strel('disk',9));

        figure(3);
        imagesc(imgdiffiltered);

        value=find(imgdiffiltered==1);
        grad=zeros(480,640);
        dept=imgsd(:,:,i);
        grad(value)=dept(value);

        figure(4);
        [FX,FY]=gradient(grad);
        gradValX=abs(FX);
        gradValY=abs(FY);
        subplot(1,2,1);
        imagesc(gradValX);
        subplot(1,2,2);
        imagesc(gradValY);

        for r=2:479
            for c=2:639

                v=abs(gradValX(r,c)-[gradValX(r+1,c) gradValX(r-1,c) gradValX(r,c+1) gradValX(r,c-1) gradValX(r+1,c+1) gradValX(r-1,c-1) gradValX(r-1,c+1) gradValX(r+1,c-1)]);
                u=abs(gradValY(r,c)-[gradValY(r+1,c) gradValY(r-1,c) gradValY(r,c+1) gradValY(r,c-1) gradValY(r+1,c+1) gradValY(r-1,c-1) gradValY(r-1,c+1) gradValY(r+1,c-1)]);
                if(~isempty(find(v > 0.2)>0) || ~isempty(find(u > 0.2)>0))
                    imgdiffiltered(r,c)=0;
                end

            end
        end

        figure(5);
        imagesc(imgdiffiltered);

        bw2=bwareaopen(imgdiffiltered,1000);

        [bw3,M]=bwlabel(bw2);
        figure(6);
        imagesc(bw3);

        
        figure(7);
        clf;
        for j=1:M        
            ind=find(bw3==j);
            load(imgseq1(i).depth);
            aux=zeros(480,640);
            aux(ind)=depth_array(ind);
            xyz1=get_xyz_asus(aux(:),[480 640], find(aux>0.2 & aux<6000), cam_params.Kdepth,1,0);
            pc1=pointCloud(xyz1);
            
            
            showPointCloud(pc1);

            Z=pc1.Location(:,3);
            zmax=max(Z)
            zmin=min(Z(Z~=0))

            Y=pc1.Location(:,2);
            ymax=max(Y)
            ymin=min(Y(Y~=0))

            X=pc1.Location(:,1);
            xmax=max(X(X~=0))
            xmin=min(X)
            
            if zmax==0
               continue; 
            end
            
            
            % draw box
            X = [xmin;xmin;xmin;xmin;xmin];
            Y = [ymin;ymin;ymax;ymax;ymin];
            Z = [zmin;zmax;zmax;zmin;zmin];
            hold on;
            plot3(X,Y,Z,'r');   
            X = [xmax;xmax;xmax;xmax;xmax];
            hold on;
            plot3(X,Y,Z,'r'); 
    
            Z = [zmin;zmin;zmin;zmin;zmin];
            X = [xmin;xmin;xmax;xmax;xmin];
            Y = [ymin;ymax;ymax;ymin;ymin];
            hold on;
            plot3(X,Y,Z,'r');   
            Z = [zmax;zmax;zmax;zmax;zmax];
            hold on;
            plot3(X,Y,Z,'r'); 
            %hold off;
            
            pause(0.2);

        end
    end
end


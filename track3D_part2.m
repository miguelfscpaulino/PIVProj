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
    
    
    
    
    
    
    
    
    objects=1;
    cam2toW=1;
end
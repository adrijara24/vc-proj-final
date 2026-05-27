function chars = segm(im)
    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    bw = imadjust(im);
    bw = ~imbinarize(bw, 'adaptive', 'Sensitivity',0.7);
    %bw = imclearborder(bw);
    %figure, imshow(bw);
    % [szy, szx] = size(bw);
    % EE = strel('rectangle', [1, round(szx * 0.3)]);
    % bord = imopen(bw, EE);
    % bw = bw & ~bord;
    bw = bwareaopen(bw, 50);
    %bw = bwareaopen(bw, 500,4);
    %blobs = watershed(bw, 8);
    %disp(max(max(blobs)));
    CC = bwconncomp(bw);% Substituir per Canny?
    S = regionprops(CC, 'BoundingBox', 'Area', 'Extent');

    blobs = [];
    for k = 1:numel(S)
        bb = S(k).BoundingBox;
        ar = bb(3) / bb(4);
        if ar < 0.8 && ar > 0.1
            blobs = [blobs; [bb(1), bb(2), bb(3), bb(4)]];
        end
    end
    if ~isempty(blobs)
        chars = sortrows(blobs, 1);
    else
        chars = [];
    end
    
end
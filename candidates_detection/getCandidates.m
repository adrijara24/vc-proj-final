
function candidates = getCandidates(im, showSteps)
    im = rgb2gray(im);
    im = imadjust(im);
    [szy, szx] = size(im);
    if showSteps
        figure, imshow(im), title('input image');
    end
    candidates = [];
    
    area = numel(im);
    edges = edge(im,'sobel', 'vertical');
    if showSteps
        figure, imshow(edges), title('edges');
    end
    sizes = [
        1, 5;
        2, 12;
        5, 20;
        8, 30;
        12, 45;
        ceil(0.010 * szy), ceil(0.030 * szx);
        ];
    for si = 1:size(sizes, 1)
        he = sizes(si, 1);
        wi = sizes(si, 2);
        EE = strel('rectangle', [he, wi]);
        EE2 = strel('rectangle', [he, wi]);
    
        cl = imdilate(edges, EE);
        cl = imfill(cl, 'holes');
        cl = imerode(cl, EE2);
    
        if showSteps
            figure, imshow(cl), title('close');
        end
    
        CC = bwconncomp(cl);
        S = regionprops(CC, 'BoundingBox', 'Area', 'Extent'); 

        for k = 1:numel(S)
            bb = S(k).BoundingBox;
            x = max(bb(1) - 10, 0);
            y = max(bb(2) - 10, 0);
            w = min(bb(3) + 20, szx);
            h = min(bb(4) + 20, szy);
            if w < 10 || h < 10
                continue;
            end
    
            ar = w / h;
            if ar < 1
                ar = 1 / ar;
            end
    
            areaRatio = S(k).Area / area;
    
            isWide = (ar > 1.7) && (ar <= 12);
            isRect = S(k).Extent >= 0.15;
            isReasonable = (areaRatio > 0.0005) & (areaRatio <= 0.25);
            if isWide && isRect && isReasonable
                candidates = [candidates; [x y w h]];
            end
        end
    end
end


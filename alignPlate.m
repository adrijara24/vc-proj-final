function [alignedCrop, alignedBB] = alignPlate(im, boundingBox)
    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    bw = imadjust(im);
    bw = imbinarize(bw, "adaptive");
    [szy, szx] = size(im);
    %figure, imshow(bw), title('adaptive binarize');
    alignedBB = boundingBox;

    CC = bwconncomp(bw);
    S = regionprops(CC, 'Orientation', 'Area', 'Extent');
    [~, idx] = max([S.Area]);
    if ~isempty(S)
        ang = S(idx).Orientation;
        im = imrotate(im, -ang);
        bw = imrotate(bw, -ang);
        
        CC = bwconncomp(bw);
        S = regionprops(CC, 'BoundingBox', 'Area');
        [~, idx] = max([S.Area]);
        bb = S(idx).BoundingBox;
        
        [szyR, szxR] = size(im);
        im = imcrop(im, bb);

        rot = [
            bb(1), bb(2);
            bb(1) + bb(3), bb(2);
            bb(1) + bb(3), bb(2) + bb(4);
            bb(1), bb(2) + bb(4);
            ];
        
        
        CO = [szx, szy] / 2;
        CR = [szxR, szyR] / 2;
        R = [cosd(ang), -sind(ang); sind(ang), cosd(ang)];
        corners = zeros(4, 2);
        for i = 1:4
            pR = rot(i, :) - CR;
            pO = pR * R;
            corners(i, :) = pO + CO;
        end
        
        alignedBB = corners + [boundingBox(1), boundingBox(2)] - 1;

    end
    alignedCrop = im;
    %figure, imshow(alignedCrop);
end
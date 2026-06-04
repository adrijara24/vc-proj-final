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
        %bb2 = [bb(1) - 10, bb(2) - 10, bb(3) + 20, bb(4) + 20];
        im = imcrop(im, bb);
        off = 15;
        bx = max(1, bb(1) - off);
        by = max(1, bb(2) - off);
        bwi = min(szxR - bx, bb(3) + (2 * off));
        bhe = min(szyR - by, bb(4) + (2 * off));
        bb2 = [bx, by, bwi, bhe];
        bb = bb2;
    
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

function [alignedCrop, alignedBB] = alignPlateExp(im, boundingBox)
if size(im, 3) == 3
    im = rgb2gray(im);
end
bw = imadjust(im);
bw = imbinarize(bw, "adaptive");
[szy, szx] = size(im);
%figure, imshow(bw), title('adaptive binarize');
alignedBB = boundingBox;

edges = edge(bw, 'canny');
[H, theta, rho] = hough(edges);
P = houghpeaks(H, 5, 'Threshold', ceil(0.3*max(H(:))));
lines = houghlines(edges, theta, rho, P, 'FillGap', 5, 'MinLength', szx*0.3);
angles = [];
for k = 1:length(lines)
    a = lines(k).theta;
    if a < 0
        a = a + 90;
    else
        a = a - 90;
    end
    if abs(a) < 25
        angles = [angles, a];
    end
end

if ~isempty(angles)
    ang = median(angles);
else
    fprintf("Align fallback\n");
    CC = bwconncomp(bw);
    S = regionprops(CC, 'Orientation', 'Area', 'Extent');
    [~, idx] = max([S.Area]);
    if ~isempty(S)
        ang = S(idx).Orientation;
    else
        ang = 0;
    end
end
if ang ~= 0 || ~isempty(angles)
    im = imrotate(im, -ang);
    bw = imrotate(bw, -ang);

    CC = bwconncomp(bw);
    S = regionprops(CC, 'BoundingBox', 'Area');
    [~, idx] = max([S.Area]);
    bb = S(idx).BoundingBox;

    [szyR, szxR] = size(im);
    off = 0;
    bx = max(1, bb(1) - off);
    by = max(1, bb(2) - off);
    bwi = min(szxR - bx, bb(3) + (2 * off));
    bhe = min(szyR - by, bb(4) + (2 * off));
    bb2 = [bx, by, bwi, bhe];
    bb = bb2;
    im = imcrop(im, bb);

    rot = [
        bb(1), bb(2);
        bb(1) + bb(3), bb(2);
        bb(1) + bb(3), bb(2) + bb(4);
        bb(1), bb(2) + bb(4);
        ];


    CO = [szx, szy] / 2;
    CR = [szxR, szyR] / 2;
    R = [cosd(ang), sind(ang); -sind(ang), cosd(ang)];
    corners = zeros(4, 2);
    for i = 1:4
        pR = rot(i, :) - CR;
        pO = pR * R;
        corners(i, :) = pO + CO;
    end

    alignedBB = corners + [boundingBox(1), boundingBox(2)] - 1;

end
alignedCrop = im;
end
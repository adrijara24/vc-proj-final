% function alignedCrop = alignPlate(im)
%     if size(im, 3) == 3
%         im = rgb2gray(im);
%     end
%     edges = edge(im, 'sobel');
%     [B, L] = bwboundaries(edges, 4, 'noholes');
%     figure, imshow(label2rgb(L));
% 
%     [szy, szx] = size(im);
%     w = ceil(szx * 0.15);
%     h = ceil(szy*0.10);
%     EE = strel('rectangle', [h, w]);
% 
%     cl = imclose(edges, EE);
%     cl = imfill(cl, 'holes');
%     cl = bwareafilt(cl, 1);
% 
%     [y, x] = find(cl);
%     if isempty(x)
%         alignedCrop = im;
%         return;
%     end
% 
%     [~, tl_idx] = min(x +y);
%     TL = [x(tl_idx), y(tl_idx)];
% 
%     [~, tr_idx] = max(x - y);
%     TR = [x(tr_idx), y(tr_idx)];
% 
%     [~, bl_idx] = min(x-y);
%     BL = [x(bl_idx), y(bl_idx)];
%     points = [TL; TR; BL];
% 
%     w = norm(TR - TL);
%     h = norm(BL - TL);
% 
%     fixedPoints = [
%         1, 1;
%         w, 1;
%         1, h
%         ];
% 
%     tform = fitgeotrans(points, fixedPoints, 'affine');
%     R = imref2d([round(h), round(w)]);
%     alignedCrop = imwarp(im, tform, 'OutputView', R);
% 
%     figure;
%     subplot(1, 3, 1), imshow(edges);
%     subplot(1, 3, 2), imshow(cl);
%     hold on;
%     plot(TL(1), TL(2), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
%     plot(TR(1), TR(2), 'go', 'MarkerSize', 8, 'LineWidth', 2);
%     plot(BL(1), BL(2), 'bo', 'MarkerSize', 8, 'LineWidth', 2);
%     hold off;
%     subplot(1, 3, 3), imshow(alignedCrop);
% end

function alignedCrop = alignPlate(im)
    if size(im, 3) == 3
        im = rgb2gray(im);
    end
    bw = imadjust(im);
    bw = imbinarize(bw, "adaptive");
    %figure, imshow(bw), title('adaptive binarize');

    CC = bwconncomp(bw);
    S = regionprops(CC, 'Orientation', 'Area', 'Extent');
    [~, idx] = max([S.Area]);
    if ~isempty(S)
        ang = S(idx).Orientation;
        im = imrotate(im, -ang);
    end
        alignedCrop = im;
    %figure, imshow(alignedCrop);
end
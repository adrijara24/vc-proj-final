
function kept = nms(candidates, scores, iouThresh, containThresh)

    if nargin < 4, containThresh = 0.75; end
    if nargin < 3, iouThresh = 0.45; end

    if isempty(candidates)
        kept = zeros(0, 4);
        return;
    end

    boxes  = double(candidates);
    scores = double(scores);

    % Ordenar por score descendente
    [~, order] = sort(scores, 'descend');
    boxes = boxes(order, :);

    keep = true(size(boxes, 1), 1);

    for i = 1:size(boxes,1)-1
        if ~keep(i)
            continue; 
        end
        for j = i+1:size(boxes,1)
            if ~keep(j)
                continue; 
            end

            [iou, r1, r2] = getOverlap(boxes(i,:), boxes(j,:));

            if iou >= iouThresh || r1 >= containThresh || r2 >= containThresh
                keep(j) = false;  % eliminar la de menor score
            end
        end
    end
    kept = boxes(keep, :);
end


function [iou, r1, r2] = getOverlap(A, B)
    x1 = max(A(1), B(1));
    y1 = max(A(2), B(2));
    x2 = min(A(1)+A(3), B(1)+B(3));
    y2 = min(A(2)+A(4), B(2)+B(4));

    iw = max(0, x2 - x1);
    ih = max(0, y2 - y1);
    intersection = iw * ih;

    aA = A(3) * A(4);
    aB = B(3) * B(4);
    union = aA + aB - intersection;

    iou = intersection / union; 
    r1  = intersection / aA;      % Fracción de A cubierta por B
    r2  = intersection / aB;      % Fracción de B cubierta por A
end


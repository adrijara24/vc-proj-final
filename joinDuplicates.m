function merged = joinDuplicates(candidates, threshold)
    if isempty(candidates)
        merged = zeros(0, 4);
        return;
    end
    if size(candidates, 1) < 2
        merged = candidates;
        return;
    end

    boxes = double(candidates);
    changed = true;

    while changed
        changed = false;
        n = size(boxes, 1);

        for i = 1:n-1
            for j = i+1:n
                [r1, r2] = getOverlap(boxes(i, :), boxes(j, :));
                if  r1 >= threshold && r2 >= threshold
                    boxes(i, :) = mergeROIs([boxes(i, :); boxes(j, :)]);
                    boxes(j, :) = [];
                    changed = true;
                    break;
                end
            end
            if changed
                break;
            end
        end
        merged = boxes;
    end


end

function [r1, r2] = getOverlap(A, B)
    x1 = max(A(1), B(1));
    y1 = max(A(2), B(2));
    x2 = min(A(1) + A(3), B(1) + B(3));
    y2 = min(A(2) + A(4), B(2) + B(4));

    iw = max(0, x2 - x1);
    ih = max(0, y2 - y1);
    in = iw * ih;

    aA = A(3) * A(4);
    aB = B(3) * B(4);

    r1 = in / aA;
    r2 = in / aB;
end

function ROI = mergeROIs(ROIs)
    x1 = min(ROIs(:, 1));
    y1 = min(ROIs(:, 2));
    x2 = max(ROIs(:, 1) + ROIs(:, 3));
    y2 = max(ROIs(:, 2) + ROIs(:, 4));

    ROI = [x1, y1, x2 - x1, y2 - y1];
end
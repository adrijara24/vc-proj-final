
% Intersection over union  
% Checks how overlapped is the negative crop compared with the license
% plate

function iou = compute_iou(boxA, boxB)

    % box = [x y w h]
    
    xA = max(boxA(1), boxB(1));
    yA = max(boxA(2), boxB(2));
    
    xB = min(boxA(1)+boxA(3), boxB(1)+boxB(3));
    yB = min(boxA(2)+boxA(4), boxB(2)+boxB(4));
    
    interW = max(0, xB - xA);
    interH = max(0, yB - yA);
    
    interArea = interW * interH;
    
    areaA = boxA(3) * boxA(4);
    areaB = boxB(3) * boxB(4);
    
    unionArea = areaA + areaB - interArea;
    
    iou = interArea / unionArea;

end

function [plateText, charLabels] = recognize_plate(aligned, blobs)

    plateText = "";
    charLabels = strings(size(blobs,1),1);
    
    for k = 1:size(blobs,1)
    
        bb = blobs(k,:);
    
        charImg = imcrop(aligned, bb);
    
        predictedChar = classify_character(charImg);
    
        charLabels(k) = string(predictedChar);
    
        plateText = plateText + charLabels(k);
    
    end
end
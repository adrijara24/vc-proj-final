
function label = classify_character(img)

    % Load model
    
    persistent svmModel5;
    
    if isempty(svmModel5)
    
        data = load('ocr_model5.mat');
    
        svmModel5 = data.svmModel5;
    
    end

    % Config 

    imgSize = [32 32];
    
    % Extract Features

    features = extract_character_features(img, imgSize);
    
    % Classify

    label = predict(svmModel5, features);
 
end

function label = classify_character(img)

    % Load model
    
    persistent svmModel;
    
    if isempty(svmModel)
    
        data = load('ocr_model2.mat');
    
        svmModel= data.svmModel;
    
    end

    % Config 

    imgSize = [32 32];
    
    % Extract Features

    features = extract_character_features(img, imgSize);
    
    % Classify

    label = predict(svmModel, features);

end
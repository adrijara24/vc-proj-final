
function [prediction, score] = classify_roi(img)

    % Load model
    
    persistent model;
    
    if isempty(model)
    
        data = load('plate_classifier.mat');
    
        model = data.model;
    
    end
    
    % Config
    
    imageSize = [64 128];
    
    % Features
    
    features = extract_plate_features(img, imageSize);
    
    % Prediction
    
    [prediction, scores] = predict(model, features);
    
    % Score
    
    score = scores(2);

end
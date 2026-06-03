clear;
clc;
close all;

%% Configuration

datasetPath = fullfile(pwd, "Datasets/Characters_Dataset");

imds = imageDatastore(datasetPath, ...
    "IncludeSubfolders", true, ...
    "LabelSource", "foldernames");

[imdsTrain, imdsTest] = splitEachLabel(imds, 0.8, "randomized");

imgSize = [32 32];


%% Features Extraction and Model Train

numTrain = numel(imdsTrain.Files);
numTest  = numel(imdsTest.Files);

XTrain = [];
YTrain = imdsTrain.Labels;

XTest  = [];
YTest  = imdsTest.Labels;

imgSize = [32 32];

% -------------------------
% TRAIN FEATURES
% -------------------------
for i = 1:numTrain

    img = readimage(imdsTrain, i);

    feat = extract_character_features(img, imgSize);

    XTrain = [XTrain; feat];

end

% -------------------------
% TEST FEATURES 
% -------------------------
for i = 1:numTest

    img = readimage(imdsTest, i);

    feat = extract_character_features(img, imgSize);

    XTest = [XTest; feat];

end


%% Train model 

svmModel = fitcecoc(XTrain, YTrain);


%% Model Evaluation

YPred = predict(svmModel, XTest);

accuracy = sum(YPred == YTest) / numel(YTest);

fprintf("Accuracy: %.2f%%\n", accuracy * 100);

figure;
confusionchart(YTest, YPred);
title("Confusion Matrix - OCR SVM");

save("ocr_model2.mat", "svmModel", "imgSize");
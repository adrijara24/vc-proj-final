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

XTrain = extract_character_features(imdsTrain, imgSize);
YTrain = imdsTrain.Labels;

XTest  = extract_character_features(imdsTest, imgSize);
YTest  = imdsTest.Labels;

svmModel = fitcecoc(XTrain, YTrain);


%% Model Evaluation

YPred = predict(svmModel, XTest);

accuracy = sum(YPred == YTest) / numel(YTest);

fprintf("Accuracy: %.2f%%\n", accuracy * 100);

figure;
confusionchart(YTest, YPred);
title("Confusion Matrix - OCR SVM");

save("ocr_model.mat", "svmModel", "imgSize");
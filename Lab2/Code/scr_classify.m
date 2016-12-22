%
% This script classify the textures of the dataset. 
% The first loop is used to extract the features of:
%  - the training set (first two images of each class)
%  - the testing set (rest of images of each class)
%
% Afterwards, it converts the training and testing sets to "weka sets",
% uses the training set to train a random forest classifier, and 
% classifies the testing set.
% It returns the confusion matrix (for a perfect classifier, numbers  
% should only be in the diagonal), and the % of correct classification.
clear all;clc;
dataDir = 'P2_class/';
d = dir([dataDir 't*']);
Num=20;
vecTrain=zeros(2*20,Num);% the size was set for this example of 20 different textural images and taking into account that four different orientations are calculated in the computeFeatureVector function
labTrain=zeros(2*20,Num);% the size was set for this example of 20 different textural images and taking into account that four different orientations are calculated in the computeFeatureVector function
vecTest=zeros(4*20,Num); % the size was set for this example of 20 different textural images and taking into account that four different orientations are calculated in the computeFeatureVector function
labTest=zeros(4*20,Num); % the size was set for this example of 20 different textural images and taking into account that four different orientations are calculated in the computeFeatureVector function
%computing features from training and testing sets
for i=1:length(d)
	namedir = d(i).name;
	d1 = dir([dataDir namedir '/*.tif']);
	for j=1:2,
		name = [dataDir namedir '/' d1(j).name];
		A = imread(name);
		vecTrain((i-1)*2+j,:) = computeFeatureVector(A); %training vector
		labTrain((i-1)*2+j) = i; %training labels
	end
	for j=3:length(d1),
		name = [dataDir namedir '/' d1(j).name];
		A = imread(name);
		vecTest((i-1)*4+j-2,:) = computeFeatureVector(A); %testing vector
		labTest((i-1)*4+j-2) = i; %testing labels
	end
end

%converting data to weka
%javaaddpath('/usr/share/java/weka.jar');
javaaddpath('C:/Program Files/Weka-3-7/weka.jar');
import weka.*;

%each feature needs a name
for i=1:size(vecTrain,2)+1,
	f{i}=num2str(i);
end

%each classname saved as a string 
for i=1:size(vecTrain,1),
	for j=1:size(vecTrain,2),
		ctrain{i,j} = vecTrain(i,j);
	end
	ctrain{i,j+1} = [char(labTrain(i)+64) char(labTrain(i)+64)];
end
for i=1:size(vecTest,1),
	for j=1:size(vecTest,2),
		ctest{i,j} = vecTest(i,j);
	end
	ctest{i,j+1} = [char(labTest(i)+64) char(labTest(i)+64)];
end

%conversion functions
wekaTrain = convertWekaDataset('training',f,ctrain);
wekaTest = convertWekaDataset('testing',f,ctest);

%Settings for the classifier
v(1) = java.lang.String('-I');
v(2) = java.lang.String('10');
v(3) = java.lang.String('-K');
v(4) = java.lang.String('0');
v(5) = java.lang.String('-S');
v(6) = java.lang.String('1');
v(7) = java.lang.String('-depth');
v(8) = java.lang.String('0');
prm = cat(1,v(1:end));

%create classifier instance, and perform the evaluation
classifier = javaObject('weka.classifiers.trees.RandomForest');
classifier.setOptions(prm)

%build classifier model
classifier.buildClassifier(wekaTrain);


%testing with final confusion matrix
cm = zeros(wekaTest.numClasses,wekaTest.numClasses);
pmx = zeros(1,wekaTest.numInstances);
predicted = zeros(wekaTest.numInstances,wekaTest.numClasses);
for i=1:wekaTest.numInstances
	instance = wekaTest.instance(i-1);
	predicted = classifier.distributionForInstance(instance)';
	[mx,pmx(i)] = max(predicted);
	cm(instance.classValue+1,pmx(i)) = cm(instance.classValue+1,pmx(i))+1;
end
cm
correct = sum(diag(cm))/sum(cm(:))

% %evaluate classifier
% ev = javaObject('weka.classifiers.Evaluation',wekaTrain);
% cloutputbuf = java.lang.StringBuffer();
% pt = javaObject('weka.classifiers.evaluation.output.prediction.PlainText');
% pt.setBuffer(cloutputbuf);
% pt.setHeader(wekaTrain);
% ev.evaluateModel(classifier,wekaTest,pt);
% cm = ev.confusionMatrix
% correct = sum(diag(cm))/sum(cm(:))


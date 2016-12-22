function example_classifier
clear all;clc;
% change this path if you install the VOC code elsewhere
addpath([cd '/VOCcode']);

% initialize VOC options
VOCinit;
VOCopts.numWords=600; % number of visual words
VOCopts.phowOpts = {'Verbose', 0, 'Sizes', 4, 'Step', 8,'Color','rgb'} ;
VOCopts.quantizer='vq';
VOCopts.numSpatialX = [2 4 8];
VOCopts.numSpatialY = [2 4 8];
% train and test classifier for each class
for i=1:VOCopts.nclasses
    cls=VOCopts.classes{i};
    classifier=build_vocab(VOCopts,cls);            % train classifier
    classifier=train(VOCopts,classifier,cls); 
    test(VOCopts,cls,classifier);                   % test classifier
    [fp,tp,auc]=VOCroc(VOCopts,'comp1',cls,true);   % compute and display ROC
    
    if i<VOCopts.nclasses
        fprintf('press any key to continue with next class...\n');
        pause;
    end
end

 % -------------------------------------------------------------------------
% train classifier
function classifier = build_vocab(VOCopts,cls)
 % -------------------------------------------------------------------------
% load 'train' image set for class
[ids,classifier.gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');
 try
        % try to load the visual vocabulary
        load(sprintf(VOCopts.exfdpath,'visual_vocab'),'vocab');
 catch
        % extract features for each image
        tic;
        fd=single([]);
        for i=1:length(ids)
            % display progress
            if toc>1
                fprintf('%s: build_vocab: %d/%d\n',cls,i,length(ids));
                drawnow;
                tic;
            end
                % compute and save features
                I=imread(sprintf(VOCopts.imgpath,ids{i}));
                [frames, feat] = vl_phow(im2single(I), VOCopts.phowOpts{:}) ;
                feat=single(feat);
                fd=cat(2,fd,feat);
                fd=vl_colsubset(fd,0.95);
                save(sprintf(VOCopts.exfdpath,ids{i}),'feat','frames');
        end
        size(fd)
        %feat = vl_colsubset(fd, 1e4) ;
        feat = single(fd) ;
        vocab = vl_kmeans(feat, VOCopts.numWords, 'verbose', 'algorithm', 'elkan', 'MaxNumIterations', 50) ;
        save(sprintf(VOCopts.exfdpath,'visual_vocab'), 'vocab') ;
 end
 classifier.vocab=vocab;
 if strcmp(VOCopts.quantizer, 'kdtree')
  classifier.kdtree = vl_kdtreebuild(vocab) ;
 end

% ------------------------------------------------------------------------- 
function  classifier=train(VOCopts,classifier,cls)
% -------------------------------------------------------------------------
 try
     load(sprintf(VOCopts.exfdpath,'histograms'),'hists') ; 
 catch
      hists = {} ;
      [ids,~]=textread(sprintf(VOCopts.clsimgsetpath,cls,'train'),'%s %d');
      for i=1:length(ids)
            % display progress
            if toc>1
                fprintf('%s: building the histogram: %d/%d\n',cls,i,length(ids));
                drawnow;
                tic;
            end
         I=imread(sprintf(VOCopts.imgpath,ids{i}));
        hists{i} = getImageDescriptor(VOCopts,classifier,ids{i},I);
      end

      hists = cat(2, hists{:}) ;
      save(sprintf(VOCopts.exfdpath,'histograms'),'hists') ;
 end
 classifier.hist=hists;


% -------------------------------------------------------------------------
function hist = getImageDescriptor(VOCopts,classifier,idsi,im)
% -------------------------------------------------------------------------

im = im2single(im) ;
width = size(im,2) ;
height = size(im,1) ;
try
   load(sprintf(VOCopts.exfdpath,idsi),'feat','frames'); 
catch
    % get PHOW features
    [frames, feat] = vl_phow(im2single(im), VOCopts.phowOpts{:}) ;
    save(sprintf(VOCopts.exfdpath,idsi),'feat','frames');
end

% quantize local descriptors into visual words
switch VOCopts.quantizer
  case 'vq'
    [~, binsa] = min(vl_alldist2(classifier.vocab, single(feat)), [], 1) ;
    hist=zeros(VOCopts.numWords,1);
    for i=1:VOCopts.numWords
        hist(i)=nnz(binsa-i==0);
    end
    hist = single(hist / sum(hist)) ;
  case 'kdtree'
    binsa = double(vl_kdtreequery(classifier.kdtree, classifier.vocab, ...
                                  single(feat), ...
                                  'MaxComparisons', 50)) ;
end



 % -------------------------------------------------------------------------
% run classifier on test images
function test(VOCopts,cls,classifier)
 % -------------------------------------------------------------------------
 
% load test set ('val' for development kit)
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath,cls,VOCopts.testset),'%s %d');

% create results file
fid=fopen(sprintf(VOCopts.clsrespath,'comp1',cls),'w');

% classify each image
tic;
for i=1:length(ids)
    % display progress
    if toc>1
        fprintf('%s: test: %d/%d\n',cls,i,length(ids));
        drawnow;
        tic;
    end
    
    try
        % try to load features
        load(sprintf(VOCopts.testResult,ids{i}),'hist');
    catch
        % compute and save features
        I=imread(sprintf(VOCopts.imgpath,ids{i}));
        hist= getImageDescriptor(VOCopts,classifier,ids{i},I);
        save(sprintf(VOCopts.testResult,ids{i}),'hist');
    end

    % compute confidence of positive classification
    [c]=classify(VOCopts,classifier,hist);
    % write to results file
    fprintf(fid,'%s %f\n',ids{i},c);
end
% close results file
fclose(fid);

function [c] = classify(VOCopts,classifier,hist)

data=double(classifier.hist');
label=single(classifier.gt);
A=prdataset(data,label);
test=prdataset(double(hist'));
w=svc(A,'p',3);
conf=classc(test*w);
c=struct(conf).data(2);


% Nearest nighbour classifier
% d=vl_alldist2(hist,classifier.hist);
% dp=min(d(classifier.gt>0));
% dn=min(d(classifier.gt<0));
% c=dn/(dp+eps);
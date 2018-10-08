clc
clear
close all

%%
imdb = get_imdb() ;

%%
net = load('./imagenet-vgg-verydeep-16.mat') ;%%%%%%%%%choose a model%%%%%%%%%%%%%%%%%%
net = vl_simplenn_tidy(net) ;

%delete the last 2 layers
net.layers = net.layers(1:end-2);
%add new FC layer and softmax
net.layers{end+1} = struct('type', 'conv', ...
						   'weights',{{0.05*randn(1,1,4096,2, 'single'), zeros(1,2,'single')}}, ...
						   'learningRate',[0.001 0.001],... %%%%%%%%%%%%%[filter bias]learningRate should be set small
						   'stride', 1, ...
						   'pad', 0) ;
net.layers{end+1} = struct('type', 'softmaxloss') ;

%%
net.meta.normalization.averageImage =imdb.meta.imagemean ;
net.meta.inputSize = [224 224 3] ;
% net.meta.trainOpts.learningRate = [0.0005*ones(1,5) 0.0001*ones(1,10) 0.00005*ones(1,20)] ;
net.meta.trainOpts.learningRate = [0.0005 0.0005 0.0001 0.0001 0.0001 0.0001] ;
net.meta.trainOpts.weightDecay = 0.0001 ;  %%%%???
net.meta.trainOpts.batchSize = 16 ;
net.meta.trainOpts.numEpochs = numel(net.meta.trainOpts.learningRate) ;
net.meta.classes = {'cat' 'dog'} ;


net = vl_simplenn_tidy(net) ;


opts.train.gpus= 1 ;
opts.whitenData = 1 ;
opts.contrastNormalization = 1 ;
opts.train.expDir = fullfile(vl_rootnn, 'data', 'mine') ;
opts.expDir = fullfile(vl_rootnn, 'data', 'mine') ;

%%
use_gpu = opts.train.gpus ;
[net, info] = cnn_train(net, imdb, @(imdb, batch)getBatch(imdb, batch), ...
 'expDir', opts.train.expDir, ...
  net.meta.trainOpts, ...
 'val', find(imdb.images.set == 2), ...
  opts.train) ;

save('fineTuningNet', 'net') ;

function  [images, labels] = getBatch(imdb, batch)
images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(batch) ;
images = single(gpuArray(images)) ;
end
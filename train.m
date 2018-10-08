
clc
clear
close all


if ~exist(opts.imdbPath,'file')

else
    imdb=get_imdb(datadir);
    mkdir(opts.expDir) ;
    save(opts.imdbPath, '-struct', 'imdb') ;
end



net.meta.normalization.averageImage =imdb.images.data_mean ;
opts.train.gpus=1;



pretrainedPath = './imagenet-vgg-verydeep-16.mat'
if ~exist(pretrainedPath)
    fprintf('downloading model...') ;
    websave('imagenet-vgg-verydeep-16.mat', ...
        'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-16.mat') ;
    fprintf('done') ;
end
 
net = vgg16_(pretrainedPath)   

[net, info] = cnn_train(net, imdb, getBatch(opts), ...
  'expDir', opts.expDir, ...
  net.meta.trainOpts, ...
  opts.train, ...
  'val', find(imdb.images.set == 3)) ;

function net = vgg16_(pretrainedPath)
net = [];
old_net = load(pretrainedPath);

load(opts.initNetPath);
net.layers=net.layers(1:end-2);
net.layers{end+1} = struct('type', 'conv', ...
                           'weights', {{0.05_randn(1, 1, OLD, 2, 'single'), zeros(1, 2, 'single')}}, ...
                           'learningRate', .1_lr, ...
                           'stride', 1, ...
                           'pad', 0) ;

net.layers{end+1} = struct('type', 'softmaxloss') ;
end

function  [images, labels] = getBatch(imdb, batch)
images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(1,batch) ;
end

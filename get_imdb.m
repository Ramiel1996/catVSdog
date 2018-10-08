function imdb = get_imdb(varargin)

datadir = './train';

%sets = {'train', 'val'} ;
numImages = length(dir([datadir '/*.jpg'])) ;
numSamples = [numImages*0.7, numImages*0.3] ; % train : val = 9 : 1
filename = dir([datadir '/*.jpg']) ;
filename = filename([randperm(2000)]) ;

%% prepare memory
totalSamples = numImages ;  
images = zeros(224, 224, 3, totalSamples) ;         %%%*1
labels = zeros(totalSamples, 1) ;
set = ones(totalSamples, 1) ;
 
%% read images
sample = 1 ;
for s = 1:2  % Iterate sets
   for i = 1:numSamples(s)  % Iterate samples
      % Read image
      im = imread(filename(i).name) ;
      im = imresize(im, [224,224]) ;                %%%*1  
      % Store
      images(:,:,:,sample) = single(im) ;
      name = filename(i).name(1:3) ;
      if strcmp(name,'cat')
          labels(sample) = 1 ;       %cat=1
      else 
          labels(sample) = 2 ;       %dog=0
      end
      set(sample) = s ;   
      sample = sample + 1 ;
      
   end
end


%% Show some example images
figure ;
montage(uint8(images(:,:,:,randperm(totalSamples, 100)))) ;
title('Example images') ;

% Remove mean over whole dataset    ???
images = bsxfun(@minus, images, mean(images, 4)) ;

% Store results in the imdb struct
imdb.images.data = images ;
imdb.images.labels = labels ;
imdb.images.set = set ;

%%          
imdb.meta.imagemean = mean(images, 4) ;
imdb.meta.sets = {'train', 'val'} ;
imdb.meta.classes = {'cat' ; 'dog'};
%% save
% save('dataset.mat', 'imdb','-v7.3') ; %太大了，不建议写入硬盘，意义不大

clc
clear
close all

run C:\Matlablib\MatConvNet\matlab\vl_setupnn ;

%加载预训练模型，更新格式
load('.\fineTuningNet.mat') ;
net = vl_simplenn_tidy(net) ;
net.layers{end}.type = 'softmax' ;
%预处理
im = imread('.\train\cat.178.jpg') ;
im_ = imresize(im, net.meta.inputSize(1:2)) ;
im_ = single(im_) ; 
% im_ = im_ - net.meta.normalization.averageImage ;

%将图片输入模型
res = vl_simplenn(net, im_) ;

%输出
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;

%可视化
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
   net.meta.classes{best}, best, bestScore)) ;
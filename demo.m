clc
clear
close all

run C:\Matlablib\MatConvNet\matlab\vl_setupnn ;

%����Ԥѵ��ģ�ͣ����¸�ʽ
load('.\fineTuningNet.mat') ;
net = vl_simplenn_tidy(net) ;
net.layers{end}.type = 'softmax' ;
%Ԥ����
im = imread('.\train\cat.178.jpg') ;
im_ = imresize(im, net.meta.inputSize(1:2)) ;
im_ = single(im_) ; 
% im_ = im_ - net.meta.normalization.averageImage ;

%��ͼƬ����ģ��
res = vl_simplenn(net, im_) ;

%���
scores = squeeze(gather(res(end).x)) ;
[bestScore, best] = max(scores) ;

%���ӻ�
figure(1) ; clf ; imagesc(im) ;
title(sprintf('%s (%d), score %.3f',...
   net.meta.classes{best}, best, bestScore)) ;
% script for testing the implemented region growing algorithm
clear all;
clc;
[seg,num_of_regions]=Region_Growing_seg('color.tif',50);
%[seg,num_of_regions]=Region_Growing_seg('coins.png',50);
%[seg,num_of_regions]=Region_Growing_seg('gantrycrane.png',100);
%[seg,num_of_regions]=Region_Growing_seg('woman.tif',50);
display(num_of_regions);
imtool(seg);

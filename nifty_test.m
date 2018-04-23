clear;close all


inputpath='/media/nazib/Store/PhD_Project/10%/';
outputpath='/media/nazib/Store/PhD_Project/10%/';
%For AIR data deformation file_pfx should be without extension
%and files should be *.img extension files

file_pfx='_deform.nii.gz';
files=dir(fullfile(inputpath,'*.nii.gz'));
src='.nii.gz';


for i=1:length(files)
    str=files(i).name;
    idx=strfind(str,src);
    name=str(1,1:idx-1);
    inputfile=fullfile(inputpath,files(i).name);
    outputfile=fullfile(outputpath,[name file_pfx]);
    ApplyDeformation(inputfile,outputfile);
end















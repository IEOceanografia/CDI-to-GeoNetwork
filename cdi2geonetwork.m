% This Matlab script is a simple loop to apply the XSL Transformation
% (CDI-to-GeoNetwork.xsl) to CDI files prevously stored in a folder of
% your system.
%
% Be sure that the folder only contains your XML files to be transformed.
%
% We only transform "unrestricted" access to data.
%
% Author: Instituto Español de Oceanografia
%         Pablo Otero (pablo.otero@md.ieo.es)
% 20-Jul-2016 

clear all; close all;

% Choose name of the directory that will be created in the current dir
output_dir_name='CDI2GN';

% ----- (END USER OPTIONS)

directoryname = uigetdir('', 'Pick a Directory with your CDI files');

currentdir=pwd;

newSubFolder = fullfile(currentdir,output_dir_name);
if ~exist(newSubFolder, 'dir')
  mkdir(newSubFolder);
end

cd(directoryname);
[status,list]=system('dir /s/b/o:gn *.xml');
cd(currentdir);

listfiles=strsplit(list);

for count=1:length(listfiles)-1   %last line is an empty character

    inputfile=listfiles{count};
    
    [pathstr,name,ext] = fileparts(inputfile);
      
    outputfile=fullfile(newSubFolder,name,ext);
    
    fid  = fopen(inputfile,'r');
    f=fread(fid,'*char')';
    fclose(fid);

    % Transform to insert in GeoNetwork only data with unrestricted access
    if(~isempty(strfind(f,'unrestricted')))
       disp(['Transforming file: ',name]);  
       xslt(inputfile,'CDI-to-GeoNetwork.xsl',outputfile); 
    end
    
end
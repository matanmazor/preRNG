function [protocol_sum] = preRNG(protocol_folder, subj_num, save_seeds)
%Sets the random number generator seed according to the study protocol.
%Params:
%    protocol_folder:    Compressed folder, including all materials to be
%                        preRNGistered.
%    subj_num:           Serial number of current subject.
%    'save_seeds':       If specified, save a csv file with subj_num
%                        subject sums.
%Returns:
%    Protocol sum. This should be identical across all subjects.

%%add lib and its subdirectories to path
addpath(genpath(fileparts(which('preRNG'))));

%%extract protocol sum
Opt = struct('Method', 'SHA-256', 'Input', 'file');
protocol_sum = DataHash(protocol_folder,Opt);

%in case user specified subject number
if nargin>1
    %obtain sum of the concatenation of protocol sum with the subject
    %number
    Opt.Input = 'bin';
    subject_sum = DataHash([protocol_sum num2str(subj_num)],Opt);
else
    subject_sum = protocol_sum;
end

%%translate to a vector of numeric values (32 bits each)
subj_vec = [];
for i = 0:length(subject_sum)/8-1
    cur_substring = subject_sum(i*8+1:(i+1)*8);
    subj_vec = [subj_vec; hex2dec(cur_substring)];
end

%use subj_vec as the subject sum
subject_sum = subj_vec;

%%use subj_sum as seed for the pseudorandom number generator
init_by_array(subject_sum);

%%if save_seeds, iterate over 1:subj_num and create a csv file with the
%%subject sums.
if nargin>2 && save_seeds
    Opt.Input = 'bin';
    %save the seeds.csv file next to the protocol folder
    fid = fopen(fullfile(fileparts(protocol_folder),'seeds.csv'),'w');
    fprintf(fid,'subject number, seed');
    for s=1:subj_num
        fprintf(fid, '\n')
        s_sum = DataHash([protocol_sum num2str(s)],Opt);
        fprintf(fid,'%d, %.100g',s,hex2dec(s_sum))
    end
    fclose(fid);
end
  
end
% This version is used to extract data from data file generated by WIPL-D
% software. It is applied for one variable only.

clc
clear


% file_path = 'E:\WPT_preparing_papers\Smooth3coilSys\wires';

fid=fopen('..\..\NAIST_Works\DynamicWPT\test1\TX_spiral_RX_3solenoid.ad1'); 


numwire = 2; % number of the wires whose currents need to be extracted
numconf = 19; % number of configurations (loop)
var_chk = 'phiRX'; % variable changed in WIPL-D
cnt = 1;

All_vector = [];
All_temp = [];
Z_vector = [];
Z_temp = [];
var_arr = [];

filename_save = 'testdata.xlsx';
if isfile(filename_save)
    delete testdata.xlsx
end


if fseek(fid, 1, 'bof') == -1 % empty file
   disp("file is empty");
else
   a = 1;
end

while a == 1
    A = fgetl(fid); % read one line in the file
    A_element = strsplit(A,' '); % split long string into elements
    if strcmp(A_element(2), var_chk)
        var_arr = [var_arr; str2double(A_element(3))];
        fgetl(fid); % ignore next line
        for wcnt = 1:(numwire*numwire)
            Parameters = fgetl(fid); % read the line
            Para_elements = strsplit(Parameters,' '); % split long string into elements
            All_temp = [All_temp; str2double(Para_elements)]; % write data
            Z_temp = [Z_temp; str2double(Para_elements(7:8))]; % write data
        end
        cnt = cnt + 1;
    end
    All_vector = [All_vector All_temp]; % store data into large matrix
    All_temp = [];
    Z_vector = [Z_vector Z_temp]; % store data into large matrix
    Z_temp = [];
    if cnt > numconf
        break
    end
end

All_vector;

% var_arr

for n = 1:numconf
    Q1(n) = Z_vector(1,2*n)/Z_vector(1,2*n-1);
    Q2(n) = Z_vector(4,2*n)/Z_vector(4,2*n-1);
    OmegaM(n) = Z_vector(2,2*n);
    k(n) = abs(Z_vector(2,2*n)/sqrt(Z_vector(1,2*n)*Z_vector(4,2*n)));
    kQ(n) = k(n)*sqrt(Q1(n)*Q2(n));
    eta_max(n) = 1 - 2/(1+sqrt(1+kQ(n)^2));
end

% Z_vector(1,2)

f=85*10^3; % hertz
Q1 = Q1(:);
Q2 = Q2(:);
OmegaM = abs(OmegaM(:));
M = OmegaM/(2*pi*f)*10^6; % micro henry
k = k(:);
kQ = kQ(:);
eta_max = eta_max(:)*100;

calculation_extract = [var_arr Q1 Q2 OmegaM M k kQ eta_max]

% name_var{1,1} = 'phi'; 
% name_var{1,2} = 'Q1'; 
% name_var{1,3} = 'Q2'; 
% name_var{1,4} = 'k'; 
% name_var{1,5} = 'kQ'; 
% name_var{1,6} = 'eta_max';


name_var = {'phi', 'Q1', 'Q2', 'OmegaM', 'M', 'k', 'kQ', 'eta_max'};

% Z_RX_TXs = Z_vector(111:120,:)
% size(Z_RX_TXs)
% Z_vector(121,:)

% for n = 1:numconf
%     Q(n) = round(Z_vector(121,2*n)/Z_vector(121,2*n-1),5);
% end
% Q
% n=1:numconf;
% coupling = (Z_vector(:,2*n-1).^2+Z_vector(:,2*n).^2).^0.5

writematrix(All_vector,filename_save, 'Sheet',1,'Range','A1');
writematrix(Z_vector,filename_save, 'Sheet',1,'Range','A10');

writecell(name_var,filename_save, 'Sheet',1,'Range','A20');
writematrix(calculation_extract,filename_save, 'Sheet',1,'Range','A21');

% writematrix(Q,filename_save, 'Sheet',1,'Range','A125');

fclose(fid);
fclose('all');
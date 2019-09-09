% This code tests if it can recover manually corrupts noaa data

%% load data
addpath PROPACK/tensor_toolbox-master
addpath ..
clear variables;
load('../Data/NOAA_6M_pollute_sim.mat'); % 0.5 Relatve error

Obs2 = data_pollute;

% construct observation matrix into tensor fromat
nl = size(Obs2,1);        % #links
nm = 24 ;         % #hours in a day
nd = size(Obs2,2)/nm;     % #days

% % index for missing entries
Sigma_bar = isnan(Obs2);
Sigma_bar = tensor(Sigma_bar,[nl nm nd]);

% fold tensor
D = data_pollute;
D(isnan(D)) = 0;
D = tensor(D,[nl nm nd]);
Size = numel(double(D));
outlier_dim = 2;

% percent. missing entries
missing_rate = sum(sum(isnan(Obs2))) / Size;

%% plot obs
figure();
for i = 1: size(Obs2, 1) 
    plot(noaa(i,:));
    hold on
end

% ylim([-20 70])
title("all observations");
xlabel('hour count')
ylabel('temperature (C)')

%% RPCA21
% define optimazation parameter
base = size(Obs2,2);
lambda = 1/sqrt(log(base)) * 0.7 ;
lambda1 = 1/sqrt(base);
fprintf('lambda=%1.4f\n',lambda);

%rpca
tic;
[Lhat,Shat,iter] = inexact_alm_rmc21(D,Sigma_bar, lambda, 1e-7, 1000, outlier_dim);
time = toc;

Lhat_mat = double(tenmat(Lhat,1));
Shat_mat = double(tenmat(Shat,1));

%% examine results: relative error
rss = norm((Lhat_mat - noaa))/ norm(noaa);

% comapre: original relative error
% fill missing data by linear interpolation
missing_index = isnan(data_pollute);
data_pollute_linear = fillmissing(data_pollute, 'linear');
rss_o = norm(data_pollute_linear - noaa,2)/ norm(noaa,2);

% imagine all missing data are correctly imputed to be the same as noaa
diff = data_pollute - noaa;
diff(isnan(diff)) = 0;
rss_o2 = norm(diff,2)/ norm(noaa,2);

disp(['residual error after recovery: ', num2str(rss)])
disp(['residual error for raw data, linear interpolate: ', num2str(rss_o)])
disp(['residual error for raw data, exclude missing: ', num2str(rss_o2)])

%% try: add back small noises
makeup = Shat_mat;
makeup(abs(makeup) >= 3) = 0;
Lhat_mat2 = Lhat_mat + makeup;
rss2 = norm(Lhat_mat2 - noaa)/ norm(noaa);
disp(['residual error after recovery, not accounting small noise: ', num2str(rss2)])
%% pearson corelation%
Lhat_mat = double(tenmat(Lhat,1));
Shat_mat = double(tenmat(Shat,1));

R_recover = mean(row_corrcoef(Lhat_mat, noaa))
R_raw = mean(row_corrcoef(data_pollute, noaa))


%% plot all data in subplots 
% convert to marix for plot

figure()
for i = 1: size(Lhat_mat, 1)
   subplot(3,1,3)
   plot(Shat_mat(i, :))
   hold on
   subplot(3,1,2)
   plot(Lhat_mat(i, :))
   hold on
   subplot(3,1,1)
   plot(noaa(i, :))
   hold on
end
subplot(3,1,3)
title("all sensors over 6 month: observation");
xlabel('hour count')
ylabel('temperature (C)')
hold off

subplot(3,1,2)
% plot(NOAA, 'k','LineWidth',2);
title("all sensors over 6 month: recovered");
xlabel('hour count')
ylabel('temperature (C)')
hold off 

subplot(3,1,1)
title("all sensors over 6 month: actual");
xlabel('hour count')
ylabel('temperature (C)')

hold off
%% funciton
function R = row_corrcoef(mat1, mat2)
nl = size(mat1, 1);
R = zeros(nl,1);
for i = 1: nl  
    index = ~isnan(mat1(i,:)) & ~isnan(mat2(i,:));
    coef = corrcoef(mat1(i,index), mat2(i,index));
    R(i) = coef(2,1);
end
end


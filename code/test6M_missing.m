% This code tests 6 month aot temperature data recovery
%% load data
addpath PROPACK/tensor_toolbox-master
addpath ..

clear variables;
load('../Data/AoT6M_277.mat')
load('../Data/Noaa_6M.mat');

% construct observation matrix into tensor fromat
nl = size(Obs2,1);        % #links
nm = 24 ;         % #hours in a day
nd = size(Obs2,2)/nm;     % #days

% 
% % index for missing entries
Sigma_bar = isnan(Obs2);
Sigma_bar = tensor(Sigma_bar,[nl nm nd]);

% fold tensor
D = Obs2;
D(isnan(D)) = 0;
D = tensor(D,[nl nm nd]);
Size = numel(double(D));
outlier_dim = 2;

% percent. missing entries
missing_rate = sum(sum(isnan(Obs2))) / Size;

% examine missing fibers 
% temp = sum(double(Sigma_bar), 2);
% sum(sum(temp > 12))
%% plot obs
figure();
for i = 1: size(Obs2, 1) 
    plot(Obs2(i,:));
    hold on
end

% ylim([-20 70])
title("all observations");
xlabel('hour count')
ylabel('temperature (C)')

%% RPCA21
% define optimazation parameter
lambda = 1/sqrt(log(4392))*0.4 ;
lambda1 = 1/sqrt(4392);
fprintf('lambda=%1.4f\n',lambda);

%rpca
tic;
[Lhat,Shat,iter] = inexact_alm_rmc21(D,Sigma_bar, lambda, 1e-7, 1000, outlier_dim);
time = toc;

%% examing results
% spar of outlier sonsor*day
tol = 3;
ind = any(abs(double(Shat)) > tol, 2);
totle_fib = numel(ind);
Spar_fiber = sum(sum(sum(ind)))/totle_fib;  % percentage of non-zero elements in S
disp(['Threshhold:', num2str(tol), ',   Estimated fiber-wise Sparcity: ', num2str(Spar_fiber)])


%% 0 to nan for estimation
col_E = tenmat(Shat,outlier_dim);
col_E = any(double(col_E) ~= 0);  %find index all nonzero fibers of outlier
col_X = tenmat(Lhat,outlier_dim);
col_X = all(double(col_X) ==0);

Shat_obs = tenmat(Shat,outlier_dim);
Lhat_obs = tenmat(Lhat,outlier_dim);
Lhat_obs(:,col_X) = nan;
Shat_obs(:,~col_E) = nan;

Lhat = tensor(Lhat_obs);
Shat = tensor(Shat_obs);


%% plot all data in subplots 
% convert to marix for plot
Lhat_mat = double(tenmat(Lhat,1));
Shat_mat = double(tenmat(Shat,1));

figure()
for i = 1: size(Lhat_mat, 1)
   subplot(3,1,3)
   plot(Shat_mat(i, :))
   hold on
   subplot(3,1,2)
   plot(Lhat_mat(i, :))
   hold on
   subplot(3,1,1)
   plot(Obs2(i, :))
   hold on
end
subplot(3,1,3)
title("all sensors over 6 month: noises");
xlabel('hour count')
ylabel('temperature (C)')
hold off

subplot(3,1,2)
plot(NOAA, 'k','LineWidth',2);
title("all sensors over 6 month: predicted");
xlabel('hour count')
ylabel('temperature (C)')
hold off 

subplot(3,1,1)
title("all sensors over 6 month: observation");
xlabel('hour count')
ylabel('temperature (C)')

hold off

%% examine missing data
missing_sensor = sum(isnan(Obs2),2) > 400;
missing_index = find(missing_sensor);
total = length(missing_index);

figure()
for i = 12:14
    ind = missing_index(i);
    subplot(3,1,1)
    plot(Obs2(ind,:));
%     ylim([-15 50]);
    hold on
    subplot(3,1,2)
    plot(Lhat_mat(ind, :));
    hold on
    subplot(3,1,3)
    plot(Shat_mat(ind, :));
    hold on
end

subplot(3,1,3)
title("missing sensors over 6 month: noises");
xlabel('hour count')
ylabel('temperature (C)')

subplot(3,1,2)
plot(NOAA, 'k','LineWidth',2);
title("missing sensors over 6 month: predicted");
xlabel('hour count')
ylabel('temperature (C)')
hold off 

subplot(3,1,1)
title("missing sensors over 6 month: observation");
xlabel('hour count')
ylabel('temperature (C)')
hold off


%% l21 norm outlier examine

% convert to marix for plot
Lhat_mat = double(tenmat(Lhat,1));
Shat_mat = double(tenmat(Shat,1));

sensor_ano = any(abs(Shat_mat) > 15, 2);
ano_index = find(sensor_ano);

figure()
for i = 1:10
   subplot(3,1,3)
   plot(Shat_mat(ano_index(i), :),'DisplayName',num2str(i))
   hold on
   subplot(3,1,2)
   plot(Lhat_mat(ano_index(i), :))
   hold on
   subplot(3,1,1)
   plot(Obs2(ano_index(i), :))
   hold on
end
subplot(3,1,3)
title("selected bad sensors over 6 month: noises");
xlabel('hour count')
ylabel('temperature (C)')
legend show

subplot(3,1,2)
plot(NOAA, 'k','LineWidth',1.5);
title("selected bad sensors over 6 month: recovered");
xlabel('hour count')
ylabel('temperature (C)')
hold off 

subplot(3,1,1)
title("selected bad sensors over 6 month: observation");
xlabel('hour count')
ylabel('temperature (C)')
hold off



%% read data file 
full_excel_sheet = xlsread('2012_2013_Solar_home_electricity data_v44.xlsx');
%% data preprocessing
clc
% full_excel_sheet = csvread('2012_2013_Solar_home_electricity data_v44.csv');
str1= ['Dataset from Ausgrid',newline,'Contains all the data (solar+load)'];
% save full_solar_data.mat
%%
load full_solar_data.mat
disp(str1)
%%
solar_data_init = full_excel_sheet(3:3:size(full_excel_sheet,1),:);
%%
sdata2 = solar_data_init(:,2:2:48);
sdata1 = solar_data_init(:,1:2:48);
%%
solar_data = [sdata1 ; sdata2];
size(solar_data);
str2 = ['Solar_data contains solar irradiance data in kW for ',newline,num2str(size(solar_data,1)),' days'];
% save solar_data.mat solar_data str2
%% SIMULATION PART
load solar_data.mat
disp(str2)
%%
load month_data.mat
%%
% Load scale to 1 MW factor
MW_scale = 1;
day_no = 15; % day of the month
% solar scale to 0.8 MW
Sol_scale = (0.7/max(solar_data((day_no),:)))*MW_scale;
micro_grid_index = 4;
% load array for day_no for micro_grid_index
Lt_day =MW_scale*monthly_norm_data.Jul((day_no)*24:(day_no+1)*24-1,micro_grid_index);
% solar array for day_no (days are the rows in solar_data array)
solar_day = Sol_scale*solar_data((day_no),:);
Net_load = Lt_day-solar_day';
figure(600)
% hold on
plot(Lt_day)
title('Load')
% hold on
figure(601)
plot(solar_day)
title('Solar')
figure(609+day_no)
% hold on
plot(Net_load)
title('Net Load: Load-Solar')
% legend
if any(Net_load <= 0) == 1
    disp('Net load has negative vale')
    disp('Solar generation > Load demand')
end
%%
%     time_init = 13;
%     time_fin = 19;
%     Lt_day2 = Lt_day(time_init:time_fin);
%     solar_day2 = solar_day(time_init:time_fin)
%     Net_load2 = Lt_day2-solar_day2';
%     plot(Net_load2)
%     %% check 
%     Net_load_dif = diff(Net_load);
%     [max_der, hour_max] = max(Net_load_dif)
%     % max ramp occurs between hour_max+1 and hour_max
%     % Net_load(hour_max+1)- Net_load(hour_max)
%%
% E_cap = 0.52;
% P_max = 0.52;
P_max = 0.8;
E_cap = 0.8;
DoD = 0.9;
alpha = (1-DoD)/2;
E_init = alpha*E_cap;
% E_init = 0
dif_mat = diag(-1*ones(1,size(Net_load,1)-3),-3) + eye(size(Net_load,1));
%% check ramp specific times (i.e. between time_init and time_fin)
%     time_init = 13;
%     time_fin = 19;
%     dif_mat(1:time_init,:) = 0;
%     dif_mat(time_fin:end,:) = 0;
%% 24 is HARD CODED change it if change the time period (from 1 pm to 7pm)
tic
cvx_begin % quiet
cvx_solver gurobi
% cvx_solver_settings('TIMELIMIT',10); 
variable bat(24)
% variable epsilon
variable tot_load(24)
% minimize epsilon
minimize max(abs(dif_mat*tot_load))
subject to 
    % const. #2
    tot_load(:) == Net_load(:)-bat(:) 
    % const #3
%     dif_mat*tot_load <= epsilon
%     battery standard constraints
    % const. #4
    bat(1) == -E_init;
    % const. #5
    -P_max <= bat(:) <= P_max
    % const. #6
    alpha*E_cap <= cumsum(-bat(:)) <= (1-alpha)*E_cap
    % const. #7
     tot_load(:) >= 0;
cvx_end
if cvx_optval == Inf
    disp('Infeasible')
end
toc

%%
figure(810+randi(400,1))
% hold on
plot(Net_load)
title(['Net Load: Load-Solar-MESS',newline,'E_{cap}= ',num2str(E_cap),...
    ' MWh P_{max}= ',num2str(P_max),' MW'])
% ,newline,'Start time: '...
%     ,num2str(time_init),' End time: ',num2str(time_fin)])
hold on
xlabel('Hours')
ylabel('MW')
plot(tot_load)
legend('NO MESS','MESS','Location','Northwest')
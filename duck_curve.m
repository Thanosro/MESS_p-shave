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
%%
load solar_data.mat
disp(str2)
%%
load month_data.mat
%%
% Load scale to 1 MW factor
MW_scale = 1;
day_no = 11; % day of the month
% solar scale to 0.8 MW
Sol_scale = (0.6/max(solar_data((day_no),:)))*MW_scale;
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
cvx_begin quiet
cvx_solver gurobi
% cvx_solver_settings('TIMELIMIT',10); 
variable b(Time_slots)

minimize epsilon
subject to 
    % const. #2
%     net_load(:) == b_dc(:) - b_ch(:);
    % const. #3
    b(1) == -E_init;
    -P_max <= b(:) <= P_max
%     alpha*E_cap <= E_init + cumtrapz(b_dc(Time_slots) - b_ch(Time_slots)) <= (1-a)*E_cap;
    alpha*E_cap <= cumsum(-b(:)) <= (1-alpha)*E_cap
%
     Lt_day(:)-b(:) >= 0;
%    Lt_day(:)-b(:) <= L_thres_ar(:)
cvx_end
if cvx_optval == Inf
    disp('Infeasible')
end
toc
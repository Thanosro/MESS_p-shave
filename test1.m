addpath(genpath('C:\Users\Thanos\Documents\DeepSolar'))
cd C:\Users\Thanos\Documents\DeepSolar\BigData\sims
rmpath('C:\Users\Thanos\Documents\DeepSolar\Optimal_flow\cvx\lib\narginchk_')
%% Laptop
addpath(genpath('C:\Users\thano\OneDrive\Documents\USC'))
cd C:\Users\thano\OneDrive\Documents\USC\DeepSolar\BigData\MESS_p-shave
rmpath('C:\Users\thano\OneDrive\Documents\USC\DeepSolar\OPF\cvx\lib\narginchk_')
%% load the array 
clc; clear all;
% loads as struct
L_t_str = load('Pecan_load.mat');
% convert to array 
L_t_ar = L_t_str.L_t_ar;
%%
% mod(length(L_t_ar),96)
L_t_ar = L_t_ar(1:(fix(length(L_t_ar)/96)*96));
% L_t_ar = L_t_ar(1:end-2);
% length(L_t_ar)
% disp(['Mod after removal ', num2str(mod(length(L_t_ar),96))])
%% indices of Nan elements in the Dataset
nan_ind1 = find(isnan(L_t_ar) == 1);
%% closest indices that are divided by 96 
ind1 = fix(nan_ind1(1)/96)*96 ;  
ind2 =  fix((nan_ind1(end)+96)/96)*96 ;
%% remove Nan elements from Dataset &
Lt_ar1 = L_t_ar(1:ind1);
Lt_ar2 = L_t_ar(ind2+1:end);
L_t_ar = [Lt_ar1; Lt_ar2];
%% 

%%
% for i_plot = 1:10
    % random integer to denote the day
    cl_num = randi(length(L_t_ar)/96);
%%
clc;
time_step = 1 ; % take average of 2 hours
assert(time_step >= 1 && mod(96,time_step) == 0,'Time step not divided by the number of time samples')
avg_cons = mean(reshape(Lt_day,4*time_step,[]));
avg_cons_rep = repelem(avg_cons,4*time_step);
   %%
%    close all;
   Lt_plot = L_t_ar(96*cl_num:96*(cl_num+1)-1);
   % find the mean of the 10 max elements from the L_t_plot array
   max(Lt_plot);
   ceil(max(Lt_plot));
   scaling_factor = 800/ceil(max(Lt_plot));
   figure(131)
   Lt_day = scaling_factor*Lt_plot;
   hold on
%    plot(avg_cons_rep,'r')
   hold on
   plot(Lt_day,'b')
   hold on;
   % plot straight line to denote the peak consumption
   plot(500*ones(1,length(Lt_plot)))

   set(gca, 'yGrid','on')
%    title('Micro-grid daily consumption')
   ylabel('Consumption (kW)')
   xlim([0 96])
   xticks(0:12:96)
   xticklabels(0:3:24)
   xlabel('Time (hours)')
% end
%% define the peak array 
figure(132)
peak_ar = Lt_day-500*ones(length(Lt_plot),1);
peak_ar(peak_ar < 0) = 0;
plot(peak_ar)
set(gca, 'yGrid','on')
title('Peak consumption')
ylabel('Consumption (kW)')
xlim([0 96])
xticks(0:12:96)
xticklabels(0:3:24)
xlabel('Time (hours)')
%% define shaved array 
figure(133)
shaved_ar = Lt_day;
shaved_ar(shaved_ar > 500) = 500;
plot(shaved_ar)
set(gca, 'yGrid','on')
title('Shaved consumption')
ylabel('Consumption (kW)')
xlim([0 96])
ylim([0 800])
xticks(0:12:96)
xticklabels(0:3:24)
xlabel('Time (hours)')
%% compute area under curve
total_energy_demand = trapz(Lt_day)
peak_energy = trapz(peak_ar)
shaved_energy = trapz(shaved_ar)
%% compute cumulative area under curve
total_energy_demand = cumtrapz(Lt_day);
peak_energy = cumtrapz(peak_ar);
shaved_energy = cumtrapz(shaved_ar);
%%
peak_energy + shaved_energy
%%
figure(134)
plot(shaved_energy)
hold on
plot(total_energy_demand)
xlim([0 96])
xticks(0:12:96)
xticklabels(0:3:24)
xlabel('Time (hours)')
%%
close all;
%%
mean(L_t_ar)
    %%  draft codes
    %
    isinteger(length(L_t_ar)/96)
    length(find(isnan(L_t_ar) == 1))
    %%
    length(L_t_ar)/96
    mod(length(L_t_ar),96)
    % nan_ind1(1)/96
    %%
    mod_init = mod(nan_ind1(1),96);
    mod_fin = mod(nan_ind1(end),96);
    if mod(nan_ind1(1),96) == 0
    disp("1st index div by 0")
    else
    disp(['Mod init is ' ,num2str(mod_init)])
    mod_ar_init = (nan_ind1(1)-mod_init):(nan_ind1(1));
    end
    if mod(nan_ind1(end),96) == 0
    disp("Last index div by 0")
    else
    disp(['Mod fin is ' ,num2str(mod_fin)])
    mod_ar_fin = (nan_ind1(end)+1):nan_ind1(end)+mod_fin;
    end
    %%
    nan_ind = [nan_ind1; mod_ar_init'; mod_ar_fin'];
    L_t_ar(find(isnan(L_t_ar) == 1)) = [];
    assert(sum(isnan(L_t_ar)),'Contains Nan Values')
    %%
    isinteger(length(L_t_ar)/96)
    %% plot clusters of 96 data poits (1 day)
    cl_num = 40;
    plot(L_t_ar(96*cl_num:96*(cl_num+1)-1))

    %%
    disp(['Lenght Lt_ar1 = ',num2str(length(Lt_ar1))])
    mod(length(Lt_ar1),96) == 0
    %%
    disp(['Lenght Lt_ar2 = ',num2str(length(Lt_ar2))])
    mod(length(Lt_ar2),96) == 0
    %%
    mod(length(L_t_ar),96) == 0
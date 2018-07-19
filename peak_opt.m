addpath(genpath('C:\Users\Thanos\Documents\DeepSolar'))
cd C:\Users\Thanos\Documents\DeepSolar\BigData\sims\MESS_p-shave
rmpath('C:\Users\Thanos\Documents\DeepSolar\Optimal_flow\cvx\lib\narginchk_')
%% Laptop
addpath(genpath('C:\Users\thano\OneDrive\Documents\USC'))
cd C:\Users\thano\OneDrive\Documents\USC\DeepSolar\BigData\MESS_p-shave
rmpath('C:\Users\thano\OneDrive\Documents\USC\DeepSolar\OPF\cvx\lib\narginchk_')
%%
clear all; clc;
%%
load month_data.mat
fig_count = 0;
%%
mg = 10; %no of micro-grids
days = 7; % no of days
NO_MESS_TYPES = size(MESS_mat,2); % no of different mess types
%% init matrix to store results
cost_w_stor_mat = zeros(mg,NO_MESS_TYPES,days);
cost_no_stor_mat = zeros(mg,NO_MESS_TYPES,days);
ben_cost_mat = zeros(mg,NO_MESS_TYPES,days);
%% load scale parameter
MW_scale = 1; % how many MW's is the peak load
%% ger data 
for micro_grid_index = 1:mg
disp(['---------Micro-grid : ',num2str(micro_grid_index),'-------------------'])
% total number of mess types is the size of size(MESS_mat,2)
for MESS_model =  1:NO_MESS_TYPES
% assert(micro_grid_index<10,'No of micro-grids is 10')
disp(['------------MESS: ',num2str(MESS_model),'-------------------'])
for day_no = 1:days % duration of 1 week 
% start from 5th day
disp(['---Micro-grid : ',num2str(micro_grid_index),'|| MESS: ',num2str(MESS_model),'|| Day: ',num2str(day_no),'-------------------'])
% duration of  days
day_dur =1;
% scaled to 1 MW
Lt_day =MW_scale*monthly_norm_data.Aug((day_no)*24:(day_no+day_dur)*24,micro_grid_index);
% variables -----------------------------------
% peak and normal price
p_base = 47;%0.05%47; % $/MWh
p_peak = 12*1000/30; % $/kWh
assert(p_base<p_peak,'Peak price lower that base')
% Energy capacity MWh
E_cap = MESS_mat(1,MESS_model); %
% E_cap = 0.5;
% Depth of Discharge DoD
% DoD = MESS_mat(3,MESS_model);%
% DoD = 0.95;
DoD = MESS_mat(3,MESS_model);
alpha = (1-DoD)/2;
fig_count = fig_count + 1;
% energy initial storage
E_init = alpha*E_cap ;
% E_init = b(end);
% Power Capacity MW
P_max  = MESS_mat(2,MESS_model);
% P_max = 0.25;
% Depth of Discharge DoD
% DoD = 0.9;

% Time resolution is the length of the load array 
Time_slots = size(Lt_day,1);
% peak charge threshold in kW
% L_thres = 700;
% L_thres_ar = L_thres*ones(size(Lt_day));
% assert(alpha*E_cap <= E_init && E_init <= (1-alpha)*E_cap,'Init charge exceed MESS cap' )
% -------------- opt problem ---------------------
tic
cvx_begin quiet
cvx_solver gurobi
% cvx_solver_settings('TIMELIMIT',10); 
% variable b_ch(Time_slots) 
% variable b_dc(Time_slots) 
variable b(Time_slots)
variable max_var%(Time_slots)
% variable per_shave
% minimize p_elec*sum(Lt_day(:)-b(:)) + p_peak*max_var%max([(Lt_day(:)-b(:)-L_thres_ar(:))])
minimize p_base*sum(Lt_day(:)-b(:)) + p_peak*max_var%max([(Lt_day(:)-b(:)-L_thres_ar(:))])
%  minimize sum(p_base*min(Lt_day(:)-b(:), L_thres_ar(:)) + p_peak*max(Lt_day(:)-b(:)-L_thres_ar(:),0) )
% minimize sum(p_base*(Lt_day(:)-b(:)) + (p_peak-p_base)*max(Lt_day(:)-b(:)-L_thres_ar(:),0) )
subject to 
    % const. #2
%     b(:) == b_dc(:) - b_ch(:);
    % const. #3
    b(1) == -E_init;
    -P_max <= b(:) <= P_max
%     alpha*E_cap <= E_init + cumtrapz(b_dc(Time_slots) - b_ch(Time_slots)) <= (1-a)*E_cap;
    alpha*E_cap <= cumsum(-b(:)) <= (1-alpha)*E_cap
%     alpha*E_cap <= E_init + sum(b(:)) <= (1-alpha)*E_cap;
%     const. #4
%     0 <=  b_ch(:) <= P_max;
%     % const. #5 
%     0 <=  b_dc(:) <= P_max;
    % --- max constraint--- % 
    max_var >= Lt_day(:)-b(:); %- L_thres_ar(:);
    max_var >= 0;
    % const # 6
     Lt_day(:)-b(:) >= 0;
%    Lt_day(:)-b(:) <= L_thres_ar(:)
cvx_end
if cvx_optval == Inf
    disp('Infeasible')
end
toc
% b
%-------- cost without battery ---------------
cost_no_stor =  p_base*sum(Lt_day(:)) + p_peak*max(Lt_day(:));
% cost with battery 
cost_w_stor = cvx_optval;
% benefit
ben_cost = cost_w_stor - cost_no_stor;
disp(['Net gain is: ',num2str(ben_cost)])
% percentage gain
perc_gain = ben_cost/cost_no_stor;
disp(['Percentage gain is: ',num2str(perc_gain)])
for i_plot = 1:1
    % %---------------------------
    % fig_count = fig_count + 1;
    %-------------plot--------------------
    % figure(2343+fig_count)%+p_i+1)
    %    plot(Lt_day,'b')
    %    title(['P_{max} = ',num2str(P_max),' E_{cap}= ',num2str(E_cap),...
    %        ' E_{init} = ',num2str(E_init), ' Day = ',num2str(day_no-12)])
    %    hold on;
    %    plot(Lt_day-b,'r')
    % %    hold on
    % %    bar(-b)
    % %    hold on 
    % %    bar(b_ch)
    %    set(gca, 'yGrid','on')
    % %    title('Micro-grid daily consumption')
    %    ylabel('Consumption (MW)')
    % %    xlim([0 96])
    % %    xticks(0:1:96)
    % %    xticklabels(0:3:24)
    %    xlabel(['Time (hours)',newline,'Percentage gain % is : ',num2str(100*perc_gain)])
    %    legend('Load','Shaved','Location','Northwest')
    % %    ------------------ plot battery level---------------
    % fig_count = fig_count + 1;
    % figure(2353+fig_count)
    % %    plot(cumsum(b),'b')
    %    hold on;
    % plot(100*abs(cumsum(b))/E_cap)
    %    hold on
    %    title(['Charge percentage',' Day = ',num2str(day_no-12)])
    % %    plot(Lt_day-b)
    %    set(gca, 'yGrid','on')
    % %    title('Micro-grid daily consumption')
    %    ylabel('Charge (kW)')
    % %    xlim([0 96])
    % %    xticks(0:12:96)
    % %    xticklabels(0:3:24)
    %    xlabel('Time (hours)')
end
    cost_w_stor_mat(micro_grid_index,MESS_model,day_no) = cost_w_stor;
    cost_no_stor_mat(micro_grid_index,MESS_model,day_no) = cost_no_stor;
    ben_cost_mat(micro_grid_index,MESS_model,day_no) = ben_cost;
end
disp(newline)
end
disp('$$$$ next microgrid $$$$$$')
end
%% cost without battery
cost_no_stor =  p_base*sum(Lt_day(:)) + p_peak*max(Lt_day(:));
% cost with battery 
cost_w_stor = cvx_optval;
% benefit
ben_cost = cost_w_stor - cost_no_stor;
disp(['Net gain is: ',num2str(ben_cost)])
% percentage gain
perc_gain = ben_cost/cost_no_stor;
disp(['Percentage gain is: ',num2str(perc_gain)])
%%
figure(2353+fig_count)
%    plot(cumsum(b),'b')
   hold on;
plot(100*abs(cumsum(b))/E_cap)
   hold on
   title('Charge percentage')
%    plot(Lt_day-b)
   set(gca, 'yGrid','on')
%    title('Micro-grid daily consumption')
   ylabel('Charge (kW)')
%    xlim([0 96])
%    xticks(0:12:96)
%    xticklabels(0:3:24)
   xlabel('Time (hours)')
%    legend('Load','Threshold','Shaved','Location','Northwest')
%% energy price
    base_cost = sum(p_base*Lt_day(:) + (p_peak-p_base)*m700ax(Lt_day(:)-L_thres_ar(:),0) );
    disp(['Base cost is ',num2str(base_cost)])
    sum(p_base*min(Lt_day(:), L_thres_ar(:)) + p_peak*max(Lt_day(:)-L_thres_ar(:),0))
    %%
    cvx_begin %quiet
    cvx_solver gurobi
    % cvx_solver_settings('TIMELIMIT',10); 
    variable b(Time_slots)
    minimize p_elec*sum(Lt_day(:)-b(:)) + p_peak*max((Lt_day(:)-b(:)-L_thres),0)
    subject to 
        % const. #2
        b(Time_slots) == b_dc(Time_slots) - b_ch(Time_slots);
        % const #3
        alpha*E_cap <= E_init + cumsum(b(:)) <= (1-alpha)*E_cap;
        % const. #4
        -P_max <=  b <= P_max;
    cvx_end
    %%
    trapz(Lt_day)
    trapz(Lt_day - b)+ E_init



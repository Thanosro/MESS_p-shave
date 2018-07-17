fig_count = 0;
%% variables
% peak and normal price
p_base = 0.05;
p_peak = 12/30;
assert(p_base<p_peak,'Peak price lower that base')
% Energy capacity MWh
E_cap = 500;
% energy initial storage
E_init = 10 ;
% Power Capacity MW
P_max = 70;
% Depth of Discharge DoD
DoD = 0.9;
% Time resolution is the length of the load array 
Time_slots = size(Lt_day,1);
% peak charge threshold in kW
% L_thres = 700;
% L_thres_ar = L_thres*ones(size(Lt_day));
% Depth of Discharge DoD
DoD = 0.9;
alpha = (1-DoD)/2;
fig_count = fig_count + 1;
% assert(alpha*E_cap <= E_init && E_init <= (1-alpha)*E_cap,'Init charge exceed MESS cap' )
%%
micro_grid_index = 8;
day_no = 15;
Lt_day = 1000*monthly_norm_data.Mar((day_no-1)*24+1:day_no*24,micro_grid_index);
% plot(Lt_day)
fig_count = fig_count + 1;
% optimization problem 
% cost_en_3d = a*Supply_vec_3d;
tic
cvx_begin quiet
cvx_solver gurobi
% cvx_solver_settings('TIMELIMIT',10); 
variable b_ch(Time_slots) 
variable b_dc(Time_slots) 
variable b(Time_slots)
variable max_var%(Time_slots)
% variable per_shave
% minimize p_elec*sum(Lt_day(:)-b(:)) + p_peak*max_var%max([(Lt_day(:)-b(:)-L_thres_ar(:))])
minimize p_elec*sum(Lt_day(:)-b(:)) + p_peak*max_var%max([(Lt_day(:)-b(:)-L_thres_ar(:))])
%  minimize sum(p_base*min(Lt_day(:)-b(:), L_thres_ar(:)) + p_peak*max(Lt_day(:)-b(:)-L_thres_ar(:),0) )
% minimize sum(p_base*(Lt_day(:)-b(:)) + (p_peak-p_base)*max(Lt_day(:)-b(:)-L_thres_ar(:),0) )
subject to 
    % const. #2
    b(:) == b_dc(:) - b_ch(:);
    % const. #3
    b_ch(1) == E_init;
%     -P_max <= b(:) <= P_max
%     alpha*E_cap <= E_init + cumtrapz(b_dc(Time_slots) - b_ch(Time_slots)) <= (1-a)*E_cap;
    alpha*E_cap <= E_init + cumsum(b(:)) <= (1-alpha)*E_cap;
%     alpha*E_cap <= E_init + sum(b(:)) <= (1-alpha)*E_cap;
    % const. #4
    0 <=  b_ch(:) <= P_max;
    % const. #5 
    0 <=  b_dc(:) <= P_max;
    % --- max constraint--- % 
    max_var >= Lt_day(:)-b(:); %- L_thres_ar(:);
    max_var >= 0;
%     max_var == max(Lt_day(:)-b(:)-L_thres_ar(:))
    % const # 6
     Lt_day(:)-b(:) >= 0;
%    Lt_day(:)-b(:) <= L_thres_ar(:)
cvx_end
if cvx_optval == Inf
    disp('Infeasible')
end
toc
%%
figure(2343+fig_count)%+p_i+1)
   plot(Lt_day,'b')
   title(['P_{max} = ',num2str(P_max),' E_{cap}= ',num2str(E_cap), ' E_{init} = ',num2str(E_init)])
   hold on;
   plot(Lt_day-b,'r')
   hold on
   bar(-b)
%    hold on 
%    bar(b_ch)
   set(gca, 'yGrid','on')
%    title('Micro-grid daily consumption')
   ylabel('Consumption (kW)')
%    xlim([0 96])
%    xticks(0:1:96)
%    xticklabels(0:3:24)
   xlabel('Time (hours)')
   legend('Load','Shaved','Location','Northwest')
%%
figure(2353+fig_count)
   plot(cumsum(b),'b')
   hold on;
% plot(b,'b')
   hold on
%    plot(Lt_day-b)
   set(gca, 'yGrid','on')
%    title('Micro-grid daily consumption')
   ylabel('Consumption (kW)')
%    xlim([0 96])
%    xticks(0:12:96)
%    xticklabels(0:3:24)
   xlabel('Time (hours)')
%    legend('Load','Threshold','Shaved','Location','Northwest')
%% cost without battery
cost_no_stor =  p_elec*sum(Lt_day(:)) + p_peak*max(Lt_day(:));
% cost with battery 
cost_w_stor = cvx_optval;
% benefit
ben_cost = cost_w_stor - cost_no_stor;
disp(['Net gain is: ',num2str(ben_cost)])
% percentage gain
perc_gain = ben_cost/cost_no_stor;
disp(['Percentage gain is: ',num2str(perc_gain)])
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



fig_count = 0;
%% variables
% peak and normal price
p_elec = 0.05;
p_peak = 12/30;
% Energy capacity MWh
E_cap = 500;
% energy initial storage
E_init = 100;
% Power Capacity MW
P_max = 120;
% Time resolution is the length of the load array 
Time_slots = size(Lt_day,1);
% peak charge threshold in kW
L_thres = 500;
L_thres_ar = L_thres*ones(size(Lt_day));
% Depth of Discharge DoD
DoD = 0.9;
alpha = (1-DoD)/2;
fig_count = fig_count + 1;
%%
micro_grid_index = 5;
Lt_day = 1000*monthly_norm_data.Sep(1:24,micro_grid_index);
plot(Lt_day)
%% optimization problem 
% cost_en_3d = a*Supply_vec_3d;
cvx_begin %quiet
cvx_solver gurobi
% cvx_solver_settings('TIMELIMIT',10); 
variable b_ch(Time_slots) 
variable b_dc(Time_slots) 
variable b(Time_slots)
variable max_var%(Time_slots)
% variable per_shave
% minimize p_elec*sum(Lt_day(:)-b(:)) + p_peak*max_var%max([(Lt_day(:)-b(:)-L_thres_ar(:))])
minimize p_elec*sum(Lt_day(:)-b(:)) + p_peak*max_var%max([(Lt_day(:)-b(:)-L_thres_ar(:))])

subject to 
    % const. #2
    b(:) == b_dc(:) - b_ch(:);
    % const. #3
    b(1) == E_init;
%     alpha*E_cap <= E_init + cumtrapz(b_dc(Time_slots) - b_ch(Time_slots)) <= (1-a)*E_cap;
    alpha*E_cap <= E_init + cumsum(b(:)) <= (1-alpha)*E_cap;
    % const. #4
    0 <=  b_ch(:) <= P_max;
    % const. #5 
    0 <=  b_dc(:) <= P_max;
    % --- max constraint--- % 
    max_var >= Lt_day(:)-b(:) - L_thres_ar(:);
    max_var >= 0;
%     max_var == max(Lt_day(:)-b(:)-L_thres_ar(:))
    % const # 6
     Lt_day(:)-b(:) >= 0
%    Lt_day(:)-b(:) <= L_thres_ar(:)
cvx_end
%%
figure(2343+fig_count)%+p_i+1)
   plot(Lt_day,'b')
   title(['P_{max} = ',num2str(P_max),' E_{cap}= ',num2str(E_cap)])
   hold on;
   % plot straight line to denote the peak consumption
   plot(500*ones(1,length(Lt_day)),'--')
   hold on
   plot(Lt_day-b)
   set(gca, 'yGrid','on')
   
%    title('Micro-grid daily consumption')
   ylabel('Consumption (kW)')
%    xlim([0 96])
%    xticks(0:1:96)
%    xticklabels(0:3:24)
   xlabel('Time (hours)')
   legend('Load','Threshold','Shaved','Location','Northwest')
%%
figure(2353+fig_count)
%    plot(cumsum(b),'b')
   hold on;
plot(b,'b')
   hold on
%    plot(Lt_day-b)
   set(gca, 'yGrid','on')
%    title('Micro-grid daily consumption')
   ylabel('Consumption (kW)')
   xlim([0 96])
   xticks(0:12:96)
   xticklabels(0:3:24)
   xlabel('Time (hours)')
%    legend('Load','Threshold','Shaved','Location','Northwest')
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



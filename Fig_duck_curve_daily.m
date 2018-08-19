%% SIMULATION PART
load solar_data.mat
disp(str2)
%%
load month_data.mat
%%
% Load scale to 1 MW factor
MW_scale = 1;
day_no = 1; % day of the month
assert(day_no<=30,'day > 30')
% solar scale to 0.8 MW
Sol_scale = (0.85/max(solar_data((day_no),:)))*MW_scale;
% Sol_scale = (mean(solar_data((day_no),:)))*MW_scale;
micro_grid_index = 3;
% load array for day_no for micro_grid_index
Lt_day =MW_scale*monthly_norm_data.Jul((day_no)*24:(day_no+1)*24-1,micro_grid_index);
% solar array for day_no (days are the rows in solar_data array)
solar_day = Sol_scale*solar_data((day_no),:);
Net_load = Lt_day-solar_day';
%%
% E_cap = 0.52;
% P_max = 0.52;
P_max = 0.8;
E_cap = 0.8;
DoD = 0.9;
alpha = (1-DoD)/2;
E_init = alpha*E_cap;
% E_init = 0
dif_mat = diag(-1*ones(1,size(Net_load,1)-1),-1) + eye(size(Net_load,1));
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
%% generate duck curve figure
figure(810+randi(400,1))
% hold on
plot(Net_load)
% title(['Net Load: Load-Solar-MESS',newline,'E_{cap}= ',num2str(E_cap),...
%     ' MWh P_{max}= ',num2str(P_max),' MW'])
title('Duck Curve Ramp Minimization')
% ,newline,'Start time: '...
%     ,num2str(time_init),' End time: ',num2str(time_fin)])
hold on
xlim([10 21])
xlabel('Hours')
ylabel('Net Load (MW)')
set(gca,'YGrid','on')
% figure(34)
plot(tot_load)
legend('NO MESS','MESS','Location','Northwest')
%%
% print('duck_curve_opt','-depsc','-r300')
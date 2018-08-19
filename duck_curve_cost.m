%% generate graph costs-benefits for duck curve part
%% simulation is for 7 days for 10 microgrids
% no of micro-grids is micro_grid_index
% number of days is day_no
% assert commmand indicates any index errors with the number of microgrids
% and days
load solar_data.mat
disp(str2)
%%
load month_data.mat
%%
% Load scale to 1 MW factor
MW_scale = 1;
base_price = 10;
peak_price = 40;
% for day_no = 1:7
% for micro_grid_index = 1:10
day_no = 13; % day of the month
assert(day_no<=30,'day > 30')
% solar scale to 0.8 MW
Sol_scale = (0.7/max(solar_data((day_no),:)))*MW_scale;
% Sol_scale = (mean(solar_data((day_no),:)))*MW_scale;
micro_grid_index = 10;
assert(micro_grid_index<=10,'Invalid micro-grid index')
% load array for day_no for micro_grid_index
Lt_day =MW_scale*monthly_norm_data.Jul((day_no)*24:(day_no+1)*24-1,micro_grid_index);
% solar array for day_no (days are the rows in solar_data array)
solar_day = Sol_scale*solar_data((day_no),:);
Net_load = Lt_day-solar_day';
% figure(600)
% % hold on
% plot(Lt_day)
% title('Load')
% hold on
% figure(601)
% plot(solar_day)
% title('Solar')
% figure(609+day_no)
% % hold on
% plot(Net_load)
% hold on
% title('Net Load: Load-Solar')
% legend
if any(Net_load <= 0) == 1
    disp('Net load has negative vale')
    disp('Solar generation > Load demand')
end
%
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
cvx_begin  quiet
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
    ylim([0 1])
    xlabel('Time (hours)')
    ylabel('Net Load (MW)')
    set(gca,'YGrid','on')
    % figure(34)
    plot(tot_load)
    legend('NO MESS','MESS','Location','Northwest')
% cost computation
% tot_load is with MESS
% Net_load is without MESS
% power plant energy generation price base and peak plant
% cost is base_price* min*() + the rest* peak price
cost_no_MESS = base_price*min(Net_load)+sum(peak_price*(Net_load - min(Net_load)));
cost_MESS = base_price*min(tot_load)+sum(peak_price*(tot_load - min(tot_load)));
gain_duck(day_no,micro_grid_index) = cost_MESS-cost_no_MESS;
% end
% end
%%
save 10mg_7days_duck.mat gain_duck
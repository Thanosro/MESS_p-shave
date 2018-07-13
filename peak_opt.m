%% variables
% peak and normal price
p_elec = 0.05;
p_peak = 12/30;
% Energy capacity kWh
E_cap = 500;
% Power Capacity kW
P_max = 100;
% Time resolution is the length of the load array 
Time_slots = size(Lt_day,1);
% Depth of Discharge DoD
DoD = 0.9;
alpha = (1-DoD)/2;
%% optimization problem 
% cost_en_3d = a*Supply_vec_3d;
cvx_begin %quiet
cvx_solver gurobi
% cvx_solver_settings('TIMELIMIT',10); 
variable b_ch(Time_slots) 
variable b_dc(Time_slots) 
variable b(Time_slots)
minimize p_elec*sum(Lt_day(Time_slots)-b(Time_slots)) + p_peak*max(Lt_day(Time_slots)-b(Time_slots))
minimize p_elec*sum(total_energy_demand(Time_slots)-b(Time_slots)) + p_peak*
subject to 
    % const. #2
    b(Time_slots) == b_dc(Time_slots) - b_ch(Time_slots) ;
    % const. #3
    alpha*E_cap <= cumsum() <= (1-a)*E_cap
    % const. #4
    0<=  b_ch(:) <= P_max;
    % const. #5 
    0<=  b_dc(:) <= P_max;
cvx_end
% min_cost_S = sum(sum(sum(cost_en_3d.*x_3d))) + p*(sum(s_t_mat_3d));%^2);
% end
%PEAK SHAVE simulation file
run graph_gen.m
min_cost_array = zeros(1,10);
greedy_array = zeros(1,10);
for reloc_factor = 0.8:0.2:1.2 
    run Min_cost_flow_sim.m
%     min_cost_array(reloc_factor) = abs(cost_v*fl);
    run greedy_baseline.m
%     greedy_array(reloc_factor) = abs(sum(suc_sh_pa));
end
%%
figure(1020+randi(400,1))
plot((-greedy_array+min_cost_array)./(greedy_array))
title(['Gain percentage',newline,'Distance factor: ',num2str(reloc_factor)])
xlabel('No of MESS')
ylabel("percentage")
ylim([-0.005 inf])
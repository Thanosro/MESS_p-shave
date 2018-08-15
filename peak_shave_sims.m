%PEAK SHAVE simulation file
min_cost_array = zeros(1,10);
greedy_array = zeros(1,10);
reloc_mat = linspace(0.8,1.2,5);
tic;
for loop_count = 1:length(reloc_mat)
    reloc_factor = reloc_mat(loop_count);
    run graph_gen.m
    run Min_cost_flow_sim.m
    min_cost_array(loop_count) = abs(cost_v*fl);
    run greedy_baseline.m
    greedy_array(loop_count) = abs(sum(suc_sh_pa));
end
toc;
%%
figure(1020+randi(400,1))
plot((-greedy_array+min_cost_array)./(greedy_array))
title(['Gain percentage',newline,'Distance factor: ',num2str(reloc_factor)])
xlabel('No of MESS')
ylabel("percentage")
ylim([-0.005 inf])
%%
close all;
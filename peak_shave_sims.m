%PEAK SHAVE simulation file
reloc_array = linspace(0,2,201);
% reloc_mat = linspace(0.25,0.25,1);

tic;
for NO_MESS = 2:10
min_cost_array = zeros(1,length(reloc_array));
greedy_array = zeros(1,length(reloc_array));
for loop_count = 1:length(reloc_array)
    reloc_factor = reloc_array(loop_count);
    run graph_gen.m
    run Min_cost_flow_sim.m
    min_cost_array(loop_count) = abs(cost_v*fl);
    run greedy_baseline.m
    greedy_array(loop_count) = abs(sum(suc_sh_pa));
end
sim_time = toc;
disp(['Sim time is: ',num2str(sim_time)])
perc_gain = 100*(-greedy_array+min_cost_array)./(greedy_array);
%     if length(reloc_array) <= 5
%         disp(['Perc gain % is: ',num2str(perc_gain)])
%     end
disp('------***********--------')
disp(['MESS no: ',num2str(NO_MESS)])
min_cost_mat(:,NO_MESS) = min_cost_array;
greedy_mat(:,NO_MESS) = greedy_array;
perc_gain_mat(:,NO_MESS) = perc_gain;
end
%%
figure(1020+randi(400,1))
plot(reloc_array,perc_gain)
title(['Gain percentage',newline,'No of MESS: ',num2str(NO_MESS)])
xlabel('Relocation Factor')
ylabel("Percentage")
ylim([0 inf])
%%
close all;
%%
str_10MESS_200rf = ['Contains data from simulations of MESS number',newline...
    ,'ranging from 2 to 10. Relocation factor varied',newline,'from 0 to 2 with 201 steps',newline,...
    'greedy_mat has the results of the greedy baseline',newline,...
    'min_cost_mat has the results of min cost flow algo',newline...
    'perc_gain_mat has the results of min_cost - greedy/greedy']
%%
% % % save 10MESS_200rf.mat perc_gain_mat greedy_mat min_cost_mat str_10MESS_200rf
%%
load 10MESS_200rf.mat
disp(str_10MESS_200rf)
%%
mesh(perc_gain_mat);  
rotate3d on;
xlabel('No of MESS', 'Rotation',20)
ylabel('Reloc. Factor', 'Rotation',-30)
zlabel('Gain Percentage (%)') 
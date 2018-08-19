%% peak shave dataset
load 10MESS_200rf.mat
disp(str_10MESS_200rf)
%% reloc_array for peak shave
reloc_array = linspace(0,2,201);
%% reloc_array for duck curve vs greedy
% load duck curve dataset
load 10MESS_17rf_duck.mat
reloc_array = linspace(1,5,17);
%
%% ESS benefits for each micro-grid is the sum of each row of gain_duck matrix

load('10mg_7days_duck.mat')
gain_duck_rsh = reshape(gain_duck,1,70);

ESS_gain = sum(reshape(gain_duck_rsh',10,[]),2);
% benefit of each ESS
% NO_MESS = 8;
for NO_MESS = 2:10;
ESS_assign = maxk(abs(ESS_gain),NO_MESS);
% total benefit of using ESS
ESS_ben = sum(ESS_assign);
perc_gain_ESS(:,NO_MESS) = 100*((min_cost_mat(:,NO_MESS)-ESS_ben)/ESS_ben);
end

%%
% number of mess in the plot
% no_mess_pl = 4:6;
no_mess_pl = [3 7 9 10];
figure(2020+randi(400,1))
% plot(reloc_array,perc_gain_mat(:,no_mess_pl))
% _________________relocation index for peak shave________________
% reloc_ind = [0.15 0.35 0.75 1.0 1.35];
% bar(reloc_ind,perc_gain_mat(reloc_ind*100,no_mess_pl));
% ________________relocation index for duck curve________________
reloc_ind = [1 1.5 2 2.5 3 3.5 4 4.5 5];
% bar(reloc_ind,perc_gain_mat(((reloc_ind-1)/0.25)+1,no_mess_pl));
%__________________reloc index for ESS duck curve
bar(reloc_ind,perc_gain_ESS(((reloc_ind-1)/0.25)+1,no_mess_pl));
%_______________________________________________________
set(gca, 'XTick', (reloc_ind))
% set(gca,'YGrid','on','LineWidth',1.5)
set(gca,'YGrid','on')
% set(gca, 'XTickLabel', {num2str(reloc_ind(1)),num2str(reloc_ind(2)),num2str(reloc_ind(3))})
% xticks(h_bar,reloc_ind*100)
% xticklabels(h_bar,{num2str(reloc_ind)})
title(['Percentage Gain for Different Relocation Factors'])
xlabel('Relocation Factor')
ylabel("Percentage Gain (%)")
ylim([0 12.5])
% xlim([0 200])
h_leg = legend('show');
title(h_leg,'No of MESS')
% legend(num2str(no_mess_pl))
% legend on;
legend(string(no_mess_pl),'Location','north')
% legend({num2str(no_mess_pl(1)),num2str(no_mess_pl(2)),num2str(no_mess_pl(3))},'Location','north')
%%
% print('bar_peak_shave','-dpng','-r0')
% print('bar_peak_shave2','-depsc','-r300')
%%
% print('bar_duck_curve','-depsc','-r300')
%%
% print('bar_duck_curve_ESS','-depsc','-r300')
%%
close all
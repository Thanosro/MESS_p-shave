%% Pre-processing of PJM Load Datasets
cd C:\Users\Thanos\Documents\DeepSolar\BigData\sims\Dataset\zones
%% datasets
micro_grids = string({'hrl_load_metered_RFC_MIDATL_JC_JC.csv'; ...
                'hrl_load_metered_RFC_WEST_ATSI_OE.csv'; ... 
                'hrl_load_metered_RFC_WEST_CE_CE.csv'; ... 
                'hrl_load_metered_RFC_WEST_DEOK_DEOK.csv'; ...
                'hrl_load_metered_RFC_WEST_DUQ_DUQ.csv'; ...
                'hrl_load_metered_RTO_RTO_RTO_RTO.csv'; ...
                'hrl_load_metered_SERC_SOUTH_DOM_DOM.csv'; ...
                'hrl_load_metered_SERC_WEST_EKPC_EKPC.csv'; ...
                'hrl_load_metered_West_AEP_AEPAPT.csv'
    });
%%
micro_grid_array = zeros(8760,length(micro_grids));
for i_read = 1:length(micro_grids)
    micro_grid_array(:,i_read) = import_data(micro_grids(i_read),2,8761)';
end
%% save filename with different name each time to avoid overwrite (with random number)
save('micro_grid_data.mat',['micro_grid_array',num2str(randi(4000,1))])
%% load data
load('micro_grid_data.mat')
%% %% data for each month
month_index = 7;
assert(month_index >= 1 && month_index <= 12,'Not valid month')
hr_ind_end = (sum(eomday(2017, 1:month_index)))*24;
hr_ind_start  = (sum(eomday(2017, 1:month_index-1)))*24+1;
disp(['Data for month ',num2str(month_index)])
%% plot load demand for each month for each micro-grid
micro_grid_index = 5;
assert(micro_grid_index >= 1 && micro_grid_index <= 9,'Not valid micro-grid')
figure(5)
plot(micro_grid_array(hr_ind_start:hr_ind_end,5:9))
title(['Month ',num2str(month_index)])
ylabel('MW')
xlabel('Days')
%% average daily load consumption 
% reshape matrix to 24 and then mean 


%% data for each month
% returns the number of days in each month
mo_days = eomday(2017, 1:12);
% total number of days 
mo_days_tot = cumsum(mo_days);
% total number of hours
hours_tot = mo_days_tot*24;
% specify which month
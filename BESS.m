%% Samsung https://zerohomebills.com/wp-content/uploads/Samsung_ESS_Data_Sheet.pdf
% Energy capacity kWh
E_cap = 3.6;
% Power Capacity kW
P_max = 2;
% Depth of Discharge DoD
DoD = 0.9;
%% Canadian Solar https://www.canadiansolar.com/fileadmin/user_upload/downloads/datasheets/v5.3/Canadian_Solar-Datasheet-Camel_ESS_v5.3C2_en.pdf
% Energy capacity kWh
E_cap = 7.2;
% Power Capacity kW
P_max = 4.5;
% Depth of Discharge DoD
DoD = 0.9;
%% Freqcon  https://www.freqcon.com/wp-content/uploads/FREQCON-datasheet-grid-storage-BESS.pdf
% Energy capacity kWh
E_cap = 1000;
% Power Capacity kW
P_max = 1000;
% Depth of Discharge DoD
DoD = 0.95;
%% BMZ http://www.prosolar.net/userfiles/BMZ_ESS7%200_Germany.pdf
% Energy capacity kWh
E_cap = 6.74;
% Power Capacity kW
P_max = 8;
% Depth of Discharge DoD
DoD = 0.9;
%% RES mess http://www.res-group.com/media/342187/mobile_energystorage_161117.pdf
% Energy capacity kWh
E_cap = 1000;
% Power Capacity kW
P_max = 500;
% Depth of Discharge DoD
DoD = 0.9;
%% matrix with all the mess values DATA SCALED TO 0.5 MW
MESS_scale_factor =1; % for 1 MW
% samsung / canadian solar / freqon / BMZ / RES / 
MESS_mat =     [3.60 0.8*7.2  6.00 6.74 6.5; % E_cap MWh
                2.00 0.8*4.5  6.00 8.00 3.25 % P_max kW
                0.90 0.85     0.95 0.90 0.90 ];% DoD
MESS_mat = [MESS_scale_factor*0.0875*MESS_mat(1,:) ;
            MESS_scale_factor*0.0875*MESS_mat(2,:);
                MESS_mat(3,:)];

            
            
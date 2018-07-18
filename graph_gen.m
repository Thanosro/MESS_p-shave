% plot graphs for figure 3 in paper
% graph with node split
% clc; clear all; close all;
%m , d # of days
% mg = 3; 
days =4;
% # of MESS types
NO_MESS_TYPES = 4;
%% transfer cost matrix for variable mg
base_reloc_cost =1;
reloc_mat =tril(randi(4,mg));
reloc_mat = tril(reloc_mat);
reloc_mat =  base_reloc_cost*(reloc_mat+triu(reloc_mat',1));
%% transfer cost matriix for fixed mg = 10
% USC LAX UCLA UC Irv. Long Beach Port UC Riv. Disn. Cal-State LB CalTech
% Univ. City
mg = 10;
LA_dist = [0 15.0 13.2 43.2 26.9 59.7 28.7 26.5 13.7 10.4; %USC
           0 0.00 10.4 41.6 23.3 71.4 34.5 27.6 25.9 25.5; %LAX
           0 0.00 0.00 50.8 32.7 69.7 42.5 34.9 25.3 16.3; %UCLA
           0 0.00 0.00 0.00 33.7 50.1 14.6 19.2 50.8 51.9; %UC Irv
           0 0.00 0.00 0.00 0.00 66.1 22.1 8.20 36.4 39.0; %Long Beach Port
           0 0.00 0.00 0.00 0.00 0.00 41.4 54.9 52.2 66.4; %UC Riv
           0 0.00 0.00 0.00 0.00 0.00 0.00 13.7 41.1 36.6; %Disneyland
           0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 31.1 35.5; %Cal-State LB
           0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 14.4; %CalTech
           0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00]; %Univ. City
LA_dist =  LA_dist+LA_dist';
% per mile cost for 2018
cost_per_mile = 0.01370*2018 - 25.94;
cost_per_mile = 1.7066;
LA_cost = LA_dist*cost_per_mile+eye(10);
%%
% A0 = [eye(mg) zeros(mg);zeros(mg) reloc_mat];
A0 = [eye(mg) zeros(mg);zeros(mg) LA_cost];
AD0 = kron(eye(days-1),A0);
% spy(AD0)
AD1 = blkdiag(AD0,eye(mg));
AD2 = [zeros((days-1)*2*mg+mg,mg) AD1; zeros(mg) zeros(mg,(days-1)*2*mg+mg)];
% spy(AD2)
G0 = digraph(AD2);
% initial number of edges
init_edges = numedges(G0);
G0 = addnode(G0,{'S*'});
G0 = addnode(G0,{'T*'});
Ed_S0 = table([(2*mg*days+1)*ones(mg,1) (1:mg)'],ones(mg,1),'VariableNames',{'EndNodes','Weight'});
Ed_T0 = table([ ((2*mg*days-mg+1):(2*mg*days))' (2*mg*days+2)*ones(mg,1)],ones(mg,1),'VariableNames',{'EndNodes','Weight'});
G0 = addedge(G0,Ed_S0);
G0 = addedge(G0,Ed_T0);
redo = 0;
%% array with benefits / cost reductions from each mess
ben_arr = 9:NO_MESS_TYPES-1+9
%%
% avoid to run code two times and add twice the no of edges
assert(redo<1,'Code ran twice')
% reshape array to find the add nodes indices
resh_1 = reshape(1:mg*days*2,mg,[]);
% resh_1 = repmat(resh_1,NO_MESS_TYPES,1)
% add_edge_ind = sort(reshape(resh_1',2,[])');
add_edge_ind = reshape(resh_1',2,[])';
add_edge_ind_rep = repelem(add_edge_ind,NO_MESS_TYPES-1,1);
add_edge_table = table(add_edge_ind_rep,[ones(length(add_edge_ind_rep),1)],...
    'VariableNames',{'EndNodes','Weight'});
G0 = addedge(G0,add_edge_table);
redo = redo +1;
%% add edges costs and capacities 
% edge capacities are 1 except those of S* and T* with capacity equal to
% the # of MESS
% assign label nodes
G0.Edges.Labels = (1:numedges(G0))';
G0.Edges.Capacities = ones(numedges(G0),1);
%% the index for each edge for each MESS type is
for MESS_NO = 1:NO_MESS_TYPES% = 2;%,2,3 for MESS number 1, 2, etc
% (0:days-1)*(mg*(mg+NO_MESS_TYPES)) + MESS_NO;
    for mess_ind = MESS_NO : NO_MESS_TYPES :mg*NO_MESS_TYPES
        (0:days-1)*(mg*(mg+NO_MESS_TYPES)) + mess_ind;
        highlight(h1,'Edges',[ans],'EdgeColor','r','LineWidth',1.5)
    end
end
%%
figure(500)
% fullscreen figure
% figure('units','normalized','outerposition',[0 0 1 1])
h1 =plot(G0,'EdgeLabel',G0.Edges.Weight);

layout(h1,'layered','Direction','right','Sources', 'S*','Sinks','T*')
highlight(h1,'Edges',1:numedges(G0),'LineWidth',1.5)
% highlight(h1,'Edges',findedge(G0,add_edge_ind(:,1),add_edge_ind(:,2)),'EdgeColor','r','LineWidth',1.5)
highlight(h1,1:numnodes(G0),'MarkerSize',4,'NodeColor','r')
micro_names ={"USC" "LAX" "UCLA" 'UC Irv.' 'Long Beach Port' 'UC Riv.' 'Disn.'....
    'Cal-State' 'LB CalTech' 'Univ. City'};
set(gca, 'Ytick',1:mg,'YTickLabel',micro_names);
% test hightlight edges
% highlight(h1,'Edges',[ans],'EdgeColor','r','LineWidth',1.5)
% highlight(h1,'Edges',[1:NO_MESS_TYPES:6],'EdgeColor','r','LineWidth',1.5)
%------------ commands to make the figure pretty------- 
% xd = get(h1, 'XData');
% yd = get(h1, 'YData');
% set(gca,'YTick',[])
% set(gca,'XTick',[])
% set(gca,'Visible','off')
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% 
% box off
% xlabel('(b)')
% labelnode(h1,[1:numnodes(G0)],'')
% highlight(h1,[1:numnodes(G0)]' ,'NodeColor','r','MarkerSize',6)
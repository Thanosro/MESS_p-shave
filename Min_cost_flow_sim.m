% min cost flow for graph G0 for NO_MESS number of mess
cost_v = G0.Edges.Costs';
% NO_MESS = 6;
tic;
cvx_begin quiet
cvx_solver gurobi
variable fl(numedges(G0),1)  %integer
% maximize sum(cost_v*fl)
minimize cost_v*fl
subject to 
    incidence(G0)*fl == [zeros(numnodes(G0)-2,1); -NO_MESS; NO_MESS];
    0 <= fl <= G0.Edges.Capacities;
cvx_end
toc;
[fl cost_v'];
disp(['Total cost reduction with MESS: ',num2str(cost_v*fl)])
%%
% if sum(mod(fl,1)) == 0
%     disp('Flow is int')
% else
%     disp('Flow is not int')
% end
%----------------------------------------------

highlight(h1,'Edges',find(fl>0),'EdgeColor','r','LineWidth',1.5)
title(['LA Micro-grids Case Study: Min Cost Flow',newline,'No of Mess ',num2str(NO_MESS)...
    ,newline,'Dist. Fac: ',num2str(reloc_factor)])
% title(['',newline,num2str(cost_v*fl)])
xlabel(['Days',newline,'Benefit: ',num2str(abs(cost_v*fl))])
set(gca,'YTick',[])
set(gca,'XTick',[])
%--------------------------------------------
% highlight(h1,'Edges',find(fl>0),'EdgeColor','r','LineWidth',3.5)
% title(['',newline,num2str(cost_v*fl)])
% xlabel(['Days',newline,'Benefit: ',num2str(abs(cost_v*fl))])
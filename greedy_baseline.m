%% SHORTEST PATHS
Gs = G0;
% MESS = 4;
suc_sh_pa = zeros(1,NO_MESS_TYPES);
figure(27)
% subplot(3,2,2*mess_counter)
% h2 = plot(Gs,'EdgeLabel',Gs.Edges.Weight);
h2 = plot(Gs);
title(['LA Micro-grids Case Study: Greedy',newline,'No of Mess ',num2str(NO_MESS_TYPES)])

labelnode(h2,[1:numnodes(Gs)-2],'')
layout(h2,'layered','Direction','right','Sources','S*','Sinks','T*')
if NO_MESS_TYPES == 1
    title('Shortest Paths','FontSize',12,'FontWeight','bold')
end
disp('******* Shortest Paths Costs ***********')
for i_rm = 1:NO_MESS_TYPES
    [P_nodes,path_len,path1] = shortestpath(Gs,'S*','T*','Method','mixed');
%     [P_nodes,path_len,path1] = shortestpath(Gs,'S*','T*');
    suc_sh_pa(i_rm) = path_len;
    Rm_nodes = P_nodes(2:(end-1));
%     G = rmnode(G,Rm_nodes);
    Gs.Edges.Weight(path1) = inf;
    highlight(h2,'Edges',path1,'EdgeColor','r','LineWidth',1.5)
    layout(h2,'layered','Direction','right','Sources','S*','Sinks','T*')
    disp(['Cost of ',num2str(i_rm),' path is: ',num2str(suc_sh_pa(i_rm))])
    %&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    % each column of Shortest_Path_mat is the edges index for each path 
    Shortest_path_mat(:,i_rm) = path1;
end
suc_sh_pa;
disp(['Total cost reduction with shortest paths is  ',num2str(sum(suc_sh_pa))])
% disp(['Total cost  with shortest paths is  ',num2str(sum(suc_sh_pa)+Base_cost)])
disp(newline)
xlabel(['Days',newline,'Benefit: ',num2str(abs(sum(suc_sh_pa)))])%,'FontSize',10,'FontWeight','bold')
set(gca,'YTick',[])
set(gca,'XTick',[])
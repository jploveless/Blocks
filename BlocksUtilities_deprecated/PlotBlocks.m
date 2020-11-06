function PlotBlocks(Block)

figure
axis([0 360 -90 90])
hold on

for i = 1:numel(Block.interiorLon)
   Block.orderLon{i} = [Block.orderLon{i}; Block.orderLon{i}(1)];
   Block.orderLat{i} = [Block.orderLat{i}; Block.orderLat{i}(1)];
   plot(Block.orderLon{i}(1), Block.orderLat{i}(1), '*r');
   for j = 1:length(Block.orderLon{i})-1
      new = plot([Block.orderLon{i}(j) Block.orderLon{i}(j+1)], [Block.orderLat{i}(j) Block.orderLat{i}(j+1)], 'r');
      pause(0.25); 
      a = get(gca, 'children');
      set(a(2:end), 'color', 'b'); drawnow;
   end
end
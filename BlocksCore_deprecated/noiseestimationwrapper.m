% noiseestimationwrapper(nx, nn)
nx = 20; 
nn = 20;


slipnoise = zeros(nx, nn);
slipoverd = slipnoise;

for i = 1:nx
   x = sign(randn(50, 1)).*50.*rand(50, 1);
   for j = 1:nn
      [G, u, noise] = SingleScrewTimeSeries(x, 15, 10, 1);
      slipest = TestNoiseEstimation(x, G, u, abs(noise));
      slipnoise(i, j) = slipest(1);
      slipoverd(i, j) = slipest(2);
   end
end
function Block = DeleteBlock(Block, idx)

%  Delete the block(s)
Block.name(idx, :)             = [];
Block.eulerLon(idx)           = [];
Block.eulerLat(idx)           = [];
Block.eulerLonSig(idx)        = [];
Block.eulerLatSig(idx)        = [];
Block.interiorLon(idx)        = [];
Block.interiorLat(idx)        = [];
Block.rotationRate(idx)       = [];
Block.rotationRateSig(idx)    = [];
Block.rotationInfo(idx)       = [];
Block.aprioriTog(idx)         = [];
Block.other1(idx)             = [];
Block.other2(idx)             = [];
Block.other3(idx)             = [];
Block.other4(idx)             = [];
Block.other5(idx)             = [];
Block.other6(idx)             = [];
delete(findobj(gcf, 'Tag', sprintf('Block.%d', idx)));

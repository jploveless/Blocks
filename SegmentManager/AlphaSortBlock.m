function Block = AlphaSortBlock(Block)
%%  Sorts a Block struct into alphabetical order by fault name

%%  Sort the blocks into alphabetical order
[blockName, sortAlphaIndex]                                        = sort(cellstr(Block.name));
Block.name                                                         = char(blockName);
Block.interiorLon                                                  = Block.interiorLon(sortAlphaIndex);
Block.interiorLat                                                  = Block.interiorLat(sortAlphaIndex);

Block.eulerLon																		 = Block.eulerLon(sortAlphaIndex);			
Block.eulerLonSig																	 = Block.eulerLonSig(sortAlphaIndex);		
Block.eulerLat																		 = Block.eulerLat(sortAlphaIndex);			
Block.eulerLatSig																	 = Block.eulerLatSig(sortAlphaIndex);		
Block.rotationRate																 = Block.rotationRate(sortAlphaIndex);	
Block.rotationRateSig															 = Block.rotationRateSig(sortAlphaIndex);
Block.rotationInfo																 =	Block.rotationInfo(sortAlphaIndex);	 
Block.aprioriTog																	 = Block.aprioriTog(sortAlphaIndex);		

Block.other1                                                       = Block.other1(sortAlphaIndex);
Block.other2                                                       = Block.other2(sortAlphaIndex);
Block.other3                                                       = Block.other3(sortAlphaIndex);
Block.other4                                                       = Block.other4(sortAlphaIndex);
Block.other5                                                       = Block.other5(sortAlphaIndex);
Block.other6                                                       = Block.other6(sortAlphaIndex);

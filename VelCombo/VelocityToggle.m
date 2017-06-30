function VelocityToggle(filename, maxVel)
S               = ReadStadataStruct(filename);
velMag          = sqrt(S.eastVel.^2 + S.northVel.^2);
badIdx          = find(velMag > maxVel);
label           = [pwd '/' filename];
for i = 1:numel(badIdx)
   fprintf(1, '%s 0 %s - %5.2f mm/yr\n', S.name(badIdx(i), :), label, velMag(badIdx(i)));
end
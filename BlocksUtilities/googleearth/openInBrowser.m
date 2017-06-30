function openInBrowser(url)

fid = fopen(fullfile(googleearthroot,'browsercall.txt'),'r');
callStr = fgetl(fid);
fclose(fid);

system(sprintf(callStr,url));



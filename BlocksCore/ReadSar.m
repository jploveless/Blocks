function Sar = ReadSar(sarfile)
% READSAR  Reads a SAR file for use in Blocks.
%   SAR = READSAR(SARFILE) reads the textfile SARFILE, which is structured
%   as follows:
%
%   Line 1: LVE LVN LVU REFLON REFLAT
%   Lines 2-end: LON LAT LOS (LOS_SIG)
%
%   where LVE, LVN, and LVU are the east, north, up components of the look
%   vector, REFLON and REFLAT are the reference point coordinates, and the
%   data are given as LON, LAT, LOS, where LOS is the velocity in mm/yr.  
%   The 4th column can either be blank or contain uncertainties (LOS_SIG).
%   If blank, unit uncertainties will be defined and will be scaled by 
%   COMM.sarSig after returning the structure to BLOCKS.
%
%   SARFILE can also be a .mat file containing a structure named "Sar" containing
%   fields "lon", "lat", "data", "dataSig", "look_vec", and "ref_pt".
%

if ~isempty(sarfile)
   [p, n, e] = fileparts(sarfile);

   if strmatch(e, '.mat')
      load(sarfile)
   else
      fid = fopen(sarfile, 'r');
      d = textscan(fid, '%n%n%n%n%n');
      fclose all;
      Sar.look_vec = [d{1}(1) d{2}(1) d{3}(1)];
      Sar.ref_pt = [d{4}(1) d{5}(1)];
      Sar.lon = d{1}(2:end);
      Sar.lat = d{2}(2:end);
      Sar.data = d{3}(2:end);
      if ~isnan(d{4}(2))
         Sar.dataSig = d{4}(2:end);
      else
         Sar.dataSig = ones(size(Sar.data));
      end
   end
else
   zv = zeros(0, 1);
   Sar = struct('look_vec', zv, 'ref_pt', zv, 'lon', zv, 'lat', zv, 'data', zv, 'dataSig', zv);
end
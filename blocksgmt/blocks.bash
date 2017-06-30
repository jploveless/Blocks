#! /bin/bash -f

red='255/0/0'
blue='0/0/255'
green='0/255/0'
cyan='0/255/255'
magenta='255/0/255'
ocean='0/128/128'
orange='255/167/0'

#gmtset LABEL_FONT Helvetica PLOT_DEGREE_FORMAT dddF LABEL_FONT_SIZE 12 ANOT_FONT_SIZE 11 HEADER_FONT_SIZE 16p

# plot coastline
pscoast $3 -Jm$4c $5 -K -Dh -W1/0 -A0/1/1 -N1 -B1WSneg0 > $1/out.ps

# plot segments
psxy $1/Seg.coords -W1/150 -M -R -Jm -O -K >> $1/out.ps
if [[ "$2" != "-" ]]
then
   psxy $2/Seg.coords -W1/150 -R -Jm -O -K >> $1/out.ps
fi

# plot colored slip rates
if   [ ${19} > 0 ];
then
	bash $1/SegSlips.bash $1
fi

# Plot residual magnitude
if   [ ${15} = 1 ];
then
   # Res.mag is a file written to the results directory that contains columns:
   # lon. | lat. | color string
    makecpt -Crainbow -T0/5/1 -Z > resm.cpt
	psxy $1/Res.mag -Sc3p -Cresm.cpt -R -Jm -O -K >> $1/out.ps
elif [ ${15} = 2 ];	
then
    makecpt -Cjet -T0/5/1 -Z > resm.cpt
	psxy $2/Res.mag -Sc3p -Cresm -R -Jm -O -K >> $1/out.ps
fi

# Plot stations
if   [ $6 = 1 ];
then
	psxy $1/Mod.sta.data -Sc3p -R -Jm -O -K >> $1/out.ps
elif [ $6 = 2 ];	
then
	psxy $2/Mod.sta.data -Sc3p -R -Jm -O -K >> $1/out.ps
elif [ $6 = 3 ];
then
	psxy $1/Mod.sta.data -Sc3p -R -Jm -O -K >> $1/out.ps
	psxy $2/Mod.sta.data -Sc3p -R -Jm -O -K >> $1/out.ps
fi

# Plot station names
if   [ $7 = 1 ];
then
   # might need some awk statements in here to add the GMT-specific text parameters
	pstext $1/Mod.sta.data -R -Jm -O -K >> $1/out.ps
elif [ $7 = 2 ];	
then
	pstext $2/Mod.sta.data -R -Jm -O -K >> $1/out.ps
elif [ $7 = 3 ];
then
	pstext $1/Mod.sta.data -R -Jm -O -K >> $1/out.ps
	pstext $2/Mod.sta.data -R -Jm -O -K >> $1/out.ps
fi

# Plot observed vectors
if   [ $8 = 1 ];
then
	psvelo $1/Obs.sta.data -G$blue -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ $8 = 2 ];	
then
	psvelo $2/Obs.sta.data -G$blue -L -W1/150 -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ $8 = 3 ];
then
	psvelo $1/Obs.sta.data -G$blue -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
	psvelo $2/Obs.sta.data -G$blue -L -W1/150 -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi

# Plot modeled vectors
if   [ $9 = 1 ];
then
	psvelo $1/Mod.sta.data -G$red -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ $9 = 2 ];	
then
	psvelo $2/Mod.sta.data -G$red -L -W1/150 -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ $9 = 3 ];
then
	psvelo $1/Mod.sta.data -G$red -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
	psvelo $2/Mod.sta.data -G$red -L -W1/150 -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi

# Plot residual vectors
if   [ ${10} = 1 ];
then
	psvelo $1/Res.sta.data -G$magenta -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${10} = 2 ];	
then
	psvelo $2/Res.sta.data -G$magenta -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${10} = 3 ];
then
	psvelo $1/Res.sta.data -G$magenta -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
	psvelo $2/Res.sta.data -G$magenta -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi

# Plot rotational vectors
if   [ ${11} = 1 ];
then
	psvelo $1/Rot.sta.data -G$green -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${11} = 2 ];	
then
	psvelo $2/Rot.sta.data -G$green -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${11} = 3 ];
then
	psvelo $1/Rot.sta.data -G$green -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
	psvelo $2/Rot.sta.data -G$green -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi

# Plot elastic vectors
if   [ ${12} = 1 ];
then
	psvelo $1/Def.sta.data -G$cyan -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${12} = 2 ];	
then
	psvelo $2/Def.sta.data -G$cyan -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${12} = 3 ];
then
	psvelo $1/Def.sta.data -G$cyan -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
	psvelo $2/Def.sta.data -G$cyan -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi

# Plot strain vectors
if   [ ${13} = 1 ];
then
     psvelo $1/Str.sta.data -G$ocean -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${13} = 2 ];	
then
     psvelo $2/Str.sta.data -G$ocean -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${13} = 3 ];
then
     psvelo $1/Str.sta.data -G$ocean -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
     psvelo $2/Str.sta.data -G$ocean -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi

# Plot triangle vectors
if   [ ${14} = 1 ];
then
    psvelo $1/Tri.sta.data -G$orange -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${14} = 2 ];	
then
	psvelo $2/Tri.sta.data -G$orange -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
elif [ ${14} = 3 ];
then
	psvelo $1/Tri.sta.data -G$orange -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
	psvelo $2/Tri.sta.data -G$orange -Se0.02i/0/0 -R -Jm -O -K >> $1/out.ps
fi
 

# # Plot residual improvement
# if   [ ${16} = 1 ];
# then
#    # Res.imp is a file written to the results directory that contains columns:
#    # lon. | lat. | color string | size
# 	psxy $1/Res.imp -R -Jm -Sc -R -Jm -O -K >> $1/out.ps
# fi


open /Applications/Preview.app $1/out.ps
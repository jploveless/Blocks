Blocks
======

Present-day deformation at plate boundary zones, recorded as GPS velocities, reflects the combination of plate motion and elastic strain accumulation. This suite of codes implements the block modeling methodology described by:

Meade, B.J. and J.P. Loveless (2009), Block modeling with multiple fault network geometries and a linear elastic coupling estimator in spherical coordinates, *Bulletin of the Seismological Society of America*, 99(6), 3124–3139, [doi:10.1785/0120090088](https://dx.doi.org/10.1785/0120090088).

Blocks is designed for use with Matlab R2014b and later. 

Documentation (evolving) can be found on the [**Blocks** wiki](https://github.com/jploveless/Blocks/wiki) and in a [Google Doc](https://docs.google.com/document/d/1AJheJrVqPX4yj2hbgysC-H2RkdkfkxvNJQIza1b3u34/edit?usp=sharing).

To get started: 
---------------
Run the following commands on the Matlab command prompt:

```matlab
blockshome = '~/MATLAB/Blocks'; % Edit path to where you placed the Blocks directory
cd(blockshome) 
cd BlocksUtilities
% The next function adds the Blocks subdirectories to your Matlab path. 
% Make sure you have permission to write to pathdef.m.
blockspath(blockshome) 
```

You can create a new template model directory structure using:
```matlab
blocksdirs('~/MATLAB/Blocks/California') 
% Edit path to specify your project name; a new directory will be created if it doesn't exist
```

Then, edit the Blocks geometry files (.segment and .block) using SegmentManager:
```matlab
cd ~/MATLAB/Blocks/California/command
SegmentManager
% Within SegmentManager, click "Load" under "Command file" and load 'model.command'. 
% Use SegmentManager tools to add and modify segment and block properties, saving 
% the geometry files to the ../segment and ../block directories
```

To run the analysis,
```matlab
cd ../result
Blocks('../command/model.command')
% The results will be saved in a newly generated directory in the result directory
```

To view the results,
```matlab
ResultManager
% Load a result directory. If you have more than one set of results, you can compare
% them by loading both a "Result directory" and "Compare directory"
```

SegmentManager interface:
-------------------------
![alt tag](https://cloud.githubusercontent.com/assets/4225359/9386297/d46874ca-4728-11e5-9deb-48899bd91770.png)

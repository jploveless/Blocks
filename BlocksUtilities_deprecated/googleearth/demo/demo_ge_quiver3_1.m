function demo_ge_quiver3_1()%% Demo ge_quiver3


kmlFileName = 'demo_ge_quiver3_1.kml';

mkdir(pwd,'data')
copyfile(fullfile(googleearthroot,'data','elong_cube_blue_lite.dae'),...
         fullfile(pwd,'data','elong_cube_blue_lite.dae'))
copyfile(fullfile(googleearthroot,'data','elong_cube_green_lite.dae'),...
         fullfile(pwd,'data','elong_cube_green_lite.dae'))
copyfile(fullfile(googleearthroot,'data','elong_cube_red_lite.dae'),...
         fullfile(pwd,'data','elong_cube_red_lite.dae'))


N = 60;

t = linspace(0,2*pi,N);

x_red = zeros(N,1);
y_red = linspace(0,90,N);
z_red = 1e5*ones(N,1);

u_red = sin(t);
v_red = zeros(N,1);
w_red = cos(t);

x_green = linspace(0,90,N);
y_green = zeros(N,1);
z_green = 1e5*ones(N,1);

u_green = zeros(N,1);
v_green = sin(t);
w_green = cos(t);

x_blue = 10*sin(t);
y_blue = 10*cos(t);
z_blue = 1e5*ones(N,1);

u_blue = sin(t);
v_blue = cos(t);
w_blue = ones(N,1)*0.5*pi;

d = date;
dnum = datevec( d );
s_red = '';
s_blue = '';
s_green = '';

for n = 1:(N-1)
    
    dnum2 = dnum;
    dnum3 = dnum;
    dnum2(5) = dnum(5) + n;
    dnum3(5) = dnum(5) + n +1;
    dstr = datestr( dnum2, 'yyyy-mm-ddTHH:MM:SSZ');
    dstr2 = datestr( dnum3, 'yyyy-mm-ddTHH:MM:SSZ');   
    
    s_red = [s_red ge_quiver3(x_red(n),y_red(n),z_red(n),u_red(n),v_red(n),w_red(n),...
                            'modelLinkStr','data/elong_cube_red_lite.dae',...
                            'altitudeMode','absolute',...
                            'arrowScale',2.5e6,...
                            'timeSpanStart', char(dstr), ...
                            'timeSpanStop', char(dstr2 ), ...
                            'name', 'quiver3 - red') ];

    s_green = [s_green ge_quiver3(x_green(n),y_green(n),z_green(n),u_green(n),v_green(n),w_green(n),...
                            'modelLinkStr','data/elong_cube_green_lite.dae',...
                            'altitudeMode','absolute',...
                            'arrowScale',2.5e6,...
                            'timeSpanStart', char(dstr), ...
                            'timeSpanStop', char(dstr2 ), ...                            
                            'name', 'quiver3 - green')];

    s_blue = [s_blue ge_quiver3(x_blue(n),y_blue(n),z_blue(n),u_blue(n),v_blue(n),w_blue(n),...
                            'modelLinkStr','data/elong_cube_blue_lite.dae',...
                            'altitudeMode','absolute',...
                            'arrowScale',2.5e6,...
                            'timeSpanStart', char(dstr), ...
                            'timeSpanStop', char(dstr2 ), ...                            
                            'name', 'quiver3 - blue') ];
    
end

s_redf = ge_folder('red', s_red);
s_greenf = ge_folder('green', s_green);
s_bluef = ge_folder('blue', s_blue);
ge_output(kmlFileName,[s_redf,s_greenf,s_bluef]);%,s_yellow])


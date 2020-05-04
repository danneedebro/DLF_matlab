dt=0.0005;
t_end=1;
time = 0:dt:t_end;
force_pulse=zeros(size(time));
force_pulse(round(0.4/dt):round(0.6/dt))=1000;

t_rise=0.001;
t_start=0.1;
t_width=0.010
t=[0,t_start,t_start+t_rise,t_start+t_rise+t_width,t_start+t_rise+t_width+t_rise,100]
f=[0,0,1000,1000,0,0];


force=interp1(t,f,time);

figure;
plot(time,force)

fn=inputdlg({'Enter filename for TFUN file name:'},'Filename?',1,{'Force.pipestress'});

fileID = fopen(fn{1},'w');
fprintf(fileID,'TFUN CV_101\n');
for i = 1:length(time)
    fprintf(fileID,'%6.4f %6.2f\n',time(i),force(i));
end
fprintf(fileID,'-1.E11\n');
fclose(fileID);


fprintf(2,'In FHFILE5.EXE\nUse Default.CM2 in first imput and %s as second. \nSave as thist file XXXX.thf\n',fn{1});

system('FHFILE5.exe');

fprintf(2,'In SPECT.EXE\nRun on component 1 in XXXX.thf\n');

system('SPECT.exe');
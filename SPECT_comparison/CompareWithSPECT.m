close ALL





load SPECT_sine1.mat

Sine1 = ClassDLF(SPECT_Sine1.TimeVector,SPECT_Sine1.ForceVector,'cutoff',200,'dfmin',0.25);
plot(Sine1.Frequency,Sine1.DLF,'-x',SPECT_Sine1.Frequency,SPECT_Sine1.DLF,'o')
legend('ClassDLF','SPECT.exe');
title('1000*sin(2*pi*t), 5% damping');
xlabel('Frequency (Hz)');
ylabel('DLF');

PlotIt('Sine1.png');


load SPECT_step1.mat

Step1 = ClassDLF(SPECT_Step1.TimeVector,SPECT_Step1.ForceVector,'cutoff',200);
plot(Step1.Frequency,Step1.DLF,'-x',SPECT_Step1.Frequency,SPECT_Step1.DLF,'o')
legend('ClassDLF','SPECT.exe');
title('Step function, start=0.1s, Rise time=0.010s, dt=0.0005s, 5% damping');
xlabel('Frequency (Hz)');
ylabel('DLF');

PlotIt('Step1.png')


load SPECT_step2.mat

Step2 = ClassDLF(SPECT_Step2.TimeVector,SPECT_Step2.ForceVector,'cutoff',200);
plot(Step2.Frequency,Step2.DLF,'-x',SPECT_Step2.Frequency,SPECT_Step2.DLF,'o')
legend('ClassDLF','SPECT.exe');
title('Step function, start=0.1s, Rise time=0.001s, dt=0.0005s, 5% damping');
xlabel('Frequency (Hz)');
ylabel('DLF');

PlotIt('Step2.png')


load SPECT_pulse1.mat

Pulse1 = ClassDLF(SPECT_Pulse1.TimeVector,SPECT_Pulse1.ForceVector,'cutoff',200);
plot(Pulse1.Frequency,Pulse1.DLF,'-x',SPECT_Pulse1.Frequency,SPECT_Pulse1.DLF,'o')
legend('ClassDLF','SPECT.exe');
title('Pulse function, start=0.1s, Rise time=0.001s, Pulse width=0.01s, dt=0.0005s, 5% damping');
xlabel('Frequency (Hz)');
ylabel('DLF');

PlotIt('Pulse1.png')

fileID = fopen('Readme.md','w');
fprintf(fileID,'#sin(2*pi*5*t), 5%% damping\n');
fprintf(fileID,'![Image description](Sine1.png)\n');

fprintf(fileID,'#Step function 1, t_start=0.1s, t_rise=0.010s, 5%% damping\n');
fprintf(fileID,'![Image description](Step1.png)\n');

fprintf(fileID,'#Step function 2, t_start=0.1s, t_rise=0.001s, 5%% damping\n');
fprintf(fileID,'![Image description](Step2.png)\n');

fprintf(fileID,'#Pulse function, t_start=0.1s, t_rise=0.001s, t_width=0.01s, 5%% damping\n');
fprintf(fileID,'![Image description](Pulse1.png)\n');

fclose(fileID);


function PlotIt(filename)
    set(gcf,'PaperUnits','centimeters')
    set(gcf,'PaperType','a3')   
    % set(gcf,'PaperOrientation','landscape')
    set(gcf,'PaperPosition',[0.0 0.0 29.3046 20.2284]);
    print(gcf,filename,'-dpng','-r600')
end
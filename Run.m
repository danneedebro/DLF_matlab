dt=0.0005;
t_end=1;
time = 0:dt:t_end;
force_pulse=zeros(size(time));
force_pulse(round(0.4/dt):round(0.6/dt))=1;
force_sine1=sin(2*pi*5*time);
force_sine2=0.5*sin(2*pi*5*time)+0.5*sin(2*pi*10*time);

force1 = ClassDLF(time,force_pulse);
force2 = ClassDLF(time,force_sine1);
force3 = ClassDLF(time,force_sine2);


force1.Plot();
figure;
force2.Plot();
figure;
force3.Plot()
figure;
force1.Plot(force2,force3);
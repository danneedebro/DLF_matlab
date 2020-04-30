time = 0:0.001:1;
force_pulse=zeros(size(time));
force_pulse(400:450)=1;
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
force1.Plot(Figure2,Figure3);
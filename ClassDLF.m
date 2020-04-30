classdef ClassDLF < handle
    %ClassDLF Calculates the Dynamic Load Factor for a force
    %   
    %  Example: Make a DLF plot of the force sin(2*pi*f*t)
    %   time = 0:0.001:1;
    %   force = sin(2*pi*5*time);
    %   force1 = ClassDLF(time,force);
    %   force1.Plot();
    %
    %  Example: Compare two forces
    %   time = 0:0.001:1;
    %   forceA = sin(2*pi*5*time);
    %   forceB = 0.5*sin(2*pi*5*time)+0.5*sin(2*pi*10*time);
    %   force1 = ClassDLF(time,forceA);
    %   force2 = ClassDLF(time,forceB);
    %   force1.Plot(force2);
    %
    
    
    properties
        ForceVector         % A vector containing the force
        TimeVector          % A vector with the time
        Frequency           % A vector with the frequencies
        DLF                 % A vector with the Dynamic Load Factor
        DampingFactor       % A number between 0-1 for the damping (0.05)
        CutoffFrequency     % How high frequency
        ForceMax            % Max force amplitude
        Tolerance           % The relative tolerance of the solution
        MaxStep             % Max step size for ode solver
    end
    
    methods
        function obj = ClassDLF(timeVector, forceVector)
            %ClassDLF Creates a DLF object from a time and force vector
            %
            %   Example: Make a DLF plot of the force sin(2*pi*f*t)
            %
            %   time = 0:0.001:1;
            %   force = sin(2*pi*5*time);
            %   force1 = ClassDLF(time,force)
            %   plot(force1.TimeVector,force1.DLF)
            %
            obj.TimeVector = timeVector;
            obj.ForceVector = forceVector;
            obj.ForceMax = max(abs(forceVector));
            obj.DampingFactor = 0.05;
            obj.CutoffFrequency = 75;
            obj.Tolerance = 1.0e-5;
            obj.MaxStep = min(diff(timeVector));
            obj.Frequency = [0,1,obj.CutoffFrequency/2,obj.CutoffFrequency];
            obj.DLF = zeros(size(obj.Frequency));
            obj.GetDLF();
            obj.SmartRefine();
        end
        
        function GetDLF(obj)
            % Calculates the DLF for all frequencies in obj.Frequency
            fprintf('\n');
            obj.DLF = zeros(size(obj.Frequency));
            for i = 2:length(obj.Frequency)
                obj.DLF(i) = obj.CalculateDLFs(obj.Frequency(i));
            end
        end
        
        function RefineInterval(obj,f1,f2)
            % Refine the DLF inbetween f1 and f2
            ind1=find(obj.Frequency>=f1,1);
            ind2=find(obj.Frequency>=f2,1);
            new_f = [];
            for i=ind1:ind2
                new_f(end+1)=0.5*(obj.Frequency(i)+obj.Frequency(i+1));
            end
            new_DLF = obj.CalculateDLFs(new_f);
            obj.Frequency = [obj.Frequency,new_f];
            obj.DLF = [obj.DLF,new_DLF];
            [obj.Frequency,indexes] = sort(obj.Frequency);
            obj.DLF = obj.DLF(indexes);
        end
        
        function SmartRefine(obj)
            % Sweeps through all frequencies and refines if point i+1
            % differs more than X% than: 
            %       DLF(i) = DLF(i) + d/df DLF * (f(i+1)-f(i))
            
            f = obj.Frequency;
            DLF = obj.DLF; %#ok<*PROP>
            
            
            fprintf('Starting with %d frequiencies\n',length(f));
            
            % Refine with two nested loops. If the innermost loop doesn't
            % add any frequency the outer loop is stopped.
            outerloop = 1;
            while outerloop == 1
                
                outerloop = 0;
                innerloop = 1;
                i = 1;
                f_added = [];
                while innerloop == 1
                    i = i + 1;
            
                    df1 = f(i)-f(i-1);
                    df2 = f(i+1)-f(i);
                    dDLFdt = (DLF(i)-DLF(i-1))/(df1);
                    DLF_predictor = DLF(i) + dDLFdt*df2;

                    pause(0.3);

                    % If DLF(i+1) based on derivate differs more than X% calculate a new DLF 
                    if abs(DLF(i+1)-DLF_predictor)/DLF(i+1) > 0.05 && df2 > 0.5
                        outerloop = 1;  % if frequency is added, run outer loop once more
                        f_new = f(i)+df2/2;
                        f_added(end+1) = f_new;
                        DLF_new = obj.CalculateDLFs(f_new);
                        f = [f,f_new];
                        DLF = [DLF,DLF_new];
                        [f,indexes] = sort(f);
                        DLF = DLF(indexes);
                    end

                    if i >= length(f)-1
                        innerloop = 0;
                        fprintf('Sweep: Added ');
                        fprintf('%5.2f Hz,',f_added);
                        fprintf('\n');
                    end
                    
                end % inner loop
            end % outer loop
            
            obj.Frequency =  f;
            obj.DLF = DLF;
        end
        
        function AppendFrequency(obj,f)
            % Adds/inserts the frequency f to obj.Frequency and calculates
            % the DLF
            ind=find(obj.Frequency >= f,1);

            % If f > max(obj.Frequency) - place last
            if isempty(ind)   
                obj.Frequency(end+1) = f;
                obj.DLF(end+1) = obj.CalculateDLF(f);
            % If f doesn't already exists in obj.Frequency
            elseif obj.Frequency(ind) ~= f   
                obj.Frequency = [obj.Frequency(1:ind-1),f,obj.Frequency(ind:end)];
                obj.DLF = [obj.DLF(1:ind-1),obj.CalculateDLF(f),obj.DLF(ind:end)];
            % If f already exists in obj.Frequency - do nothing
            else
                return;
            end
        end
        
        function DLF=CalculateDLF(obj,f)
            % Calculates the DLF for a given frequency
            
            k = obj.ForceMax/0.1;
%             k = 1e3;
            wn=2*pi*f;
            mn=k/wn^2;
            
            tSpan = [obj.TimeVector(1), obj.TimeVector(end)]; % Solve from t=1 to t=5
            options = odeset('RelTol',obj.Tolerance,'MaxStep',obj.MaxStep);
            [~, Y] = ode45(@(t,y) obj.springEq1(t,y,mn,wn),tSpan,[0 0],options); % Solve ODE
            
            yMax = max(abs(Y(:,1)));
            yMaxStatic = obj.ForceMax/k;
            DLF = yMax/yMaxStatic;
        end
        
        function DLFs=CalculateDLFs(obj,f)
            % Calculates the DLF for a given frequency
            
            DLFs=zeros(size(f));
            
            k = obj.ForceMax/0.1;
            wn=2*pi*f;
            mn=k./wn.^2;
            yMaxStatic = obj.ForceMax/k;
            
            for i = 1:length(f)
                if isinf(mn(i)), continue; end
                tSpan = [obj.TimeVector(1), obj.TimeVector(end)]; % Solve from t=1 to t=5
                options = odeset('RelTol',obj.Tolerance,'MaxStep',obj.MaxStep);
                [~, Y] = ode45(@(t,y) obj.springEq1(t,y,mn(i),wn(i)),tSpan,[0 0],options); % Solve ODE
                
                yMax = max(abs(Y(:,1)));
                DLFs(i) = yMax/yMaxStatic;
            end
        end
        
        function [time,disp] = Displacement(obj,f,k)
            % Returns the time dependant displacement as a function of time
            % when obj.ForceVector is applied to a system with natural
            % frequency f.
            nargin
            if nargin < 3
                k = 1e3;
            end
            wn=2*pi*f;
            mn=k/wn^2;
            tSpan = [obj.TimeVector(1), obj.TimeVector(end)]; % Solve from t=1 to t=5
            options = odeset('RelTol',obj.Tolerance,'MaxStep',obj.MaxStep);
            [time, Y] = ode45(@(t,y) obj.springEq1(t,y,mn,wn),tSpan,[0 0],options); % Solve ODE
            disp = Y(:,1);
        end
        
        function Plot(obj,varargin)
            % Plot the force and DLF
            subplot(2,1,1)
            plot_force = plot(obj.TimeVector,obj.ForceVector);
            plot_force.Parent.YLabel.String = 'Force (N)';
            plot_force.Parent.XLabel.String = 'Time (s)';
            
            for i = 1:nargin-1
                hold on
                plot(varargin{i}.TimeVector,varargin{i}.ForceVector);
            end
            hold off
            
            subplot(2,1,2)
            if isempty(varargin)
                plot_DLF = plot(obj.Frequency,obj.DLF,'-o');
            else
                plot_DLF = plot(obj.Frequency,obj.DLF*obj.ForceMax,'-o');
            end
            
            for i=1:nargin-1
                hold on
                plot(varargin{i}.Frequency,varargin{i}.DLF*varargin{i}.ForceMax,'-o')
            end
            hold off
            
            ax1=plot_DLF.Parent;
            ax1.XLabel.String='Frequency (Hz)';
            
            % If only one force - plot both DLF expressed in relative terms
            % and absolute (as a equivalent force)
            if isempty(varargin)
                ax2 = axes('Position',ax1.Position,'XAxisLocation','top',...
                    'YAxisLocation','right',...
                    'Color','none','YLim',ax1.YLim*obj.ForceMax);
                ax2.XTickLabel={''};
                ax2.YTick =ax1.YTick*obj.ForceMax;
                ax2.YTickLabelMode='auto';
                ax2.YLabel.String='F_{equiv} (N)';
                ax1.YLabel.String='DLF = x_{max}/x_{max,static} (-)';
            else
                ax1.YLabel.String='F_{equiv} (N)';
            end
        end
        
        
        function dy = springEq1(obj,t,y,mn,wn)
            % The spring equation rewritten as a system of diff eqns

            Ft=interp1(obj.TimeVector,obj.ForceVector,t);

            dy = zeros(2,1);
            dy(1) = y(2);
            dy(2) = Ft/mn-2*obj.DampingFactor*wn*y(2)-wn^2*y(1);
        end
        
    end

end


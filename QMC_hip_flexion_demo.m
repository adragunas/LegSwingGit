function [xdata ydata] = QMC_hip_flexion_demo(n)        % n is the amount of frames the demo should retrieve before disconnecting.

qtm = QMC('QMC_conf.txt'); % Creates the objecthandle 'qtm' which keeps the connection alive.

the3dlabels = QMC(qtm, '3dlabels'); % char matrix
labels = deblank(string(the3dlabels)); % Convert to string array

% % Mapping of labels (logical index to 3D data)
i_upper = 16;
i_joint = 32;
i_lower = 22;

% Initialize figure
% Figure Parameters
nframes = 500;
margin = 50;
ylim = [50 150];

% Plot data
ydata = nan(n,1);
xdata = nan(n,1);

% Set-up figure
figure;
hax = axes('Nextplot','add','XLim',[-500 nframes+margin],'YLim',ylim);
hline = plot(xdata,ydata,'LineWidth',2);
ylabel('Flexion - Extension (deg)')
xlabel('Frames')

drawnow

% State variables
skipped_frames=0;
last_frame = nan;
last_flex = nan;

% Real time loop
for i = 1:n
    % Fetch data from QTM
    [frameinfo data] = QMC(qtm); % Gather data from QTM. This configuration gets the frame info and
                                 % three different types of data from QTM. Note that the number of
                                 % data types must be the same as in the config-file.
    current_frame = frameinfo(1);
    
    % Calculate lines and angle

    pelvis = data(:,i_joint)-data(:,i_upper);
    thigh = data(:,i_joint)-data(:,i_lower);
    flexion = (acos(dot(pelvis/norm(pelvis),thigh/norm(thigh))));
    
    % Update plot data
    ydata(i)=flexion*180/pi;
    xdata(i) = i;
    hline.XData = xdata;
    hline.YData = ydata;
    hax.XLim = [-500+i nframes+margin+i];
    
    refreshdata(hline)
    refreshdata(hax)
    drawnow
    
end

QMC(qtm, 'disconnect'); % Terminates the QMC-object.

clear mex
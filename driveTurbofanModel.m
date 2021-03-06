% Drive the turbofanF100 function and make some interesting plots.
% SI units are used for every parameter, except for altitude (in
% feet), and sfc (in lb/lbf/hr). Sorry for mixing units.
%
% Rick Fenrich 7/23/15, modified 10/15/15

% =========================== SET INPUTS =================================

altitude = 0;%35000; % in feet
mach = 0;%0.9;

% =================== SET ERROR TOLERANCE RANGES =========================
% Set error tolerances for various iterations and solvers
error.betweenIterations.inletMach = 1e-8;
error.solver.inletMach = 1e-8;
error.betweenIterations.exitTemp = 1e-6;
error.solver.apparentThroatLocation = 1e-6;
error.solver.M2relative = 1e-10;
error.solver.M2absolute = 1e-10;
error.dMdxDenominator = 4; % this is not an error tolerance, rather it is used to set the slope of dMdx in the transonic regime

% ======================= INITIALIZE CONTROLS ============================
% If a control is set to zero then turbofanF100.m will
% assume a typical value for that parameter; otherwise, it will use the
% parameter value that the user provides.

% -------------------------- ENGINE CONTROLS -----------------------------

control.bypassRatio = 0;
control.f = 0;
control.fan.PstagRatio = 0;
control.fan.efficiency.polytropic = 0;
control.compressor.efficiency.polytropic = 0;
control.compressor.overallPressureRatio = 0;
control.burner.PstagRatio = 0;
control.burner.efficiency = 0;
control.turbine.TstagLimit = 0;
control.turbine.efficiency.polytropic = 0;
control.turbine.efficiency.shaft = 0;

% ---------------------- NOZZLE GEOMETRY CONTROLS ------------------------

control.nozzle.geometry.shape = 'B-spline-mex';
control.nozzle.inlet.D = 0; % m
control.nozzle.geometry.Ainlet2Athroat = 0;
control.nozzle.geometry.Aexit2Athroat = 0;
control.nozzle.geometry.length = 1;
control.nozzle.geometry.xThroat = 0.33;

if(strcmp(control.nozzle.geometry.shape,'spline'))
    % To parameterize using a spline, the following must be provided:
    % nozzle.spline.seed = either a shape already defined in the
    % nozzleGeometry.m file or an array of the form [x,y] where [x_i,y_i]
    % denote the location of the control points with the origin being at
    % the center of the inlet area
    % nozzle.spline.controlPointSpacing = either 'regular' where control
    % points will be evenly spaced or a vector giving the x-location
    % nozzle.spline.slopes = 1x2 array; 1st argument is slope of inlet,
    % 2nd argument is slope of outlet
    control.nozzle.geometry.spline.seed = ...%'linear';
                                        [0, 0.3255; 
                                         0.33, 0.2783;
                                         1, 0.3293];
    % Recalculate area ratios/inlet geometry if necessary from the spline seed:
    % control.nozzle.geometry.Ainlet2Athroat = (0.3255+0.1)^2/0.2783^2; % area ratio of inlet to throat
    % control.nozzle.geometry.Aexit2Athroat = 0.3293^2/0.2783^2; % area ratio of exit to throat
    % control.nozzle.inlet.D = (0.3255+0.1)*2;
    control.nozzle.geometry.spline.breaks = ...
            [0;
            control.nozzle.geometry.xThroat;
            control.nozzle.geometry.length];
    control.nozzle.geometry.spline.slopes = [0, 0];
elseif(strcmp(control.nozzle.geometry.shape,'B-spline') || strcmp(control.nozzle.geometry.shape,'B-spline-mex'))
    % B-spline geometry defined by knots vector and coefficients matrix
	knots = [0 0 0 0 1:12 13 13 13 13]';
% 	coefs = [0.0000 0.0000 0.1500 0.1700 0.1900 0.2124 0.2269 0.2734 0.3218 0.3343 0.3474 0.4392 0.4828 0.5673 0.6700 0.6700;
%              0.3255 0.3255 0.3255 0.3255 0.3255 0.3238 0.2981 0.2817 0.2787 0.2790 0.2804 0.2936 0.2978 0.3049 0.3048 0.3048];
	coefs = [0.0000 0.0000 0.1500 0.1700 0.1900 0.2124 0.2269 0.2734 0.3218 0.3343 0.3474 0.4392 0.4828 0.5673 0.6700 0.6700;
             0.3255 0.3255 0.3255 0.3255 0.3255 0.3238 0.2981 0.2817 0.2789 0.2790 0.2804 0.2936 0.2978 0.3049 0.3048 0.3048];
    % Determine nozzle throat
    control.nozzle.geometry.bSpline.degree = length(knots) - length(coefs) - 1;
    if(control.nozzle.geometry.bSpline.degree == 2)
        [xThroat, yThroat] = BsplineGeometry(0, 'throat', knots, coefs);
    elseif(control.nozzle.geometry.bSpline.degree == 3)
        [xThroat, yThroat] = BsplineGeometry3(0, 'throat', knots, coefs);        
    end
    control.nozzle.geometry.xThroat = xThroat;

    % Define other geometry parameters
    control.nozzle.geometry.length = coefs(1,end);
    control.nozzle.inlet.D = coefs(2,1)*2;
    control.nozzle.geometry.Ainlet2Athroat = (control.nozzle.inlet.D/2)^2/yThroat^2;
    control.nozzle.geometry.Aexit2Athroat = (coefs(2,end))^2/yThroat^2;
 
    control.nozzle.geometry.bSpline.knots = knots;
    control.nozzle.geometry.bSpline.coefs = coefs;
end

control.nozzle.inlet.Abypass2Acore = 0;
control.nozzle.throat.A = 0; % m^2

% -------------------- SET NOZZLE WALL GEOMETRY --------------------------
control.nozzle.wall.shape = 'piecewise-linear';
% nozzle.wall.seed = an array of the form [x; y] where [x,y]
% denote the location of the control points with the origin being at
% the center of the inlet area
% nozzle.wall.breaks = vector giving location of breaks in piecewise
% function
control.nozzle.wall.seed = [0, 0.01; 
                    control.nozzle.geometry.xThroat, 0.01; 
                    control.nozzle.geometry.length, 0.01];
control.nozzle.wall.breaks = [0;
                      control.nozzle.geometry.xThroat;
                      control.nozzle.geometry.length];
                 
% ----------------------- RUN SIMPLE TEST CASE ---------------------------
tic
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
toc
fprintf('\n')
fprintf('thrust: %f N\n',thrust.total);
fprintf('sfc: %f lb/lbf/hr\n',sfc);
fprintf('mass flow rate: %f kg/s\n',engine.nozzle.massFlowRate);
fprintf('thermal efficiency: %f\n',thermalEfficiency);
fprintf('nozzle is: %s\n',engine.nozzle.status);
fprintf('nozzle Pstag ratio: %f\n',engine.nozzle.PstagRatio);
fprintf('nozzle Tstag ratio: %f\n',engine.nozzle.TstagRatio);
fprintf('fan exit Mach: %f\n',engine.fan.exit.M);

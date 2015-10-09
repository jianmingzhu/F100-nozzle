% Drive the turbofanF100 function and make some interesting plots.
% SI units are used for every parameter, except for altitude (in
% feet), and sfc (in lb/lbf/hr). Sorry for mixing units.
%
% Rick Fenrich 7/23/15, modified 7/31/15

% =========================== SET INPUTS =================================

altitude = 35000; % in feet
mach = 0.9;
delta = 1e-4; % absolute delta used in forward finite difference calculation
rel_delta = 1e-2;

% =================== SET ERROR TOLERANCE RANGES =========================
error.betweenIterations.inletMach = 1e-10;
error.solver.inletMach = 1e-8;
error.betweenIterations.exitTemp = 1e-6;
error.solver.apparentThroatLocation = 1e-6;
error.solver.M2relative = 1e-10;
error.solver.M2absolute = 1e-10;
error.dMdxDenominator = 4;

% ======================= INITIALIZE CONTROLS ============================
% If a control is set to zero then turbofanF100.m will
% assume a typical value for that parameter; otherwise, it will use the
% parameter value that the user provides.

control.bypassRatio = 0.6;
control.fan.PstagRatio = 3.06;
control.fan.efficiency.polytropic = 0.83;
control.compressor.efficiency.polytropic = 0.87;
control.compressor.overallPressureRatio = 24.5;
control.burner.PstagRatio = 0.95;
control.burner.efficiency = 0.95;
control.turbine.efficiency.polytropic = 0.85;
control.turbine.efficiency.shaft = 0.97;
control.nozzle.inlet.Abypass2Acore = 0.2962;

control.f = 0;

control.nozzle.inlet.D = 0; % m
control.nozzle.throat.A = 0; % m^2

control.nozzle.Ainlet2Athroat = 1.368;
control.nozzle.Aexit2Athroat = 1.4;

nominalControl = control; % save original control settings

% ----------------------- RUN SIMPLE TEST CASE ---------------------------

% Open file for writing data to
fid = fopen('finiteDifference_sensitivity.txt','a');
fprintf(fid,'Finite difference sensitivity for F100-PW-220 model\n');
fprintf(fid,'%s\n',datestr(now));
fprintf(fid,'altitude: %f, mach: %f, delta: %e\n',altitude,mach,delta);

% Run nominal case
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );

fprintf(fid,'parameter \t thrust \t sfc \t mdot \t eta \t PstagRatio \t TstagRatio \n');
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'nominal', thrust.total, sfc, engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Run all non-nominal cases

% Bypass ratio
control = nominalControl;
%control.bypassRatio = control.bypassRatio + delta;
control.bypassRatio = (1+rel_delta)*control.bypassRatio;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'bypassRatio', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Fan Pstag Ratio
control = nominalControl;
%control.fan.PstagRatio = control.fan.PstagRatio + delta;
control.fan.PstagRatio = (1+rel_delta)*control.fan.PstagRatio;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'fanPstagRatio', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Fan polytropic efficiency
control = nominalControl;
%control.fan.efficiency.polytropic = control.fan.efficiency.polytropic + delta;
control.fan.efficiency.polytropic = (1+rel_delta)*control.fan.efficiency.polytropic;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'fanEfficiency', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Compressor polytropic efficiency
control = nominalControl;
%control.compressor.efficiency.polytropic = control.compressor.efficiency.polytropic + delta;
control.compressor.efficiency.polytropic = (1+rel_delta)*control.compressor.efficiency.polytropic;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'compressorEfficiency', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Compressor overall pressure ratio
control = nominalControl;
%control.compressor.overallPressureRatio = control.compressor.overallPressureRatio + delta;
control.compressor.overallPressureRatio = (1+rel_delta)*control.compressor.overallPressureRatio;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'OPR', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Burner Pstag Ratio
control = nominalControl;
%control.burner.PstagRatio = control.burner.PstagRatio + delta;
control.burner.PstagRatio = (1+rel_delta)*control.burner.PstagRatio;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'burnerPstagRatio', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Burner Efficiency
control = nominalControl;
%control.burner.efficiency = control.burner.efficiency + delta;
control.burner.efficiency = (1+rel_delta)*control.burner.efficiency;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'burnerEfficiency', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Turbine Efficiency
control = nominalControl;
%control.turbine.efficiency.polytropic = control.turbine.efficiency.polytropic + delta;
control.turbine.efficiency.polytropic = (1+rel_delta)*control.turbine.efficiency.polytropic;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'turbineEfficiency', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Turbine Shaft Efficiency
control = nominalControl;
%control.turbine.efficiency.shaft = control.turbine.efficiency.shaft + delta;
control.turbine.efficiency.shaft = (1+rel_delta)*control.turbine.efficiency.shaft;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'turbineShaftEfficiency', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

% Bypass area to core area ratio
control = nominalControl;
%control.nozzle.inlet.Abypass2Acore = control.nozzle.inlet.Abypass2Acore + delta;
control.nozzle.inlet.Abypass2Acore = (1+rel_delta)*control.nozzle.inlet.Abypass2Acore;
[ thrust, sfc, thermalEfficiency, engine ] = turbofanF100( altitude, mach, control, error );
fprintf(fid,'%s \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \t %1.12f \n', ...
    'Abypass2Acore', thrust.total, sfc, ...
    engine.nozzle.massFlowRate, thermalEfficiency, ...
    engine.nozzle.PstagRatio, engine.nozzle.TstagRatio);

fclose(fid);

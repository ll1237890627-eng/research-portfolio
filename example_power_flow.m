%% example_power_flow.m 
%Demonstrate how to use the model for power flow analysis
clear; clc;

fprintf('========================================\n');
fprintf(' Example: IEEE 33-Bus Power Flow Calculation\n');
fprintf('========================================\n\n');

%% 1. Initialize system
init_IEEE33;

%% 2.Run power flow calculation
fprintf('Running load flow calculation...\n');
model_name = 'IEEE33_benchmark';

% Set up a short-time simulation to quickly achieve steady state
set_param(model_name, 'StopTime', '0.5');
simOut = sim(model_name);

fprintf('Trend calculation completed\n\n');

%% 3. Show results
fprintf('========================================\n');
fprintf('  Load Flow Calculation Results\n');
fprintf('========================================\n');

% Add your result display code here
fprintf('\nExample run completed！\n');

%% run_simulation.m - Run Simulation of IEEE 33-Bus System
% Purpose: Automate the simulation process and save the results
% Usage: Type run_simulation in the MATLAB command window to run. 
clear; clc;

Initializing system... \n');
init_IEEE33;

2. Check the model file model_name = 'IEEE33_benchmark';
if ~exist([model_name '.slx'], 'file')
    error('Error: Model file %s.slx not found', model_name);
end end

%% 3. Load the model
fprintf('\nLoading the Simulink model...') \n');
load_system(model_name);
fprintf('✓ Model loaded successfully\n'); 
%% 4. Configure Simulation Parameters
fprintf('\nConfiguring simulation parameters...') \n');
set_param(model_name, 'Solver', sim_params.solver);
set_param(model_name, 'StopTime', num2str(sim_params.stop_time));
set_param(model_name, 'MaxStep', num2str(sim_params.max_step));
set_param(model_name, 'RelTol', num2str(sim_params.rel_tol));
fprintf('✓ Simulation parameter configuration completed\n'); 
5. Run the simulation fprintf('\n========================================\n');
fprintf('Simulation begins\n'); fprintf('========================================\n');
tic;
simOut = sim(model_name);
elapsed_time = toc;

fprintf('\n✓ Simulation completed!') \n');
fprintf('Simulation time elapsed: %.2f seconds\n', elapsed_time); 
%% 6. Extracting Results
fprintf('\nExtracting simulation results...') \n');
```matlab
try
    % Adjust the output port name based on your model
    results.time = simOut.tout;  % If you used the To Workspace block in your model
    if evalin('base', 'exist(''bus_voltages'', ''var'')')
        results.bus_voltages = evalin('base', 'bus_voltages');
    end
end
``` end  if evalin('base', 'exist(''line_currents'', ''var'')') results.line_currents = evalin('base', 'line_currents'); end  if evalin('base', 'exist(''power_flow'', ''var'')') results.power_flow = evalin('base', 'power_flow'); try
    fprintf('✓ Result extraction successful\n');
catch ME
    warning('Warning during result extraction: %s', ME.message);
    fprintf(' Please ensure that the correct output ports are configured in the model\n');
end end

7. Save the results timestamp = datestr(now, 'yyyymmdd_HHMMSS');
result_filename = sprintf('results/simulation_results_%s.mat', timestamp);

% Create the "results" folder if it does not exist. if ~exist('results', 'dir') mkdir('results');
end

save(result_filename, 'results', 'sim_params', 'elapsed_time');
fprintf('\n✓ Results have been saved to: %s\n', result_filename); 
%% 8. Quick Analysis fprintf('\n========================================\n');
fprintf('Quick Analysis\n'); fprintf('========================================\n');

if isfield(results, 'bus_voltages') % Calculate steady-state voltage (using the last 10% of the data) steady_start = round(0.9 * length(results.time)); steady_voltages = mean(results.bus_voltages(steady_start:end, :), 1);  fprintf('Voltage statistics:\n'); fprintf(' Minimum voltage: %.4f p.u. (Node %d)\n', ... min(steady_voltages), find(steady_voltages == min(steady_voltages), 1)); fprintf('Maximum voltage: %.4f p.u. (Node %d)\n', ... max(steady_voltages), find(steady_voltages == max(steady_voltages), 1)); fprintf('Average voltage: %.4f p.u.\n', mean(steady_voltages)); end

fprintf('\n========================================\n');
Simulation completed. fprintf('========================================\n');
fprintf('Next step: Run analyze_results for detailed analysis\n\n');

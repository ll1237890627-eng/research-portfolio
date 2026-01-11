%% sensitivity_analysis.m - PV Penetration Sensitivity Analysis
% Corresponding paper Section III.D, Figure 3

clear; clc;

fprintf('========================================\n');
fprintf('  PV Penetration Sensitivity Analysis\n');
fprintf('========================================\n\n');

%% Set the range of PV capacity variation
pv_scaling_factors = [0.8, 0.9, 1.0, 1.1, 1.2];  % 40% ~ 60%Penetration rate
n_cases = length(pv_scaling_factors);

% Initialize result storage
sensitivity_results = struct();
sensitivity_results.scaling = pv_scaling_factors;
sensitivity_results.case1 = zeros(n_cases, 1);
sensitivity_results.case2 = zeros(n_cases, 1);
sensitivity_results.case3 = zeros(n_cases, 1);

%% Loop simulation
for i = 1:n_cases
    scale = pv_scaling_factors(i);
    fprintf('\n[%d/%d] PV capacity scaling: %.1f (Penetration rate approximately %.0f%%)\n', ...
            i, n_cases, scale, scale*50);
    
    % Initialize system
    init_voltage_control;
    
    % Adjust PV capacity
    pv_data_pu(:, 2) = pv_data_pu(:, 2) * scale;
    pv_profiles(:, 4) = pv_profiles(:, 4) * scale;
    
    %% Case 1: Uncontrolled
    fprintf('  Run Case 1...');
    oltc_config.enable = false;
    inverter_config.enable_Qdroop = false;
    
    simOut1 = sim('IEEE33_voltage_control', 'StopTime', '86400');
    res1 = extract_results(simOut1);
    sensitivity_results.case1(i) = res1.max_voltage_deviation;
    fprintf(' Completed \n');
    
    %% Case 2: OLTC only
    fprintf('  Run Case 2...');
    oltc_config.enable = true;
    inverter_config.enable_Qdroop = false;
    
    simOut2 = sim('IEEE33_voltage_control', 'StopTime', '86400');
    res2 = extract_results(simOut2);
    sensitivity_results.case2(i) = res2.max_voltage_deviation;
    fprintf(' 完成\n');
    
    %% Case 3: Coordinated Control
    fprintf('  Run Case 3...');
    oltc_config.enable = true;
    inverter_config.enable_Qdroop = true;
    
    simOut3 = sim('IEEE33_voltage_control', 'StopTime', '86400');
    res3 = extract_results(simOut3);
    sensitivity_results.case3(i) = res3.max_voltage_deviation;
    fprintf(' Completed \n');
end

%% Save results
save('results/sensitivity_analysis.mat', 'sensitivity_results');

%% Plot the sensitivity curve (Figure 3 in the paper)
figure('Name', 'PV Penetration Sensitivity Analysis', 'Position', [100, 100, 1000, 600]);

penetration = pv_scaling_factors * 50;  % Penetration rate%

hold on;
plot(penetration, sensitivity_results.case1 * 100, '-o', ...
     'LineWidth', 2.5, 'MarkerSize', 10, 'Color', [0.8 0.2 0.2], ...
     'DisplayName', 'Case 1: No Control');
plot(penetration, sensitivity_results.case2 * 100, '-s', ...
     'LineWidth', 2.5, 'MarkerSize', 10, 'Color', [0.2 0.6 0.8], ...
     'DisplayName', 'Case 2: OLTC Only');
plot(penetration, sensitivity_results.case3 * 100, '-d', ...
     'LineWidth', 3, 'MarkerSize', 10, 'Color', [0.2 0.8 0.3], ...
     'DisplayName', 'Case 3: Coordinated');

% Mark the benchmark point (50% penetration rate)
xline(50, 'k--', 'LineWidth', 1.5, 'Alpha', 0.5, 'Label', 'Baseline (50%)');

5% limit line
yline(5, 'r--', 'LineWidth', 1.5, 'Label', '5% Limit');

grid on;
xlabel('PV Penetration (%)', 'FontSize', 14);
ylabel('95th Percentile Voltage Deviation (%)', 'FontSize', 14);
title('Sensitivity to PV Capacity', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 12);
xlim([38 62]);

saveas(gcf, 'results/figures/sensitivity_pv_penetration.png');

fprintf('\n✓Sensitivity analysis completed, results have been saved\n');

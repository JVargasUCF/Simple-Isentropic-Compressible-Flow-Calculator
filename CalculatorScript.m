% Developed Fall 2024 @ Propulsion and Energy Research Laboratory
% Jerry R. Vargas
% Simple Matlab/Offline Alternative to VA Tech Compressible Aerodynamics Calculator for Isentropic Flow
% Enjoy!

function isentropicFlowGUI
    % Create the GUI figure
    f = figure('Position', [300 300 400 700], 'Name', 'Isentropic Flow Relations', 'NumberTitle', 'off');

    % Gamma input field (for compressible flows, gamma is usually 1.4)
    uicontrol('Style', 'text', 'Position', [20 620 80 20], 'String', 'Gamma (γ):');
    gammaInput = uicontrol('Style', 'edit', 'Position', [120 620 80 20], 'String', '1.4');
    
    % Dropdown menu for selecting the known input
    uicontrol('Style', 'text', 'Position', [20 580 120 20], 'String', 'Select Known Input:');
    inputType = uicontrol('Style', 'popupmenu', 'Position', [150 580 150 20], ...
        'String', {'Mach Number (M)', 'rho/rho_o', 'Mach Angle', 'P-M Angle', 'T/T_o', 'A/A*', 'p/p_o', 'p/p*', 'rho/rho*'});

    % Known input value field
    uicontrol('Style', 'text', 'Position', [20 540 120 20], 'String', 'Enter Known Value:');
    inputValue = uicontrol('Style', 'edit', 'Position', [150 540 150 20]);

    % Output labels and text boxes for each flow property
    outputLabels = {'Mach Number (M)', 'rho/rho_o', 'Mach Angle (deg)', 'P-M Angle (deg)', ...
                    'T/T_o', 'A/A*', 'rho/rho*', 'p/p_o', 'p/p*'};
    outputFields = [];
    for i = 1:numel(outputLabels)
        uicontrol('Style', 'text', 'Position', [20 500-40*(i-1) 120 20], 'String', outputLabels{i});
        outputFields(i) = uicontrol('Style', 'text', 'Position', [150 500-40*(i-1) 150 20], 'String', '');
    end

    % Compute button
    uicontrol('Style', 'pushbutton', 'Position', [150 50 100 40], 'String', 'Compute', 'Callback', @computeIsentropicFlow);

    function computeIsentropicFlow(~,~)
        % Get input values
        gammaVal = str2double(get(gammaInput, 'String'));  % Changed from gamma to gammaVal
        knownValue = str2double(get(inputValue, 'String'));
        selectedInput = get(inputType, 'Value'); % Dropdown menu selection

        % Clear previous output
        for i = 1:numel(outputFields)
            set(outputFields(i), 'String', '');
        end
        
        % Perform calculations based on selected input type
        switch selectedInput
            case 1  % Mach Number (M)
                M = knownValue;
            case 2  % rho/rho_o
                M = sqrt(((knownValue)^((gammaVal-1)/gammaVal) - 1) * 2 / (gammaVal-1));
            case 3  % Mach Angle
                M = 1 / sind(knownValue);
            case 4  % P-M Angle
                nu = knownValue * pi / 180; % Convert to radians
                M = fsolve(@(M) sqrt((gammaVal+1)/(gammaVal-1)) * atan(sqrt((gammaVal-1)/(gammaVal+1)*(M^2 - 1))) - atan(sqrt(M^2 - 1)) - nu, 2);
            case 5  % T/T_o
                M = sqrt((1 / knownValue - 1) * 2 / (gammaVal - 1));
            case 6  % A/A*
                M_sub = fsolve(@(M) (1/M)*((2/(gammaVal+1))*(1+((gammaVal-1)/2)*M^2))^((gammaVal+1)/(2*(gammaVal-1))) - knownValue, 0.5);
                M_sup = fsolve(@(M) (1/M)*((2/(gammaVal+1))*(1+((gammaVal-1)/2)*M^2))^((gammaVal+1)/(2*(gammaVal-1))) - knownValue, 2);
                M = [M_sub, M_sup]; % Two solutions (subsonic and supersonic)
            case 7  % p/p_o
                M = sqrt(((1/knownValue)^((gammaVal-1)/gammaVal) - 1) * 2 / (gammaVal - 1));
            case 8  % p/p*
                M = fsolve(@(M) (1+((gammaVal-1)/2)*M^2)^(-gammaVal/(gammaVal-1)) - knownValue, 1.5);
            case 9  % rho/rho*
                M = fsolve(@(M) (1+((gammaVal-1)/2)*M^2)^(-1/(gammaVal-1)) - knownValue, 1.5);
        end
        
        % If M is a vector (A/A* case), display both subsonic and supersonic solutions
        if length(M) == 2
            M1 = M(1); M2 = M(2);
            computeAndDisplay(M1, 'Subsonic', gammaVal);
            computeAndDisplay(M2, 'Supersonic', gammaVal);
        else
            computeAndDisplay(M, '', gammaVal);
        end
    end

    function computeAndDisplay(M, flowType, gammaVal)
        % Compute other flow properties based on the Mach number
        rho_over_rho_o = (1 + (gammaVal-1)/2*M^2)^(-1/(gammaVal-1));  % Changed from gamma to gammaVal
        mach_angle = asind(1/M);
        pm_angle = sqrt((gammaVal+1)/(gammaVal-1))*atan(sqrt((gammaVal-1)/(gammaVal+1)*(M^2-1))) - atan(sqrt(M^2-1));
        temp_over_to = (1 + (gammaVal-1)/2*M^2)^(-1);
        area_over_astar = (1/M)*((2/(gammaVal+1))*(1+(gammaVal-1)/2*M^2))^((gammaVal+1)/(2*(gammaVal-1)));
        rho_over_rho_star = (1 + (gammaVal-1)/2*M^2)^(-1/(gammaVal-1));
        p_over_po = (1 + (gammaVal-1)/2*M^2)^(-gammaVal/(gammaVal-1));
        p_over_pstar = (1 + (gammaVal-1)/2*M^2)^(-gammaVal/(gammaVal-1));

        % Display the computed values
        set(outputFields(1), 'String', sprintf('%.2f %s', M, flowType));
        set(outputFields(2), 'String', sprintf('%.4f', rho_over_rho_o));
        set(outputFields(3), 'String', sprintf('%.2f', mach_angle));
        set(outputFields(4), 'String', sprintf('%.2f', pm_angle * 180/pi));  % Convert rad to deg
        set(outputFields(5), 'String', sprintf('%.4f', temp_over_to));
        set(outputFields(6), 'String', sprintf('%.4f', area_over_astar));
        set(outputFields(7), 'String', sprintf('%.4f', rho_over_rho_star));
        set(outputFields(8), 'String', sprintf('%.4f', p_over_po));
        set(outputFields(9), 'String', sprintf('%.4f', p_over_pstar));
    end
end

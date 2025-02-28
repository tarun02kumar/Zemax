%% Guidelines
% This is a boiler plate main code for a singlet lens example
% # This example demonstrates how to design and optimize a landscape or singlet lens using ZOS-API in MATLAB.
% It shows how to set system parameters, populate the lens data editor (LDE), build custom 
% merit function and run local and Hammer optimizer

% To run this code
% Goto Programming tab of Zemax OpticStudio and select MATLAB > Standalone Application
% Copy the section of code from "Start" to "End" and paste in the generated 
% file where it says "Add your custom code
% here..."
% Execute and it will generate the Zemax lens file at the indicated path

% Design parameters: 
% F# = 10, EFL = 100 mm, Wavelengths = F, d, C and field of +/-5 degree
% Stop is a separate physically defined surface.
% Lens should have min center and edge thickness of 3 mm 
% and max centre thickness of 10 mm
% Lens should also have 2 mm of chip zone for mounting
% Minimize the RMS spot size


% Written by Tarun Kumar, 2025


%% ---------------------Start-----------------------------------------------
%% Global variables
% change these variables as you like (within limits)
MinAirCenter = 0.5;
MaxAirCenter = 1000;
MinAirEdge = 0.5;

MinGlassCenter = 3;
MaxGlassCenter = 15;
MinGlassEdge = 3;
F_Number = 10;

Hammer_time = 15;

%% Creating a optical system file
   % Set up primary optical system
    % TheSystem = TheApplication.PrimarySystem;
    sampleDir = TheApplication.SamplesDir;
  % Make new file and define path where lens file will be saved
    testFile = System.String.Concat(sampleDir, '\Sequential\Objectives\Singlet_Example_01.zmx');
    TheSystem.New(false);
    TheSystem.SaveAs(testFile);

%% System explorer settings

  % Setting aperture
    SystExplorer = TheSystem.SystemData;
    SystExplorer.Aperture.ApertureType = ZOSAPI.SystemData.ZemaxApertureType.FloatByStopSize;
    % SystExplorer.Aperture.ApertureValue = 40;

  % Define 3 Fields with equal area
    Field_1 = SystExplorer.Fields.GetField(1);           
    NewField_2 = SystExplorer.Fields.AddField(0, 5.0, 1.0);
    SystExplorer.Fields.SetFieldType(ZOSAPI.SystemData.FieldType.Angle);
    % SystExplorer.Fields.SetFieldType(ZOSAPI.SystemData.FieldNormalizationType.Radial);
    SystExplorer.Fields.MakeEqualAreaFields(3, 5);

  % Wavelength preset
    slPreset = SystExplorer.Wavelengths.SelectWavelengthPreset(ZOSAPI.SystemData.WavelengthPreset.d_0p587);%%% 
%% Lens data editor
  % Lens data 
    TheLDE = TheSystem.LDE;
    TheLDE.InsertNewSurfaceAt(2);
    TheLDE.InsertNewSurfaceAt(2);
    Surface_0 = TheLDE.GetSurfaceAt(0);
    Surface_1 = TheLDE.GetSurfaceAt(1);
    Surface_2 = TheLDE.GetSurfaceAt(2);
    Surface_3 = TheLDE.GetSurfaceAt(3);
    Surface_0.Comment = 'Object at Infinity';
    Surface_1.Thickness = 50.0;
    Surface_1.Comment = 'Fixed stop size';
    Surface_1.SemiDiameter = 10;
    Surface_2.Radius = 100.0;
    Surface_2.Thickness = 10.0;
    Surface_2.Comment = 'front of lens';
    Surface_2.Material = 'N-BK7';      
    Surface_3.Comment = 'rear of lens';               

  % F# Solver
    Solver = Surface_3.RadiusCell.CreateSolveType(ZOSAPI.Editors.SolveType.FNumber);
    Solver.FNumber = F_Number;
    Surface_3.RadiusCell.SetSolveData(Solver);

%% Quick Focus  
  % QuickFocus
    quickFocus = TheSystem.Tools.OpenQuickFocus();
    quickFocus.Criterion = ZOSAPI.Tools.General.QuickFocusCriterion.SpotSizeRadial;
    quickFocus.UseCentroid = true;
    quickFocus.RunAndWaitForCompletion();
    quickFocus.Close();

%% Setting up variables
   % Make thicknesses and radii variable
    Surface_1.ThicknessCell.MakeSolveVariable();
    Surface_2.ThicknessCell.MakeSolveVariable();
    Surface_2.RadiusCell.MakeSolveVariable();
    Surface_3.ThicknessCell.MakeSolveVariable();


%% Defining merit function
    
  % Minimizing Astimatism and coma
    TheMFE = TheSystem.MFE; 
    TheMFE.ShowMFE();
    % TheMFE.ShowMFE(true);
    % ZOSAPI.Editors.MFE.;
    % TheMFE.ShowMFE = true;
    Operand_1=TheMFE.GetOperandAt(1);
    Operand_1.ChangeType(ZOSAPI.Editors.MFE.MeritOperandType.ASTI);
    Operand_1.Target = 0.0;
    Operand_1.Weight = 10.0;
    Operand_2=TheMFE.InsertNewOperandAt(2);
    Operand_2.ChangeType(ZOSAPI.Editors.MFE.MeritOperandType.COMA);
    Operand_2.Target = 0.0;
    Operand_2.Weight = 1.0;
   
    % defining default merit function
    OptWizard = TheMFE.SEQOptimizationWizard;
    
    %Optimize for smallest RMS Spot, which is "Data" = 1
    OptWizard.Data = 1;
    OptWizard.Type = 0;
    OptWizard.OverallWeight = 1;
    OptWizard.RelativeXWeight = 1;
    % Choosing centroid as a reference (code = 0)
    OptWizard.Reference = 0;
    

    % selecting Gaussian Qaudature, 3 rings (code = 2) and 6 arms (code = 0)
    OptWizard.PupilIntegrationMethod = 0;
    OptWizard.Ring = 2;
    OptWizard.Arm = 0;
    %Set air & glass boundaries
    OptWizard.IsGlassUsed = true;
    OptWizard.GlassMin = MinGlassCenter;
    OptWizard.GlassMax = MaxGlassCenter;
    OptWizard.GlassEdge = MinGlassEdge;
    OptWizard.IsAirUsed = true;
    OptWizard.AirMin = MinAirCenter;
    OptWizard.AirMax = MaxAirCenter;
    OptWizard.AirEdge = MinAirEdge;
    % start at operand 3 to avoid overwriting predefined operands
    OptWizard.StartAt = 3;
    %And click OK!
    OptWizard.Apply();

%% Optimization
  % Local optimisation till completion
    LocalOpt = TheSystem.Tools.OpenLocalOptimization();
    LocalOpt.Algorithm = ZOSAPI.Tools.Optimization.OptimizationAlgorithm.DampedLeastSquares;
    LocalOpt.Cycles = ZOSAPI.Tools.Optimization.OptimizationCycles.Automatic;
    LocalOpt.NumberOfCores = 8;
    LocalOpt.RunAndWaitForCompletion();
    LocalOpt.Close();
  % Hammer optimization 

    HammerOptimTimeInSeconds = Hammer_time;
    HammerOpt = TheSystem.Tools.OpenHammerOptimization();
    if ~isempty(HammerOpt)
        HammerOpt.Algorithm = ZOSAPI.Tools.Optimization.OptimizationAlgorithm.DampedLeastSquares;
        HammerOpt.NumberOfCores = 8;
        fprintf('Hammer Optimization for %i seconds...\n', HammerOptimTimeInSeconds);
        fprintf('Initial Merit Function %6.3f\n',HammerOpt.InitialMeritFunction);
        HammerOpt.RunAndWaitWithTimeout(HammerOptimTimeInSeconds);
        fprintf('Final Merit Function %6.3f\n', HammerOpt.CurrentMeritFunction);

        HammerOpt.Cancel();
		HammerOpt.WaitForCompletion();
        HammerOpt.Close();
    end

%% Open spot diagram window

     % Create analysis
    TheAnalyses  = TheSystem.Analyses;
    SpotDiagram = TheAnalyses.New_StandardSpot; 

    SpotDiagram_settings = SpotDiagram.GetSettings();
    SpotDiagram_settings.RayDensity = 15;
  % Run Analysis
    SpotDiagram.ApplyAndWaitForCompletion();
    % SpotDiagram_Results = SpotDiagram.GetResults()

  % Save and close
    TheSystem.Save();

%% -----------------------End----------------------------------------
%% Guidelines
% This is a boiler plate main code for a singlet lens example
% # This example demonstrates how to design and optimize a landscape or singlet lens using ZOS-API in MATLAB.
% It shows how to set system parameters, populate the lens data editor (LDE), build custom 
% merit function and run local and Hammer optimizer

% To run this code
% Goto Programming tab of Zemax OpticStudio and select MATLAB > Standalone Application
% Copy the section of code from "Start" to "End" and paste in the generated 
% file where it says "Add your custom code
% here..."
% Execute and it will generate the Zemax lens file at the indicated path

% Design parameters: 
% F# = 10, EFL = 100 mm, Wavelengths = F, d, C and field of +/-5 degree
% Stop is a separate physically defined surface.
% Lens should have min center and edge thickness of 3 mm 
% and max centre thickness of 10 mm
% Lens should also have 2 mm of chip zone for mounting
% Minimize the RMS spot size


% Written by Tarun Kumar, 2025


%% ---------------------Start-----------------------------------------------
%% Global variables
% change these variables as you like (within limits)
MinAirCenter = 0.5;
MaxAirCenter = 1000;
MinAirEdge = 0.5;

MinGlassCenter = 3;
MaxGlassCenter = 15;
MinGlassEdge = 3;
F_Number = 10;

Hammer_time = 15;

%% Creating a optical system file
   % Set up primary optical system
    % TheSystem = TheApplication.PrimarySystem;
    sampleDir = TheApplication.SamplesDir;
  % Make new file and define path where lens file will be saved
    testFile = System.String.Concat(sampleDir, '\Sequential\Objectives\Singlet_Example_01.zmx');
    TheSystem.New(false);
    TheSystem.SaveAs(testFile);

%% System explorer settings

  % Setting aperture
    SystExplorer = TheSystem.SystemData;
    SystExplorer.Aperture.ApertureType = ZOSAPI.SystemData.ZemaxApertureType.FloatByStopSize;
    % SystExplorer.Aperture.ApertureValue = 40;

  % Define 3 Fields with equal area
    Field_1 = SystExplorer.Fields.GetField(1);           
    NewField_2 = SystExplorer.Fields.AddField(0, 5.0, 1.0);
    SystExplorer.Fields.SetFieldType(ZOSAPI.SystemData.FieldType.Angle);
    % SystExplorer.Fields.SetFieldType(ZOSAPI.SystemData.FieldNormalizationType.Radial);
    SystExplorer.Fields.MakeEqualAreaFields(3, 5);

  % Wavelength preset
    slPreset = SystExplorer.Wavelengths.SelectWavelengthPreset(ZOSAPI.SystemData.WavelengthPreset.d_0p587);%%% 
%% Lens data editor
  % Lens data 
    TheLDE = TheSystem.LDE;
    TheLDE.InsertNewSurfaceAt(2);
    TheLDE.InsertNewSurfaceAt(2);
    Surface_0 = TheLDE.GetSurfaceAt(0);
    Surface_1 = TheLDE.GetSurfaceAt(1);
    Surface_2 = TheLDE.GetSurfaceAt(2);
    Surface_3 = TheLDE.GetSurfaceAt(3);
    Surface_0.Comment = 'Object at Infinity';
    Surface_1.Thickness = 50.0;
    Surface_1.Comment = 'Fixed stop size';
    Surface_1.SemiDiameter = 10;
    Surface_2.Radius = 100.0;
    Surface_2.Thickness = 10.0;
    Surface_2.Comment = 'front of lens';
    Surface_2.Material = 'N-BK7';      
    Surface_3.Comment = 'rear of lens';               

  % F# Solver
    Solver = Surface_3.RadiusCell.CreateSolveType(ZOSAPI.Editors.SolveType.FNumber);
    Solver.FNumber = F_Number;
    Surface_3.RadiusCell.SetSolveData(Solver);

%% Quick Focus  
  % QuickFocus
    quickFocus = TheSystem.Tools.OpenQuickFocus();
    quickFocus.Criterion = ZOSAPI.Tools.General.QuickFocusCriterion.SpotSizeRadial;
    quickFocus.UseCentroid = true;
    quickFocus.RunAndWaitForCompletion();
    quickFocus.Close();

%% Setting up variables
   % Make thicknesses and radii variable
    Surface_1.ThicknessCell.MakeSolveVariable();
    Surface_2.ThicknessCell.MakeSolveVariable();
    Surface_2.RadiusCell.MakeSolveVariable();
    Surface_3.ThicknessCell.MakeSolveVariable();


%% Defining merit function
    
  % Minimizing Astimatism and coma
    TheMFE = TheSystem.MFE; 
    TheMFE.ShowMFE();
    % TheMFE.ShowMFE(true);
    % ZOSAPI.Editors.MFE.;
    % TheMFE.ShowMFE = true;
    Operand_1=TheMFE.GetOperandAt(1);
    Operand_1.ChangeType(ZOSAPI.Editors.MFE.MeritOperandType.ASTI);
    Operand_1.Target = 0.0;
    Operand_1.Weight = 10.0;
    Operand_2=TheMFE.InsertNewOperandAt(2);
    Operand_2.ChangeType(ZOSAPI.Editors.MFE.MeritOperandType.COMA);
    Operand_2.Target = 0.0;
    Operand_2.Weight = 1.0;
   
    % defining default merit function
    OptWizard = TheMFE.SEQOptimizationWizard;
    
    %Optimize for smallest RMS Spot, which is "Data" = 1
    OptWizard.Data = 1;
    OptWizard.Type = 0;
    OptWizard.OverallWeight = 1;
    OptWizard.RelativeXWeight = 1;
    % Choosing centroid as a reference (code = 0)
    OptWizard.Reference = 0;
    

    % selecting Gaussian Qaudature, 3 rings (code = 2) and 6 arms (code = 0)
    OptWizard.PupilIntegrationMethod = 0;
    OptWizard.Ring = 2;
    OptWizard.Arm = 0;
    %Set air & glass boundaries
    OptWizard.IsGlassUsed = true;
    OptWizard.GlassMin = MinGlassCenter;
    OptWizard.GlassMax = MaxGlassCenter;
    OptWizard.GlassEdge = MinGlassEdge;
    OptWizard.IsAirUsed = true;
    OptWizard.AirMin = MinAirCenter;
    OptWizard.AirMax = MaxAirCenter;
    OptWizard.AirEdge = MinAirEdge;
    % start at operand 3 to avoid overwriting predefined operands
    OptWizard.StartAt = 3;
    %And click OK!
    OptWizard.Apply();

%% Optimization
  % Local optimisation till completion
    LocalOpt = TheSystem.Tools.OpenLocalOptimization();
    LocalOpt.Algorithm = ZOSAPI.Tools.Optimization.OptimizationAlgorithm.DampedLeastSquares;
    LocalOpt.Cycles = ZOSAPI.Tools.Optimization.OptimizationCycles.Automatic;
    LocalOpt.NumberOfCores = 8;
    LocalOpt.RunAndWaitForCompletion();
    LocalOpt.Close();
  % Hammer optimization 

    HammerOptimTimeInSeconds = Hammer_time;
    HammerOpt = TheSystem.Tools.OpenHammerOptimization();
    if ~isempty(HammerOpt)
        HammerOpt.Algorithm = ZOSAPI.Tools.Optimization.OptimizationAlgorithm.DampedLeastSquares;
        HammerOpt.NumberOfCores = 8;
        fprintf('Hammer Optimization for %i seconds...\n', HammerOptimTimeInSeconds);
        fprintf('Initial Merit Function %6.3f\n',HammerOpt.InitialMeritFunction);
        HammerOpt.RunAndWaitWithTimeout(HammerOptimTimeInSeconds);
        fprintf('Final Merit Function %6.3f\n', HammerOpt.CurrentMeritFunction);

        HammerOpt.Cancel();
		HammerOpt.WaitForCompletion();
        HammerOpt.Close();
    end

%% Open spot diagram window

     % Create analysis
    TheAnalyses  = TheSystem.Analyses;
    SpotDiagram = TheAnalyses.New_StandardSpot; 

    SpotDiagram_settings = SpotDiagram.GetSettings();
    SpotDiagram_settings.RayDensity = 15;
  % Run Analysis
    SpotDiagram.ApplyAndWaitForCompletion();
    % SpotDiagram_Results = SpotDiagram.GetResults()

  % Save and close
    TheSystem.Save();

%% -----------------------End----------------------------------------

VAR
    SF1: BOOL; (* Mine Phone Continuity SF1 (1008 (2) port 8) *)
    SF2: BOOL; (* Mine Phone Continuity SF2 (1008 (2) port 7) *)
    SF6: BOOL; (* MGT Continuity SF6 (1008 (3) port 1) *)
    SF8: BOOL; (* MGT Continuity SF8 (1008 (3) port 2) *)
    SF4: BOOL; (* Fire pull Station SF4 (1008 (1) port 1) *)
    SF5: BOOL; (* Fire Alarm Sound SF5 (2024 port 2) *)
    J1_1: BOOL; (* Lighting 24V Check J1 (1) (1008 (3) port 3) *)
    J1_2: BOOL; (* Lighting 24V Check J1 (2) (1008 (3) port 4) *)
    J2_1: BOOL; (* Lighting 24V Check J2 (1) (1008 (3) port 5) *)
    J2_2: BOOL; (* Lighting 24V Check J2 (2) (1008 (3) port 6) *)
    J3_1: BOOL; (* 24V PWR Check J3 (1) (1008 (1) port 4) *)
    J3_2: BOOL; (* 24V PWR Check J3 (2) (1008 (1) port 5) *)
    J4_1: BOOL; (* 24V PWR Check J4 (1) (1008 (1) port 6) *)
    J4_2: BOOL; (* 24V PWR Check J4 (2) (1008 (1) port 7) *)
    J5_1: BOOL; (* 24V PWR Check J5 (1) (1008 (2) port 1) *)
    J5_2: BOOL; (* 24V PWR Check J5 (2) (1008 (2) port 2) *)
    J6_1: BOOL; (* 24V PWR Check J6 (1) (1008 (2) port 3) *)
    J6_2: BOOL; (* 24V PWR Check J6 (2) (1008 (2) port 4) *)
    J7_4: BOOL; (* 24V PWR Check J7 (4) (1008 (1) port 2) *)
    J7_5: BOOL; (* 24V PWR Check J7 (5) (1008 (1) port 3) *)
    J8_4: BOOL; (* 24V PWR Check J8 (4) (1008 (2) port 5) *)
    J8_5: BOOL; (* 24V PWR Check J8 (5) (1008 (2) port 6) *)
    Door_Switch: BOOL; (* Door Switch, Unknown Port *)
    Estop_Signal: BOOL; (* Estop Signal, Unknown Port *)
    DCDC_Signal: BOOL; (* DCDC Signal, Unknown Port *)
    Estop_Signal_Low: BOOL; (* Estop Signal Low, Unknown Port *)
    DCDC_Signal_Low: BOOL; (* DCDC Signal Low, Unknown Port *)
    DCDC_Calibration_Manual: BOOL; (* DCDC Calibration Manual, Unknown Port *)
    DCDC_2_Signal: BOOL; (* DCDC 2 Signal, Unknown Port *)
    DCDC_2_Signal_Low: BOOL; (* DCDC 2 Signal Low, Unknown Port *)
    DCDC_2_Calibration_Manual: BOOL; (* DCDC 2 Calibration Manual, Unknown Port *)
    PSU_1_Signal: BOOL; (* PSU 1 Signal, Unknown Port *)
    PSU_1_Signal_Low: BOOL; (* PSU 1 Signal Low, Unknown Port *)
    PSU_2_Signal: BOOL; (* PSU 2 Signal, Unknown Port *)
    PSU_2_Signal_Low: BOOL; (* PSU 2 Signal Low, Unknown Port *)
    Hear_Fire_Alarm_Manual: BOOL; (* Hear Fire Alarm Manual, Unknown Port *)
    Ping_address_1: BOOL; (* Ping address 1, Unknown Port *)
    Ping_address_2: BOOL; (* Ping address 2, Unknown Port *)
    Ping_address_3: BOOL; (* Ping address 3, Unknown Port *)
    Ping_address_4: BOOL; (* Ping address 4, Unknown Port *)
    grace_port_visible: BOOL; (* grace port visible, Unknown Port *)
    120V_indicator_visible: BOOL; (* 120V indicator visible, Unknown Port *)
    programmed_psu1_manual: BOOL; (* programmed psu1 manual, Unknown Port *)
    programmed_psu2_manual: BOOL; (* programmed psu2 manual, Unknown Port *)
    24v_load_test_psu1: BOOL; (* 24v load test psu1, Unknown Port *)
    24v_load_test_psu2: BOOL; (* 24v load test psu2, Unknown Port *)
    ecat_branch_test: BOOL; (* ecat branch test, Unknown Port *)
    ecat_branch_test_2: BOOL; (* ecat branch test 2, Unknown Port *)
    mine_phone_battery_manual: BOOL; (* mine phone battery manual, Unknown Port *)
    ping_ips: BOOL; (* ping ips, Unknown Port *)
    gfci_test_manual: BOOL; (* gfci test manual, Unknown Port *)


    TestingStage   : INT := 0;
    StepReady      : BOOL := TRUE;
    AdvanceStep    : BOOL; // Could be a physical input or HMI button

    // Logging arrays
    LogStep        : ARRAY[0..39] OF STRING(50);
    LogValue       : ARRAY[0..39] OF BOOL;

    // Internal helpers
    LogIndex       : INT := 0;

    Section1 : FB_Execute_Section_1;
    TestInProgress : BOOL;

END_VAR


// Main program

// Variable	Purpose
// StartTest	External trigger to begin
// Done	Goes TRUE when test finishes
// Result	TRUE = pass, FALSE = fail
// state	Local step tracking inside FB
// TON	Timer used for delays


// Advance only on rising edge of AdvanceStep
IF AdvanceStep AND StepReady THEN
    CASE TestingStage OF

        0:
            Section1(StartTest := TRUE,
                     Input1 := SF1,
                     Input2 := SF2,
                     Input3 := SF6,
                     Input4 := SF8);

            IF Section1.Done THEN
                LogStep[LogIndex] := 'section 1'
                LogValue[LogIndex] := Section1.Result;
                LogIndex := LogIndex + 1;
                TestingStage := 1;
            END_IF;

        ELSE
            // End of test
            TestingStage := 0;
            LogIndex := 0;
            LogStep[LogIndex] := 'Test Complete';
            LogValue[LogIndex] := TRUE;
            LogIndex := LogIndex + 1;
            TestingStage := 0;
            //

        END_CASE;

        StepReady := FALSE; // Lock step until AdvanceStep is Released
    END_IF
    // Allow next step when button released
    IF NOT AdvanceStep THEN
        StepReady:= TRUE;
    END_IF


// This is where I call the test logger program to create the test log

// VAR
//     TestLogger : FB_TestLogger;
//     AdvanceStep : BOOL;
//     ManualTrigger : BOOL;
// END_VAR

// Call it like this:

// pascal
// Copy
// Edit
// // During test step
// IF AdvanceStep THEN
//     TestLogger.StepDescription := 'Power Input 1 good';
//     TestLogger.StepResult := TRUE;
//     TestLogger.AddStep := TRUE;
// ELSE
//     TestLogger.AddStep := FALSE;
// END_IF

// // Trigger saving the log
// TestLogger.WriteLogToFile := ManualTrigger;

// // Optionally print it to logger
// TestLogger.PrintToLogger := FALSE; // or TRUE on demand

// TestLogger();

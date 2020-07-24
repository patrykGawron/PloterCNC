PROGRAM _INIT
	MpAlarmXCore_0.MpLink := ADR(gAlarmXCore);
	MpAlarmXCore_0.Enable := TRUE;
	
	MpAlarmXHistory_0.MpLink := ADR(gAlarmXHistory);
	MpAlarmXHistory_0.Enable := TRUE;
	
	MpCnc2Axis_0.MpLink := ADR(gCncXY);
	MpCnc2Axis_0.Enable := TRUE;
	MpCnc2Axis_0.Parameters := ADR(CncParameters);
    
	MpCnc2Axis_0.Override := 100.0;
	AxisVelocity := 0;
	CncParameters.Jog.Velocity[0] := AxisVelocity;
	CncParameters.Jog.Velocity[1] := AxisVelocity;
END_PROGRAM

PROGRAM _CYCLIC
	
	IF ProgramOption THEN
		CncParameters.ProgramName := 'CncSquare';
	ELSE
		CncParameters.ProgramName := 'CncProg';
	END_IF;
	
	MpCnc2Axis_0.ErrorReset := diErrorReset;
	
	IF EDGEPOS(MpCnc2Axis_0.Error) THEN
		MotionStep := STEP_ERROR;
	END_IF;
	
	CASE MotionStep OF
		STEP_INIT:
			MpCnc2Axis_0.Power := FALSE;
			MpCnc2Axis_0.Home := FALSE;
			
			IF diStart THEN
				MotionStep := STEP_POWER;
			END_IF;
		STEP_POWER:
			MpCnc2Axis_0.Power := TRUE;
			
			IF MpCnc2Axis_0.PowerOn THEN
				MotionStep := STEP_HOME;
			END_IF;
		STEP_HOME:
			MpCnc2Axis_0.Home := TRUE;
			
			IF MpCnc2Axis_0.IsHomed THEN
				MotionStep := STEP_AWAIT;
			END_IF;
		STEP_AWAIT:
			
			IF diStop THEN
	  			MotionStep := STEP_INIT;
			ELSIF diRunProgram THEN
				MotionStep := STEP_RUN_PROGRAM;
			ELSIF diIncreaseXAxis THEN
				CncParameters.Jog.Velocity[0] := AxisVelocity;
				MotionStep := STEP_MOVE_X_AXIS;
			ELSIF diDecreaseXAxis THEN
				CncParameters.Jog.Velocity[0] := -AxisVelocity;
				MotionStep := STEP_MOVE_X_AXIS;
			ELSIF diIncreaseYAxis THEN
				CncParameters.Jog.Velocity[1] := AxisVelocity;
				MotionStep := STEP_MOVE_Y_AXIS;
			ELSIF diDecreaseYAxis THEN
				CncParameters.Jog.Velocity[1] := -AxisVelocity;
				MotionStep := STEP_MOVE_Y_AXIS;
			END_IF;
		STEP_RUN_PROGRAM:
			MpCnc2Axis_0.MoveProgram := TRUE;
			MpCnc2Axis_0.Continue := FALSE;
			
			IF MpCnc2Axis_0.MoveDone THEN
				MotionStep := STEP_AWAIT;
				MpCnc2Axis_0.MoveProgram := FALSE;
			END_IF;
			
			IF diInterruptProgram THEN
				MotionStep := STEP_PROGRAM_INTERRUPTED;
			END_IF;
		STEP_PROGRAM_INTERRUPTED:
			MpCnc2Axis_0.Interrupt := TRUE;
			
			IF diResumeProgram THEN
				MotionStep := STEP_RUN_PROGRAM;
				MpCnc2Axis_0.Interrupt := FALSE;
				MpCnc2Axis_0.Continue := TRUE;
			END_IF;
		STEP_MOVE_X_AXIS:
			MpCnc2Axis_0.Jog := TRUE;
			
			IF NOT(diIncreaseXAxis) AND NOT(diDecreaseXAxis) THEN
				MotionStep := STEP_AWAIT;
				MpCnc2Axis_0.Jog := FALSE;
				CncParameters.Jog.Velocity[0] := 0;
			END_IF;
		STEP_MOVE_Y_AXIS:
			MpCnc2Axis_0.Jog := TRUE;
			
			IF  NOT(diIncreaseYAxis) AND NOT(diDecreaseYAxis) THEN
				MotionStep := STEP_AWAIT;
				MpCnc2Axis_0.Jog := FALSE;
				CncParameters.Jog.Velocity[1] := 0;
			END_IF;
		STEP_ERROR:
		
			IF NOT(MpCnc2Axis_0.Error) THEN
	  			MotionStep := STEP_INIT;
			END_IF;
	END_CASE;
	
	MpAlarmXHistory_0();
	MpAlarmXCore_0();
	MpCnc2Axis_0();
END_PROGRAM

PROGRAM _EXIT
    
	MpCnc2Axis_0.Power  := FALSE;
	MpCnc2Axis_0.Home   := FALSE;
	MpCnc2Axis_0();

	MpCnc2Axis_0.Enable := FALSE;
	MpCnc2Axis_0();

END_PROGRAM
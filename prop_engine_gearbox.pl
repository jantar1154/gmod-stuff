@name Torque Converter
@inputs GearUp GearDown Clutch [Crank Flywheel]:entity
@outputs AngularError AngVelDifference Ratio Gear
@persist Ratios:array HoldingForce AngVelMatchForce ShiftSound:string

if(first() | dupefinished()) {
    runOnTick(1)

    Ratios = array(
        -10,
        0,
        10,
        5,
        3,
        2,
        1.5,
        1.2
    )

    ShiftSound = "acf_extra/vehiclefx/trans/default_shift.wav"
    HoldingForce = 40 #Force for holding the crank and flywheel angles together.
    AngVelMatchForce = 30 #Force for matching the angular velocity between crank and flywheel.
                        #Both of these settings account for the current gear ratio.
    Gear = 2 #Gear you start in
}

if(~GearUp & GearUp & Gear < Ratios:count()) {
    Gear++
    if(ShiftSound) {
        Flywheel:soundPlay(1, 0.5, "acf_extra/vehiclefx/trans/default_shift.wav")
        soundVolume(1, 0.5)
    }
}

if(~GearDown & GearDown & Gear > 1) {
    Gear--
    if(ShiftSound) {
        Flywheel:soundPlay(1, 0.5, "acf_extra/vehiclefx/trans/default_shift.wav")
        soundVolume(1, 0.5)
    }
}

if(changed(Gear)) {
    Ratio = Ratios[clamp(Gear, 1, Ratios:count()), number]
}

if(Ratio != 0 & !Clutch) {
    Inertia1 = Crank:inertia():z()
    Inertia2 = Flywheel:inertia():z() / Ratio^2

    if(Inertia1 < Inertia2) {
        I = Inertia1
    } else {
        I = Inertia2
    }

    AngVelDifference = Flywheel:angVel():yaw() * Ratio - Crank:angVel():yaw()
    AngularError += AngVelDifference

    Force = (HoldingForce * AngularError + AngVelDifference * AngVelMatchForce) * I

    Crank:applyAngForce(ang(0, Force, 0))

    Flywheel:applyAngForce(-ang(0, Force, 0) * Ratio)
}

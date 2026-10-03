Constants = {}

Constants.ResourceName = 'nb-dispatch'

Constants.CallStatus = {
    PENDING  = 'pending',
    ACTIVE   = 'active',
    CLOSED   = 'closed',
}

Constants.Events = {

    CreateCall       = 'nb-dispatch:server:createCall',
    AcceptCall       = 'nb-dispatch:server:acceptCall',
    AssignCall       = 'nb-dispatch:server:assignCall',
    UnassignCall     = 'nb-dispatch:server:unassignCall',
    CloseCall        = 'nb-dispatch:server:closeCall',
    AddNote          = 'nb-dispatch:server:addNote',
    UpdateUnitStatus = 'nb-dispatch:server:updateUnitStatus',
    Panic            = 'nb-dispatch:server:panic',
    SetCallsign      = 'nb-dispatch:server:setCallsign',
    RequestSync      = 'nb-dispatch:server:requestSync',
    AutoDispatch     = 'nb-dispatch:server:autoDispatch',
    Citizen911       = 'nb-dispatch:server:citizen911',
    PursuitFlag      = 'nb-dispatch:server:pursuitFlag',
    UnitDown         = 'nb-dispatch:server:unitDown',

    UpdateCalls = 'nb-dispatch:client:updateCalls',
    UpdateUnits = 'nb-dispatch:client:updateUnits',
    NewCall     = 'nb-dispatch:client:newCall',
    Panic_C     = 'nb-dispatch:client:panic',
    UnitDown_C  = 'nb-dispatch:client:unitDown',
    Open        = 'nb-dispatch:client:open',
    Close       = 'nb-dispatch:client:close',
    Notify      = 'nb-dispatch:client:notify',
    SyncMeta    = 'nb-dispatch:client:syncMeta',
}

Constants.NuiActions = {
    UpdateCalls = 'dispatch:updateCalls',
    UpdateUnits = 'dispatch:updateUnits',
    NewCall     = 'dispatch:newCall',
    Panic       = 'dispatch:panic',
    UnitDown    = 'dispatch:unitDown',
    Open        = 'dispatch:open',
    Close       = 'dispatch:close',
    Notify      = 'dispatch:notify',
    SyncMeta    = 'dispatch:syncMeta',
}

trigger Doctor on Doctor__c ( before insert,after update) 
{
    // before insert trigger on doctor
    if(Trigger.isInsert && Trigger.isBefore)
    {
        DoctorPatientHandler.doctorBeforeInsert(Trigger.New);
    }
    
    // after update trigger on doctor
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        if(!checkRecursive.firstcall)
        {
            checkRecursive.firstcall = true;
            DoctorPatientHandler.doctorAfterUpdate(Trigger.New);
        }
    }    
}














/*
public with sharing class CheckRecursiveTriggerDoctor {
public static Boolean triggerFlag=true;

public static Boolean doNotRunTrigger = false;

public static void setDoNotRunTrigger(){
doNotRunTrigger = true;
}



public static Boolean shouldRunTrigger() {
return !doNotRunTrigger;
}

}
*/
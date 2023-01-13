trigger Appointment on Appointment__c (after insert, after update, before delete, after undelete) 
{
    //after insert/ after update/ after undelete trigger on appointment
    if(Trigger.isInsert && Trigger.isafter || Trigger.isUpdate && Trigger.isafter || trigger.isundelete)
    {
        DoctorPatientHandler.appointmentInsertUpdateUndelete(Trigger.New);
    }
    
    //before delete trigger on appointment
    if(Trigger.isDelete && Trigger.isBefore)
    {
        DoctorPatientHandler.appointmentBeforeDelete(Trigger.Old);
    }
}
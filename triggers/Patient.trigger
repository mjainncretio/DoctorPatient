trigger Patient on Patient__c (after update, before delete) 
{
    //before delete trigger on patient
	if(Trigger.isDelete && Trigger.isbefore)
    {
       DoctorPatientHandler.patientBeforeDelete(Trigger.old);
    }
    
    //after update trigger on patient
    if(Trigger.isUpdate && Trigger.isAfter)
    {
       DoctorPatientHandler.patientAfterUpdate(Trigger.New, Trigger.oldMap);
    }
}
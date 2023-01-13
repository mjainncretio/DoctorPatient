public class DoctorPatientHandler 
{
    //for Insert of doctor
	public static void doctorBeforeInsert(List<Doctor__c> doctors)
    {
        for(Doctor__c insertedDoctor : doctors)
        {
            insertedDoctor.Most_Critical_Patient__c = NULL;
        }
    }
    
    //for update of doctor
    public static void doctorAfterUpdate(List<Doctor__c> doctors)
    {
        DoctorPatientHelper.updateDoctor(doctors);
    }
    
    //for Insert/update/undelete of appointment
    public static void appointmentInsertUpdateUndelete(List<Appointment__c> appointments)
    {
        DoctorPatientHelper.appointmentUpdate(appointments);
    }
    
    //for delete of appointment
    public static void appointmentBeforeDelete(List<Appointment__c> appointments)
    {
        DoctorPatientHelper.appointmentDelete(appointments);
    }
    
    //for delete of patient
    public static void patientBeforeDelete(List<Patient__c> patients)
    {
         DoctorPatientHelper.deletePatient(patients);
    }
    
    //for update of patient
    public static void patientAfterUpdate(List<Patient__c> patients, Map<Id, Patient__c> patientMap)
    {
         DoctorPatientHelper.updatePatient(patients, patientMap);
    }
}
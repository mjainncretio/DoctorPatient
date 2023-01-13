@isTest
public class TestDoctorPatient 
{
    //create records
    @TestSetup
    static void create()
    {
        List<Doctor__c> doctorList = new List<Doctor__c>();
        doctorList.add(new Doctor__c(Name = 'Harshita'));
        doctorList.add(new Doctor__c(Name = 'Manav'));
        doctorList.add(new Doctor__c(Name = 'Yash'));
        doctorList.add(new Doctor__c(Name = 'Honey'));
        doctorList.add(new Doctor__c(Name = 'Navya'));
        INSERT doctorList;
        
        List<Patient__c> patientList = new List<Patient__c>();
        patientList.add(new Patient__c(Name__c = 'Muskan', Age__c = 21));
        patientList.add(new Patient__c(Name__c = 'Hemang', Age__c = 12));
        patientList.add(new Patient__c(Name__c = 'Manan', Age__c = 45));
        patientList.add(new Patient__c(Name__c = 'Karan', Age__c = 67));
        patientList.add(new Patient__c(Name__c = 'Kartik', Age__c = 2));
        patientList.add(new Patient__c(Name__c = 'Komal', Age__c = 56));
        INSERT patientList;
        
        doctorList = [SELECT Id FROM Doctor__c];
        patientList = [SELECT Id FROM Patient__c];
        
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        appointmentList.add(new Appointment__c(Patient__c = patientList[0].Id, Doctor__c = doctorList[0].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[1].Id, Doctor__c = doctorList[0].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[2].Id, Doctor__c = doctorList[1].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[3].Id, Doctor__c = doctorList[1].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[4].Id, Doctor__c = doctorList[1].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[5].Id, Doctor__c = doctorList[1].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[5].Id, Doctor__c = doctorList[2].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[0].Id, Doctor__c = doctorList[2].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[4].Id, Doctor__c = doctorList[3].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[5].Id, Doctor__c = doctorList[3].Id));
        appointmentList.add(new Appointment__c(Patient__c = patientList[5].Id, Doctor__c = doctorList[4].Id));
        INSERT appointmentList;
    }
    
    //On updating most critical patient of doctor
    @isTest
    private static void updateDoctor()
    {
        List<Doctor__c> doctorList = new List<Doctor__c>();
        Doctor__c doctorFirst = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Harshita' LIMIT 1];
        Doctor__c doctorSecond = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Manav' LIMIT 1];
        Id doctorpatientFirstId = doctorFirst.Most_Critical_Patient__c;
        Id doctorpatientSecondId = doctorSecond.Most_Critical_Patient__c;
        
        Id patientFirstId = [SELECT Id FROM Patient__c WHERE Name__c = 'Komal' LIMIT 1].Id;
        doctorFirst.Most_Critical_Patient__c = patientFirstId;
        doctorSecond.Most_Critical_Patient__c = patientFirstId;
        doctorList.add(doctorFirst);
        doctorList.add(doctorSecond);
        UPDATE doctorList;
        
        Doctor__c updatedDoctorFirst = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Harshita' LIMIT 1];
        Doctor__c updatedDoctorSecond = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Manav' LIMIT 1];
         
        //on updating of most critical patient of doctor its value is recalculated according to age
        System.assertEquals(doctorpatientFirstId, updatedDoctorFirst.Most_Critical_Patient__c);
        System.assertEquals(doctorpatientSecondId, updatedDoctorSecond.Most_Critical_Patient__c);      
    }
    
    //on deleting patient
    @isTest
    private static void deletePatient()
    {
        Patient__c patient = [SELECT Id, Name__c FROM Patient__c WHERE Name__c = 'Komal'];
        try
        {
            DELETE patient;
        } catch(Exception e)
        {
             //when doctor had single patient
             System.assert(e.getMessage().contains('You can\'t delete this appointment'));
        }
        
        patient = [SELECT Id, Name__c FROM Patient__c WHERE Name__c = 'Kartik'];
        try
        {
            DELETE patient;
        } catch(Exception e){}  
        
        List<Patient__c> patientList = [SELECT Id, Name__c FROM Patient__c WHERE Name__c = 'Kartik'];
        //when doctor had multiple patient
        System.assertEquals(0, patientList.size());        
    }
    
    //on updating age of patient
    @isTest
    private static void updatePatient()
    {
        List<Patient__c> patientList = new List<Patient__c>();
        Patient__c patientFirst = [SELECT Id, Name__c, Age__c FROM Patient__c WHERE Name__c = 'Muskan' LIMIT 1];
        Patient__c patientSecond = [SELECT Id, Name__c, Age__c FROM Patient__c WHERE Name__c = 'Hemang' LIMIT 1];
        
        patientFirst.Age__c = 45;
        patientSecond.Age__c = 90;
        patientList.add(patientFirst);
        patientList.add(patientSecond);
        UPDATE patientList;
        
        Patient__c patientThird = [SELECT Id, Name__c, Age__c FROM Patient__c WHERE Name__c = 'Komal' LIMIT 1];
        Doctor__c doctorFirst = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Harshita' LIMIT 1];
        Doctor__c doctorSecond = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Yash' LIMIT 1];
        
        //the most critical patient of doctor recalculated according to updating age of patient
        System.assertEquals(patientSecond.Id, doctorFirst.Most_Critical_Patient__c);
        System.assertEquals(patientThird.Id, doctorSecond.Most_Critical_Patient__c);
    }
    
    //on adding appointment
    @isTest
    private static void insertAppointment()
    {
        List<Doctor__c> doctorList = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c];
        
        Patient__c patient = [SELECT Id FROM Patient__c WHERE Name__c = 'Muskan' LIMIT 1];
        //most critical patient recalculated value
        System.assertEquals(patient.Id, doctorList[0].Most_Critical_Patient__c);
        
        patient = [SELECT Id FROM Patient__c WHERE Name__c = 'Karan' LIMIT 1];
        //most critical patient recalculated value
        System.assertEquals(patient.Id, doctorList[1].Most_Critical_Patient__c);
        
        patient = [SELECT Id FROM Patient__c WHERE Name__c = 'Komal' LIMIT 1];       
        //most critical patient recalculated value
        System.assertEquals(patient.Id, doctorList[2].Most_Critical_Patient__c);
        System.assertEquals(patient.Id, doctorList[3].Most_Critical_Patient__c);    
    }
    
    //on updating appointment
    @isTest
    private static void updateAppointment()
    {
        List<Appointment__c> appointmentList = new List<Appointment__c>();
        
        Id patientId = [SELECT Id FROM Patient__c WHERE Name__c = 'Muskan' LIMIT 1].Id; 
        Doctor__c doctor = [SELECT Id FROM Doctor__c WHERE Name = 'Harshita' LIMIT 1];
        Appointment__c appointmentFirst = [SELECT Id, Patient__c, Doctor__c 
                                           FROM Appointment__c 
                                           WHERE Patient__c = :patientId AND Doctor__c = :doctor.Id LIMIT 1];
        
        patientId = [SELECT Id FROM Patient__c WHERE Name__c = 'Komal'].Id;
        doctor = [SELECT Id FROM Doctor__c WHERE Name = 'Honey' LIMIT 1];
        Appointment__c appointmentSecond = [SELECT Id, Patient__c, Doctor__c 
                                           FROM Appointment__c 
                                           WHERE Patient__c = :patientId AND Doctor__c = :doctor.Id LIMIT 1];
        
        Id ChangedpatientFirstId = [SELECT Id FROM Patient__c WHERE Name__c = 'Manan' LIMIT 1].Id;
        appointmentFirst.Patient__c = ChangedpatientFirstId;
        Id ChangedpatientSecondId = [SELECT Id FROM Patient__c WHERE Name__c = 'Karan' LIMIT 1].Id;
        appointmentSecond.Patient__c = ChangedpatientSecondId;
        appointmentList.add(appointmentFirst);
        appointmentList.add(appointmentSecond);
        UPDATE appointmentList;
        
        //most critical patient of doctor when appointment updated
        doctor = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Harshita' LIMIT 1];
        System.assertEquals(ChangedpatientFirstId, doctor.Most_Critical_Patient__c);
        
        //most critical patient of doctor when appointment updated
        doctor = [SELECT Id, Most_Critical_Patient__c FROM Doctor__c WHERE Name = 'Honey' LIMIT 1];
        System.assertEquals(ChangedpatientSecondId, doctor.Most_Critical_Patient__c);
    }

    //on deleting appointment
    @isTest
    private static void deleteAppointment()
    {
        Id patientId = [SELECT Id FROM Patient__c WHERE Name__c = 'Komal' LIMIT 1].Id; 
        Doctor__c doctor = [SELECT Id FROM Doctor__c WHERE Name = 'Navya' LIMIT 1];
        Appointment__c appointmentFirst = [SELECT Id, Patient__c, Doctor__c 
                                           FROM Appointment__c 
                                           WHERE Patient__c = :patientId AND Doctor__c = :doctor.Id LIMIT 1];
        
        try
        {
            DELETE appointmentFirst;
        } catch(Exception e)
        {
             //when doctor had single patient
             System.assert(e.getMessage().contains('You can\'t delete this appointment'));
        }
        
        patientId = [SELECT Id FROM Patient__c WHERE Name__c = 'Muskan' LIMIT 1].Id; 
        doctor = [SELECT Id FROM Doctor__c WHERE Name = 'Harshita' LIMIT 1];
        appointmentFirst = [SELECT Id, Patient__c, Doctor__c 
                            FROM Appointment__c 
                            WHERE Patient__c = :patientId AND Doctor__c = :doctor.Id LIMIT 1];
        
        try
        {
            DELETE appointmentFirst;
        }catch(Exception e){}
        
        List<Appointment__c> appointmentList = [SELECT Id, Patient__c, Doctor__c 
                                                FROM Appointment__c 
                                                WHERE Patient__c = :patientId AND Doctor__c = :doctor.Id];
        //when doctor had multiple patient
        System.assertEquals(0, appointmentList.size());
    }
    
}
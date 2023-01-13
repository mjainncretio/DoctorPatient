public class DoctorPatientHelper 
{
    //update doctor
    public static void updateDoctor(List<Doctor__c> doctors)
    {
        Set<Id> doctorId = new Set<Id>();
        List<Doctor__c> UpdatedoctorList = new List<Doctor__c>();
        
        for(Doctor__c tempDoctor : doctors)
        {
            doctorId.add(tempDoctor.Id);
        }
        List<Doctor__c> doctorList = [SELECT Id, (SELECT Patient__r.Age__c FROM Appointments__r ORDER BY Patient__r.Age__c DESC LIMIT 1) 
                                      FROM Doctor__c 
                                      WHERE Id IN :doctorId];
        for(Doctor__c tempDoctor : doctorList)
        {
            if(tempDoctor.Appointments__r.size() > 0)
            {
                 tempDoctor.Most_Critical_Patient__c = tempDoctor.Appointments__r[0].Patient__c;            
            }
            else
            {
                tempDoctor.Most_Critical_Patient__c = NULL;
            }
            UpdatedoctorList.add(tempDoctor);
                      
        }
             UPDATE  UpdatedoctorList;      
    }
    
    //update/Insert/undelete appointment
    public static void appointmentUpdate(List<Appointment__c> appointments)
    {
        Set<Id> doctorId = new Set<Id>();
        List<Doctor__c> UpdatedocList = new List<Doctor__c>();
        
        for(Appointment__c tempAppointment : appointments)
        {
            doctorId.add(tempAppointment.Doctor__c);
        }
        List<Doctor__c> doctorList = [SELECT Id, (SELECT Patient__r.Age__c FROM Appointments__r ORDER BY Patient__r.Age__c DESC LIMIT 1) 
                                      FROM Doctor__c 
                                      WHERE Id IN :doctorId];
        
        for(Doctor__c doctor : doctorList)
        {
            doctor.Most_Critical_Patient__c = doctor.Appointments__r[0].Patient__c;
            UpdatedocList.add(doctor);           
        }
        UPDATE  UpdatedocList;    
    }
    
    //delete appointment
    public static void appointmentDelete(List<Appointment__c> appointments)
    {
        Map<Id,List<Id>> doctorPatient = new Map<Id,List<Id>>();
        List<Doctor__c> updateDoctorList = new List<Doctor__c>();
        for(Appointment__c tempAppointment : appointments)
        {
            List<Id> patientId = new List<Id>();
            if(doctorPatient.containsKey(tempAppointment.Doctor__c))
            {
                doctorPatient.get(tempAppointment.Doctor__c).add(tempAppointment.Patient__c);
            }
            else
            {
                patientId.add(tempAppointment.Patient__c);
                doctorPatient.put(tempAppointment.Doctor__c, patientId);
            }
        }
         List<Doctor__c> doctorList = [SELECT Id, (SELECT Id, Patient__r.Age__c FROM Appointments__r ORDER BY Patient__r.Age__c DESC) 
                                       FROM Doctor__c 
                                       WHERE Id IN :doctorPatient.keySet()]; 
                                            
        for(Doctor__c tempDoctor : doctorList)
        {
            Integer count = tempDoctor.Appointments__r.size();
            for(Appointment__c tempAppointment : tempDoctor.Appointments__r)
            {
                if(doctorPatient.get(tempDoctor.Id).contains(tempAppointment.Patient__c) && count <= 1)
                {
                    tempDoctor.Most_Critical_Patient__c = tempAppointment.Patient__c;
                    updateDoctorList.add(tempDoctor);
                    Trigger.oldMap.get(tempAppointment.Id).adderror('You can\'t delete this appointment');
                    break;
                }
                else if(doctorPatient.get(tempDoctor.Id).contains(tempAppointment.Patient__c) && count > 1)
                {
                    count -= 1;
                }
                else
                {
                    tempDoctor.Most_Critical_Patient__c = tempAppointment.Patient__c;
                    updateDoctorList.add(tempDoctor);
                    break;
                }
            }
        }
        UPDATE updateDoctorList;
    }
    
    //delete patient
    public static void deletePatient(List<Patient__c> patients)
    {
        List<Id> doctorId = new List<Id>();
        Set<Id> patientId = new Set<Id>();
        List<Appointment__c> appointmentToBeDeleted = new List<Appointment__c>();
        for(Patient__c tempPatient : patients)
        {
           patientId.add(tempPatient.Id);
        }
        List<Doctor__c> doctorList = [SELECT Id, Name, Most_Critical_Patient__c 
                                      FROM Doctor__c 
                                      WHERE Most_Critical_Patient__c IN :patientId];
        for(Doctor__c tempDoctor : doctorList)
        {
            doctorId.add(tempDoctor.Id);
        }
        List<Doctor__c> doctorsList = [SELECT Id, Most_Critical_Patient__c, (SELECT Patient__r.Age__c, Patient__c FROM Appointments__r 
                                       ORDER BY Patient__r.Age__c DESC) 
                                       FROM Doctor__c WHERE Id IN :doctorId];
        for(Doctor__c tempDoctor : doctorsList)
        {
            System.debug(tempDoctor.Appointments__r);
            Integer count = tempDoctor.Appointments__r.size();
            for(Appointment__c tempAppointment : tempDoctor.Appointments__r)
            {
                if(patientId.contains(tempAppointment.Patient__c) && count >= 1)
                {
                    appointmentToBeDeleted.add(tempAppointment);
                } else if(patientId.contains(tempAppointment.Patient__c) && count <= 1)
                {
                    Trigger.oldMap.get(tempAppointment.Patient__c).addError('Can not delete this patient as it\'s a Critical Patient for a Doctor');
                } else
                {                   
                    count += 1;
                    tempDoctor.Most_Critical_Patient__c = tempAppointment.Patient__c;
                }     
                count -= 1;
            }
        }
        DELETE appointmentToBeDeleted;
    }
    
    //update Patient
    public static void updatePatient(List<Patient__c> patients, Map<Id,Patient__c> patientMap)
    {
        Set<Id> doctorId = new Set<Id>();
        List<Doctor__c> updateDoctorList = new List<Doctor__c>();
        List<Id> patientId = new List<Id>();
        for(Patient__c tempPatient : patients)
        {
            if(tempPatient.Age__c != (patientMap).get(tempPatient.Id).Age__c)
            {
                patientId.add(tempPatient.Id);
            }
        }
        List<Appointment__c> appointmentList = [SELECT Id, Patient__r.Name,Patient__r.Age__c, Doctor__r.Name
                                                FROM Appointment__c 
                                                WHERE Patient__c IN :patientId]; 
        for(Appointment__c tempAppointment: appointmentList)
        {
            doctorId.add(tempAppointment.Doctor__r.Id);
        }
        List<Doctor__c> doctorList = [SELECT Id, (SELECT Patient__r.Age__c FROM Appointments__r ORDER BY Patient__r.Age__c DESC LIMIT 1) 
                                      FROM Doctor__c 
                                      WHERE Id IN :doctorId];
        for(Doctor__c tempDoctor : doctorList)
        {
            tempDoctor.Most_Critical_Patient__c = tempDoctor.Appointments__r[0].Patient__c;
            updateDoctorList.add(tempDoctor);           
        }
        UPDATE  updateDoctorList;
    }
}
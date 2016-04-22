#!/usr/bin/python
import subprocess
import os

SVNURL='https://prog.nctdc.com/svn/CSP/Projects/ANSWRS/source/module/awr_reports/SMART/'

genreports = {
'19841':'awr_SMART_site_details.sql',  
'19841':'awr_SMART_site_personnel.sql', 
'19886':'awr_SMART_shipment_summary.sql',
'20031':'awr_SMART_unblinded_drug_inv_wh.sql', 
'19841':'awr_SMART_unblinded_drug_inv_site.sql',
'19841':'awr_SMART_unblinded_kit_summary_wh.sql', 
'19841':'awr_SMART_unblinded_kit_summary_site.sql', 
'19873':'awr_SMART_blinded_kit_summary_site.sql',  
'20546':'awr_SMART_blinded_kit_summary_wh.sql',
'19708':'awr_SMART_blinded_drug_inv_wh.sql',
'19707':'awr_SMART_blinded_drug_inv_site.sql',
'19841':'awr_SMART_detailed_vis_sum.sql',
'20273':'awr_SMART_recruitment.sql',
'20281':'awr_SMART_subject_details.sql'
}

def fetchReports(psql,db,study):
   if os.path.exists("install_"+study):print "install_"+study+"/*.sql";os.remove("install_"+study+"/*.sql")
   else:os.makedirs("install_"+study)
   print psql,db
   for rev,rep in genreports.iteritems():
     print "exporting report"+rep+" with Revision:"+rev
     p=subprocess.Popen("svn export "+SVNURL+rep, shell=True)
     p.wait()
   return;
   
def repStudy(study):
    psqlcmd=psql+" -p 5433 -U wctdba -f"     
    for rev,rep in genreports.iteritems():
       print rep
       f1 = open(rep, 'r')
       f2 = open("install_"+study+"/"+study+"_"+rep, 'w')
       for line in f1:
           f2.write(line.replace('[study]', study));
           psqlcmd=psqlcmd+"install_"+study+"/"+study+"_"+rep+" "+db
           print psqlcmd
           #p=subprocess.Popen(psqlcmd, shell=True)
           #p.wait()
       f1.close();
       f2.close();   
    return;     
    

def print_menu():       ## Your menu design here  
               print 30 * "-" , "MENU" , 30 * "-"
               print "1-DEV)"
               print "2-UAT)"
               print "3-PRD)"
               print "4-Quit)"
loop=True
while loop:          ## While loop which will keep going until loop = False
        print_menu()    ## Displays menu
        choice = input("Enter your choice [1-4]: ")
        if choice==1: psql='/usr/lib/postgresql/9.0/bin/psql';db='dev_140e';study=(raw_input('Enter the schema name:? '));fetchReports(psql,db,study);repStudy(study);
        if choice==2: print "2"
        if choice==3: print "2"
        if choice==4: print "2"
         
        # Any integer inputs other than values 1-5 we print an error message
        raw_input("Wrong option selection. Enter any key to try again..")

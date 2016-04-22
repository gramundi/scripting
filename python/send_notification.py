#!/usr/bin/python
import select
import sys
#PSYCOPG2 is an Postgres adapter which implement the python DB API 
import psycopg2
import psycopg2.extensions
import smtplib
#mail package modules
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

#print "num arg %d"  % len(sys.argv)
if (len(sys.argv) < 6 ) :
   #example ./send_notification.py dev_140e wctdba 127.0.0.1  5433 5
   print "usage:/.send_notification.py [database] [user] [host] [port] [timeout]"
   quit()
else:
	db=sys.argv[1]
	un=sys.argv[2]
	hn=sys.argv[3]
	pn=sys.argv[4]
	to=sys.argv[5]

dbc = psycopg2.connect(database=db,user=un, host=hn, port=pn)
dbc.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
cur = dbc.cursor()
cur.execute('LISTEN new_role')

#endless loop to listen on the DB chanel with the unix API
while 1:
    #listen on dbc descriptor with a timeoput of 5 sec
    if select.select([dbc], [], [], 5) == ([], [], []):
      print "timeout"
    else:
        dbc.poll()
        #we have got a notification 
        while dbc.notifies:
            notify = dbc.notifies.pop()
            print "new_role for the user %s, backed: %d" % (notify.payload, notify.pid) 
            #create the cointainer of the mail message
            msg= MIMEMultipart('alternative')
	    sender = 'noreply@wwctrials.com'
            receivers = ['giovanni.ramundi@wwctrials.com']
            msg['From']='noreply@wwctrials.com'
            msg['To']='giovanni.ramundi@wwctrials.com'
            msg['Subject']='Role Changed'
            text=notify.payload
            part1 = MIMEText(text, 'html')
            msg.attach(part1)
	    try:
   		smtpObj = smtplib.SMTP('mailgate.nctdc.com')
   		smtpObj.sendmail(sender, receivers, msg.as_string())         
   		print "Successfully sent email"
	    except smtplib.SMTPException:
   		print "Error: unable to send email"

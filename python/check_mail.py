#!/usr/bin/python
import smtplib
#mail package modules
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
#create the cointainer of the mail message
msg= MIMEMultipart('alternative')
sender = 'noreply@wwctrials.com'
receivers = ['giovanni.ramundi@wwctrials.com']
msg['From']='noreply@wwctrials.com'
msg['To']='giovanni.ramundi@wwctrials.com'
msg['Subject']='Role Changed'
text='test'
part1 = MIMEText(text, 'plain')
msg.attach(part1)
try:
	smtpObj = smtplib.SMTP('mailgate.nctdc.com')
   	smtpObj.sendmail(sender, receivers, msg.as_string())         
   	print "Successfully sent email"
except smtplib.SMTPException:
	print "Error: unable to send email"

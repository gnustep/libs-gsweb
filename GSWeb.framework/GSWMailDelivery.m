/** GSWMailDelivery.m - <title>GSWeb: Class GSWMailDelivery</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Feb 1999
   
   $Revision$
   $Date$

   This file is part of the GNUstep Web Library.
   
   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

static char rcsId[] = "$Id$";

#include "GSWeb.h"

//====================================================================
@implementation GSWMailDelivery

static GSWMailDelivery *sharedInstance;


+ (void)initialize
{
  sharedInstance = [GSWMailDelivery new];
}

+(GSWMailDelivery*)sharedInstance
{
  return sharedInstance;
};

-(NSString*)composeEmailFrom:(NSString*)sender
                          to:(NSArray*)to
                          cc:(NSArray*)cc
                     subject:(NSString*)subject
                   plainText:(NSString*)plainTextMessage
                        send:(BOOL)sendNow
{
  NSString* emailString=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"sender=%@",sender);
  NSDebugMLog(@"to=%@",to);
  NSDebugMLog(@"cc=%@",cc);
  NSDebugMLog(@"subject=%@",subject);
  NSDebugMLog(@"plainTextMessage=%@",plainTextMessage);
  NSDebugMLog(@"sendNow=%d",(int)sendNow);
  emailString=[self composeEmailFrom:sender
                    to:to
                    cc:cc
                    bcc:nil
                    subject:subject
                    plainText:plainTextMessage
                    send:sendNow];
  NSDebugMLog(@"emailString=%@",emailString);
  LOGObjectFnStop();
  return emailString;
};

-(NSString*)composeEmailFrom:(NSString*)sender
                          to:(NSArray*)to
                          cc:(NSArray*)cc
                     subject:(NSString*)subject
                   component:(GSWComponent*)component
                        send:(BOOL)sendNow
{
  NSString* emailString=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"sender=%@",sender);
  NSDebugMLog(@"to=%@",to);
  NSDebugMLog(@"cc=%@",cc);
  NSDebugMLog(@"subject=%@",subject);
  NSDebugMLog(@"component=%@",component);
  NSDebugMLog(@"sendNow=%d",(int)sendNow);
  emailString=[self composeEmailFrom:sender
                    to:to
                    cc:cc
                    bcc:nil
                    subject:subject
                    component:component
                    send:sendNow];
  NSDebugMLog(@"emailString=%@",emailString);
  LOGObjectFnStop();
  return emailString;
};


//NDFN
-(NSString*)composeEmailFrom:(NSString*)sender
                          to:(NSArray*)to
                          cc:(NSArray*)cc
                         bcc:(NSArray*)bcc
                     subject:(NSString*)subject
                   plainText:(NSString*)plainTextMessage
                        send:(BOOL)sendNow
{
  NSString* messageString=nil;
  NSMutableString* toString=nil;
  int i=0;
  int count=0;
  LOGObjectFnStart();
  NSAssert1(!to || [to isKindOfClass:[NSArray class]],@"to is a %@, not a NSArray",[to class]);
  NSAssert1(!cc || [cc isKindOfClass:[NSArray class]],@"cc is a %@, not a NSArray",[cc class]);
  NSAssert1(!bcc || [bcc isKindOfClass:[NSArray class]],@"bcc is a %@, not a NSArray",[bcc class]);
  count=[to count];
  NSDebugMLog(@"sender=%@",sender);
  NSDebugMLog(@"to=%@",to);
  NSDebugMLog(@"cc=%@",cc);
  NSDebugMLog(@"bcc=%@",bcc);
  NSDebugMLog(@"subject=%@",subject);
  NSDebugMLog(@"plainTextMessage=%@",plainTextMessage);
  NSDebugMLog(@"sendNow=%d",(int)sendNow);

  for(i=0;i<count;i++)
    {
      if (!toString)
        toString=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",[to objectAtIndex:i]];
      else
        [toString appendFormat:@", %@",[to objectAtIndex:i]];
    };
  NSDebugMLog(@"toString=%@",toString);
  messageString=[NSString stringWithFormat:@"From: %@\nTo: %@\n",sender,toString];
  NSDebugMLog(@"messageString=%@",messageString);
  count=[cc count];
  if (count)
    {
      NSMutableString* ccString=nil;
      for(i=0;i<count;i++)
        {
          if (!ccString)
            ccString=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",[cc objectAtIndex:i]];
          else
            [ccString appendFormat:@", %@",[cc objectAtIndex:i]];
        };
      NSDebugMLog(@"ccString=%@",ccString);
      messageString=[messageString stringByAppendingFormat:@"Cc: %@\n",ccString];
      NSDebugMLog(@"messageString=%@",messageString);
    };
  count=[bcc count];
  if (count)
    {
      NSMutableString* bccString=nil;
      for(i=0;i<count;i++)
        {
          if (!bccString)
            bccString=(NSMutableString*)[NSMutableString stringWithFormat:@"%@",[bcc objectAtIndex:i]];
          else
            [bccString appendFormat:@", %@",[bcc objectAtIndex:i]];
        };
      NSDebugMLog(@"bccString=%@",bccString);
      messageString=[messageString stringByAppendingFormat:@"Bcc: %@\n",bccString];
      NSDebugMLog(@"messageString=%@",messageString);
    };
  messageString=[messageString stringByAppendingFormat:@"Subject: %@\n\n%@",subject,plainTextMessage];
  NSDebugMLog(@"messageString=%@",messageString);
  if (sendNow)
    [self sendEmail:messageString];
  LOGObjectFnStop();
  return messageString;
};

//NDFN
// Be carefull: this call [context _generateCompleteURLs]
-(NSString*)composeEmailFrom:(NSString*)sender
                          to:(NSArray*)to
                          cc:(NSArray*)cc
                         bcc:(NSArray*)bcc
                     subject:(NSString*)subject
                   component:(GSWComponent*)component
                        send:(BOOL)sendNow
{
//TODO setting the content type of the email as Content-type: text/html. 
  GSWContext* context=nil;
  NSString* plainTextMessage=nil;
  NSString* messageString=nil;
  GSWResponse* response=nil;
  LOGObjectFnStart();
  NSDebugMLog(@"component=%@",component);
  context=[component context];
  NSDebugMLog(@"context=%@",context);
  [context _generateCompleteURLs];
  response=[component generateResponse];
  NSDebugMLog(@"response=%@",response);
  plainTextMessage=[[[NSString alloc]initWithData:[response content]
                                     encoding:[response contentEncoding]] autorelease];
  NSDebugMLog(@"plainTextMessage=%@",plainTextMessage);
  messageString=[self composeEmailFrom:sender
                         to:to
                         cc:cc
                         bcc:bcc
                         subject:subject
                         plainText:plainTextMessage
                         send:sendNow];
  messageString=[[response content]description];
  NSDebugMLog(@"messageString=%@",messageString);
  LOGObjectFnStop();
  return messageString;
};


-(void)sendEmail:(NSString *)emailString
{
  FILE* sendmailFile=NULL;
  NSString* sendmailPath=nil;
  NSString* sendmailCommand=nil;
  NSFileManager* fileManager=nil;
  LOGObjectFnStart();
  //TODO: here we should contact smtp server,... instead au using sendmail
  NSDebugMLog(@"emailString=%@",emailString);
  fileManager=[NSFileManager defaultManager];
  NSAssert(fileManager,@"No fileManager");
  sendmailPath=@"/usr/bin/sendmail";
  if (![fileManager isExecutableFileAtPath:sendmailPath])
    {
      sendmailPath=@"/usr/lib/sendmail";
      if (![fileManager isExecutableFileAtPath:sendmailPath])
        {
          sendmailPath=@"/usr/sbin/sendmail";
          if (![fileManager isExecutableFileAtPath:sendmailPath])
            {
              sendmailPath=@"/bin/sendmail";
              if (![fileManager isExecutableFileAtPath:sendmailPath])
                {
                  sendmailPath=@"/sbin/sendmail";
                  if (![fileManager isExecutableFileAtPath:sendmailPath])
                    {
                      sendmailPath=@"/usr/local/bin/sendmail";
                      if (![fileManager isExecutableFileAtPath:sendmailPath])
                        {
                          sendmailPath=@"/usr/local/lib/sendmail";
                          if (![fileManager isExecutableFileAtPath:sendmailPath])
                            {
                              sendmailPath=@"/usr/local/sbin/sendmail";
                              if (![fileManager isExecutableFileAtPath:sendmailPath])
                                {
                                  sendmailPath=@"sendmail"; //try without absolute path
                                };
                            };
                        };
                    };
                };
            };
        };
    };
  NSDebugMLog(@"sendmailPath=%@",sendmailPath);
  // -i When reading a message from standard  input,  don't treat  a line with only a . character as the end of input.
  // -t Extract  recipients  from  message  headers.   This requires  that  no  recipients  be specified on the command line.
  sendmailCommand=[NSString stringWithFormat:@"%@  -i -t",sendmailPath];
  NSDebugMLog(@"sendmailCommand=%@",sendmailCommand);
  sendmailFile=popen([sendmailCommand lossyCString],"w");
  if (sendmailFile)
    {
      const char* cString=[emailString lossyCString];
      size_t len=strlen(cString);
      size_t written=fwrite(cString, sizeof(char),len,sendmailFile);
      if (written!=len)
        {
          NSDebugMLog(@"Error writing to sendmail (written %d / %d",written,len);
        };
      fclose(sendmailFile);
    }
  else
    {
      NSDebugMLog(@"Can't run sendmail (%@)",sendmailCommand);
    };
  LOGObjectFnStop();

/*  int files[2];
  pid_t pid;
  LOGObjectFnStart();

  NSDebugMLog(@"emailString=%@",emailString);

  if(pipe(files))
    [NSException raise:NSInternalInconsistencyException format:@"%@ -- %@ 0x%x: cannot create pipe", 
                 NSStringFromSelector(_cmd), 
                 NSStringFromClass([self class]), 
                 self];

  switch(pid = fork())
    {
    case 0:
      NSDebugMLog(@"FORK0");
      close(0);
      dup(files[0]);
      close(files[0]);
      close(files[1]);

      execlp("sendmail", "sendmail", "-i", "-t", NULL);

      break;

    case -1:
      NSDebugMLog(@"FORK-1");
      close(files[0]);
      close(files[1]);
      [NSException raise:NSInternalInconsistencyException format:@"%@ -- %@ 0x%x: cannot fork process", 
                   NSStringFromSelector(_cmd), 
                   NSStringFromClass([self class]), 
                   self];
      break;

    default:
      NSDebugMLog(@"FORKDEF");
      write(files[1], [emailString cString], strlen([emailString cString]));
      close(files[0]);
      close(files[1]);

      waitpid(pid, NULL, 0);
      break;
    }
  LOGObjectFnStop();
*/
};

-(void)_invokeGSWSendMailAt:(id)at
                  withEmail:(id)email
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end



/** GSWMailDelivery.m - <title>GSWeb: Class GSWMailDelivery</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
   
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

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

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

  emailString=[self composeEmailFrom:sender
                    to:to
                    cc:cc
                    bcc:nil
                    subject:subject
                    plainText:plainTextMessage
                    send:sendNow];

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

  emailString=[self composeEmailFrom:sender
                    to:to
                    cc:cc
                    bcc:nil
                    subject:subject
                    component:component
                    send:sendNow];

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
  NSMutableString* messageString=nil;
  NSMutableString* toString=nil;
  int i=0;
  int count=0;
  NSAssert1(!to || [to isKindOfClass:[NSArray class]],@"to is a %@, not a NSArray",[to class]);
  NSAssert1(!cc || [cc isKindOfClass:[NSArray class]],@"cc is a %@, not a NSArray",[cc class]);
  NSAssert1(!bcc || [bcc isKindOfClass:[NSArray class]],@"bcc is a %@, not a NSArray",[bcc class]);
  count=[to count];

  for(i=0;i<count;i++)
    {
      if (!toString)
        toString=(NSMutableString*)[NSMutableString stringWithString:NSStringWithObject([to objectAtIndex:i])];
      else
        {
          [toString appendString:@", "];
          [toString appendString:NSStringWithObject([to objectAtIndex:i])];
        };
    };
  messageString=(NSMutableString*)[NSMutableString string];

  // From:
  [messageString appendString:@"From: "];
  [messageString appendString:NSStringWithObject(sender)];
  [messageString appendString:@"\n"];

  // To:
  [messageString appendString:@"To: "];
  [messageString appendString:toString];
  [messageString appendString:@"\n"];

  count=[cc count];
  if (count)
    {
      NSMutableString* ccString=nil;
      for(i=0;i<count;i++)
        {
          if (!ccString)
            ccString=(NSMutableString*)[NSMutableString stringWithString:NSStringWithObject([cc objectAtIndex:i])];
          else
            {
              [ccString appendString:@", "];
              [ccString appendString:NSStringWithObject([cc objectAtIndex:i])];
            };
        };

      // cc:
      [messageString appendString:@"Cc: "];
      [messageString appendString:ccString];
      [messageString appendString:@"\n"];
    };
  count=[bcc count];
  if (count)
    {
      NSMutableString* bccString=nil;
      for(i=0;i<count;i++)
        {
          if (!bccString)
            bccString=(NSMutableString*)[NSMutableString stringWithString:NSStringWithObject([bcc objectAtIndex:i])];
          else
            {
              [bccString appendString:@", "];
              [bccString appendString:NSStringWithObject([bcc objectAtIndex:i])];
            };
        };

      // Bcc:
      [messageString appendString:@"Bcc: "];
      [messageString appendString:bccString];
      [messageString appendString:@"\n"];
    };

  //Subject
  [messageString appendString:@"Subject: "];
  [messageString appendString:NSStringWithObject(subject)];
  [messageString appendString:@"\n\n"];

  // plainTextMessage
  [messageString appendString:NSStringWithObject(plainTextMessage)];

  if (sendNow)
    [self sendEmail:messageString];
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

  context=[component context];
  [context _generateCompleteURLs];
  response=[component generateResponse];
  plainTextMessage=[[[NSString alloc]initWithData:[response content]
                                     encoding:[response contentEncoding]] autorelease];

  messageString=[self composeEmailFrom:sender
                         to:to
                         cc:cc
                         bcc:bcc
                         subject:subject
                         plainText:plainTextMessage
                         send:sendNow];
  messageString=[[response content]description];

  return messageString;
};


-(void)sendEmail:(NSString *)emailString
{
  FILE* sendmailFile=NULL;
  NSString* sendmailPath=nil;
  NSString* sendmailCommand=nil;
  NSFileManager* fileManager=nil;
  //TODO: here we should contact smtp server,... instead au using sendmail
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
  // -i When reading a message from standard  input,  don't treat  a line with only a . character as the end of input.
  // -t Extract  recipients  from  message  headers.   This requires  that  no  recipients  be specified on the command line.
  sendmailCommand=[sendmailPath stringByAppendingString:@" -i -t"];
  sendmailFile=popen([sendmailCommand lossyCString],"w");
  if (sendmailFile)
    {
      const char* cString=[emailString lossyCString];
      size_t len=strlen(cString);
      size_t written=fwrite(cString, sizeof(char),len,sendmailFile);
      if (written!=len)
        {
//          NSDebugMLog(@"Error writing to sendmail (written %d / %d",written,len);
        };
      fclose(sendmailFile);
    }
  else
    {
      NSLog(@"Can't run sendmail (%@)",sendmailCommand);
    };

};

-(void)_invokeGSWSendMailAt:(id)at
                  withEmail:(id)email
{
  [self notImplemented: _cmd];	//TODOFN
};

@end



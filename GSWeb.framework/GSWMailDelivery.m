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

#include <GSWeb/GSWeb.h>

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
  NSDebugMLog(@"sender=%@",sender);
  NSDebugMLog(@"to=%@",to);
  NSDebugMLog(@"cc=%@",cc);
  NSDebugMLog(@"subject=%@",subject);
  NSDebugMLog(@"plainTextMessage=%@",plainTextMessage);
  NSDebugMLog(@"sendNow=%d",(int)sendNow);
  return [self composeEmailFrom:sender
               to:to
               cc:cc
               bcc:nil
               subject:subject
               plainText:plainTextMessage
               send:sendNow];
};

-(NSString*)composeEmailFrom:(NSString*)sender
                          to:(NSArray*)to
                          cc:(NSArray*)cc
                     subject:(NSString*)subject
                   component:(GSWComponent*)component
                        send:(BOOL)sendNow
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
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
  return messageString;
};

//NDFN
-(NSString*)composeEmailFrom:(NSString*)sender
                          to:(NSArray*)to
                          cc:(NSArray*)cc
                         bcc:(NSArray*)bcc
                     subject:(NSString*)subject
                   component:(GSWComponent*)component
                        send:(BOOL)sendNow
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

-(void)sendEmail:(NSString *)emailString_
{
  int files[2];
  pid_t pid;

  NSDebugMLog(@"emailString_=%@",emailString_);

  if(pipe(files))
    [NSException raise:NSInternalInconsistencyException format:@"%@ -- %@ 0x%x: cannot create pipe", 
                 NSStringFromSelector(_cmd), 
                 NSStringFromClass([self class]), 
                 self];

  switch(pid = fork())
    {
    case 0:
      close(0);
      dup(files[0]);
      close(files[0]);
      close(files[1]);

      execlp("sendmail", "sendmail", "-i", "-t", NULL);

      break;

    case -1:
      close(files[0]);
      close(files[1]);
      [NSException raise:NSInternalInconsistencyException format:@"%@ -- %@ 0x%x: cannot fork process", 
                   NSStringFromSelector(_cmd), 
                   NSStringFromClass([self class]), 
                   self];
      break;

    default:
      write(files[1], [emailString_ cString], strlen([emailString_ cString]));
      close(files[0]);
      close(files[1]);

      waitpid(pid, NULL, 0);
      break;
    }
};

-(void)_invokeGSWSendMailAt:(id)at
                  withEmail:(id)email
{
  LOGObjectFnNotImplemented();	//TODOFN
};

@end


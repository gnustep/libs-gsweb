/** GSWTemplateParserXML.m - <title>GSWeb: Class GSWTemplateParserXML</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 1999
   
   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

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
#include "GSWTemplateParserXML.h"
#include <libxml/parser.h>
#include <libxml/parserInternals.h>
#include <libxml/SAX.h>
#include <libxml/HTMLparser.h>

extern xmlParserInputPtr xmlNewStringInputStream(xmlParserCtxtPtr ctxt,
                                                 const xmlChar *buffer);

static NSLock* GSXMLParserLock=nil;
static NSMutableDictionary* DTDCache=nil;
static NSMutableDictionary* DTDFilePathCache=nil;

@interface GSWTemplateParserSAXHandler (Private)
-(xmlParserInputPtr)resolveEntity:(NSString*)publicIdEntity
                         systemID:(NSString*)systemIdEntity;
@end

//====================================================================
@implementation GSWTemplateParserSAXHandler

//--------------------------------------------------------------------
+ (void) initialize
{
  // Initialize DTD Cache, and Lock
  if (self==[GSWTemplateParserSAXHandler class])
    {
      if (!DTDCache)
        DTDCache=[NSMutableDictionary new];
      if (!DTDFilePathCache)
        DTDFilePathCache=[NSMutableDictionary new];
      if (!GSXMLParserLock)
        GSXMLParserLock=[NSRecursiveLock new];
    };
};

//--------------------------------------------------------------------
+(void)dealloc
{
  // Dealloc DTD Cache and Lock
  if (self==[GSWTemplateParserSAXHandler class])
    {
      DESTROY(DTDCache);
      DESTROY(DTDFilePathCache);
      DESTROY(GSXMLParserLock);
    };
};

//--------------------------------------------------------------------
/*"Lock"*/
+(void)lock
{
  NS_DURING
    {
      [GSXMLParserLock lock];
    }
  NS_HANDLER
    {
      NSLog(@"EXCEPTION:(GSXMLParserLock lock) %@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
      [localException raise];
    };
  NS_ENDHANDLER;
};

//--------------------------------------------------------------------
/*"Unlock"*/
+(void)unlock
{
  NS_DURING
    {
      [GSXMLParserLock unlock];
    }
  NS_HANDLER
    {
      NSLog(@"EXCEPTION:(GSXMLParserLock unlock) %@ (%@) [%s %d]",localException,[localException reason],__FILE__,__LINE__);
      [localException raise];
    };
  NS_ENDHANDLER;
};

//--------------------------------------------------------------------
/** Find cached DTD Content for Key url **/
+(NSString*)cachedDTDContentForKey:(NSString*)url
{
  NSString* content=nil;
  [self lock];
  content=[DTDCache objectForKey:url];
  [self unlock];
  return content;
};

//--------------------------------------------------------------------
/** Cache DTD Content externalContent for Key url **/
+(void)setCachedDTDContent:(NSString*)externalContent
                    forKey:(NSString*)url
{
  [self lock];
  [DTDCache setObject:externalContent
            forKey:url];
  [self unlock];
};

//--------------------------------------------------------------------
/** Find cached DTD FilePath for Key url **/
+(NSString*)cachedDTDFilePathForKey:(NSString*)url
{
  NSString* filePath=nil;
  [self lock];
  filePath=[DTDFilePathCache objectForKey:url];
  [self unlock];
  return filePath;
};

//--------------------------------------------------------------------
/** Cache DTD FilePath for Key url **/
+(void)setCachedDTDFilePath:(NSString*)filePath
                    forKey:(NSString*)url
{
  [self lock];
  [DTDFilePathCache setObject:filePath
                    forKey:url];
  [self unlock];
};

//--------------------------------------------------------------------
+(id)handlerWithTemplateParser:(GSWTemplateParser*)templateParser
{
  return AUTORELEASE([[self alloc] initWithTemplateParser:templateParser]);
};  

extern void            externalSubset                  (void *ctx,
                                                        const xmlChar *name,
                                                        const xmlChar *ExternalID,
                                                        const xmlChar *SystemID);

//--------------------------------------------------------------------
-(id)initWithTemplateParser:(GSWTemplateParser*)templateParser
{
  if ((self=[self init]))
    {
      _templateParser=templateParser;
      //NSLog(@"my sax lib=%p",lib);
      if (lib)
        {
          xmlSAXHandlerPtr def=NULL;
          if ([_templateParser isKindOfClass:[GSWTemplateParserXMLHTML class]])
            def=&htmlDefaultSAXHandler;
          else
            def=&xmlDefaultSAXHandler;
          ((xmlSAXHandlerPtr)lib)->internalSubset         = def->internalSubset;
          ((xmlSAXHandlerPtr)lib)->isStandalone           = def->isStandalone;
          ((xmlSAXHandlerPtr)lib)->hasInternalSubset      = def->hasInternalSubset;
          ((xmlSAXHandlerPtr)lib)->hasExternalSubset      = def->hasExternalSubset;
          ((xmlSAXHandlerPtr)lib)->resolveEntity          = def->resolveEntity;
          ((xmlSAXHandlerPtr)lib)->getEntity              = def->getEntity;
          ((xmlSAXHandlerPtr)lib)->entityDecl             = def->entityDecl;
          ((xmlSAXHandlerPtr)lib)->notationDecl           = def->notationDecl;
          ((xmlSAXHandlerPtr)lib)->attributeDecl          = def->attributeDecl;
          ((xmlSAXHandlerPtr)lib)->elementDecl            = def->elementDecl;
          ((xmlSAXHandlerPtr)lib)->unparsedEntityDecl     = def->unparsedEntityDecl;
          ((xmlSAXHandlerPtr)lib)->startDocument          = def->startDocument;
          ((xmlSAXHandlerPtr)lib)->endDocument            = def->endDocument;
          ((xmlSAXHandlerPtr)lib)->startElement           = def->startElement;
          ((xmlSAXHandlerPtr)lib)->endElement             = def->endElement;
          ((xmlSAXHandlerPtr)lib)->reference              = def->reference;
          ((xmlSAXHandlerPtr)lib)->characters             = def->characters;
          ((xmlSAXHandlerPtr)lib)->ignorableWhitespace    = def->ignorableWhitespace;
          ((xmlSAXHandlerPtr)lib)->processingInstruction  = def->processingInstruction;
          ((xmlSAXHandlerPtr)lib)->comment                = def->comment;
          //    ((xmlSAXHandlerPtr)lib)->warning                = xmlParserWarning;
          //    ((xmlSAXHandlerPtr)lib)->error                  = xmlParserError;
          //    ((xmlSAXHandlerPtr)lib)->fatalError             = xmlParserError;
          ((xmlSAXHandlerPtr)lib)->getParameterEntity     = def->getParameterEntity;
          ((xmlSAXHandlerPtr)lib)->cdataBlock             = def->cdataBlock;
          ((xmlSAXHandlerPtr)lib)->externalSubset         = def->externalSubset;
        };
    };
  return self;
};

-(id)init
{
  if ((self=[super init]))
    {
    };
  return self;
};

+ (NSString*) loadEntity: (NSString*)publicId
                      at: (NSString*)location
{
  NSDebugMLog(@"+LOAD ENTITY pid=%@ l=%@",publicId,location);
  return nil;
}

/** Should return a file path
    publicId: for exemple: -//W3C//DTD XHTML 1.0 Transitional//EN
    location: for exemple: xhtml1-transitional.dtd
**/
- (NSString*) loadEntity: (NSString*)publicId
                      at: (NSString*)location
{  
  NSString* filePath=nil;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWTemplateParser",@"loadEntity:%@ at:%@\n",
               publicId,
               location);
  NSAssert(publicId || location,
           @"resolveEntity: publicId and location are both nil");
  if (location)
    {
      NSString* resourceName=location;
      if ([[resourceName pathExtension] isEqual:@"dtd"])
        resourceName=[resourceName stringByDeletingPathExtension];
      filePath = [[NSBundle bundleForClass: [self class]]
                   pathForResource:resourceName
                   ofType:@"dtd"
                   inDirectory:@"DTDs"];
      NSDebugMLLog(@"GSWTemplateParser",@"location: fileName=%@ for Resource:%@",filePath,resourceName);
    };
  if (!filePath && publicId)
    {
      filePath=[[self class] cachedDTDFilePathForKey:publicId];
      if (!filePath)
        {
          //Well Known DTDs / Entities
          if ([publicId hasPrefix:@"-//"])
            {
              // 0: -
              // 1: W3C or IETF
              // 2: DTD ... or ENTITIES ...
              // 3: EN or ... (language)
              NSArray* parts=[publicId componentsSeparatedByString:@"//"];
              if ([parts count]>=2)
                {
                  NSString* whatPart=[parts objectAtIndex:2];
                  if ([whatPart hasPrefix:@"DTD"])
                    {
                      NSString* resourceName=nil;
                      if ([whatPart rangeOfString:@"Transitional"].length>0)
                        resourceName=@"xhtml1-transitional.dtd";
                      else if ([whatPart rangeOfString:@"Strict"].length>0)
                        resourceName=@"xhtml1-strict.dtd";
                      else if ([whatPart rangeOfString:@"Frameset"].length>0)
                        resourceName=@"xhtml1-frameset.dtd";
                      else
                        {
                          NSDebugMLog(@"Unknown DTD: %@. Choose default: xhtml1-transitional.dtd",publicId);
                          resourceName=@"xhtml1-transitional.dtd"; // guess
                        };
                      if (resourceName)
                        {
                          if ([[resourceName pathExtension] isEqual:@"dtd"])
                            resourceName=[resourceName stringByDeletingPathExtension];
                          filePath = [[NSBundle bundleForClass: [self class]]
				       pathForResource:resourceName
				       ofType:@"dtd"
				       inDirectory:@"DTDs"];
                          NSDebugMLLog(@"GSWTemplateParser",@"fileName=%@ for Resource:%@",filePath,publicId);
                        };
                    }
                  else if ([whatPart hasPrefix:@"ENTITIES"])
                    {
                      NSString* resourceName=nil;
                      if ([whatPart rangeOfString:@"Symbols"].length>0)
                        resourceName=@"xhtml-symbol.ent";
                      else if ([whatPart rangeOfString:@"Special"].length>0)
                        resourceName=@"xhtml-special.ent";
                      else if ([whatPart rangeOfString:@"Latin 1"].length>0)
                        resourceName=@"xhtml-lat1.ent";
                      else
                        {
                          NSDebugMLog(@"Unknown ENTITIES: %@",publicId);
                        };
                      if (resourceName)
                        {
                          if ([[resourceName pathExtension] isEqual:@"ent"])
                            resourceName=[resourceName stringByDeletingPathExtension];
                          filePath = [[NSBundle bundleForClass: [self class]]
				       pathForResource:resourceName
				       ofType:@"ent"
				       inDirectory:@"DTDs"];
                          NSDebugMLLog(@"GSWTemplateParser",@"fileName=%@ for Resource:%@",filePath,publicId);
                        };
                    }
                  else
                    {
                      NSDebugMLog(@"Unknown publicId %@",publicId);
                    };
                }
              else
                {
                  NSDebugMLog(@"Don't know how to parse publicId %@",publicId);
                };
            }
          else
            {
              NSDebugMLog(@"Don't know what to do with publicId %@",publicId);
            };
          if (filePath)
            [[self class] setCachedDTDFilePath:filePath
                          forKey:publicId];
        };
    };
  if (!filePath)
    {
      NSDebugMLog(@"Can't load external (publicId:%@ location:%@)",publicId,location);
    }
  else
    {
      NSDebugMLLog(@"GSWTemplateParser",@"LOADED: resolveEntity:%@ location:%@ filePath:%@\n",
                   publicId,
                   location,
                   filePath);
    };
  LOGObjectFnStop();
  return filePath;
               
}

- (void*) getEntity: (NSString*)name
{
  NSDebugMLog(@"-GET ENTITY %@",name);
  return 0;
}

/*
xmlParserInputPtr GSWTemplateParserSAXHandler_ExternalLoader(const char *systemId,
                                                             const char *publicId,
                                                             xmlParserCtxtPtr context)
{
//  NSCAssert(context,@"No Parser Context");
//  NSCAssert(context->_private,@"No GSSAXHandler reference in Parser Context");
//  return [(GSSAXHandler*)(context->_private)resolveEntity:[NSString stringWithCString:publicId]
//                         systemID:[NSString stringWithCString:systemId]];
  return NULL;
}
*/

//--------------------------------------------------------------------
//exemple:
// publicIdEntity
//		-//IETF//DTD HTML//EN
// 		-//W3C//ENTITIES Special for XHTML//EN
//		-//W3C//ENTITIES Symbols for XHTML//EN
//		-//W3C//ENTITIES Latin 1 for XHTML//EN
//		-//W3C//DTD XHTML 1.0 Transitional//EN
//		-//W3C//DTD XHTML 1.0 Strict//EN
//		-//W3C//DTD XHTML 1.0 Frameset//EN
//		-//W3C//DTD HTML 4.01//EN
//		-//W3C//DTD HTML 4.01 Transitional//EN
//		-//W3C//DTD HTML 4.01 Frameset//EN
//		-//IETF//DTD HTML//EN
//		-//W3C//DTD HTML 3.2//EN
// systemIdEntity
//		http://www.w3c.org/html.dtd
//		html.dtd

-(xmlParserInputPtr)resolveEntity:(NSString*)publicIdEntity
                         systemID:(NSString*)systemIdEntity
{
  NSString* externalContent=nil;
  xmlParserInputPtr	result = 0;
  LOGObjectFnStart();
  NSDebugMLLog(@"GSWTemplateParser",@"resolveEntity:%@ systemID:%@ inParserContext:%p\n",
        publicIdEntity,
        systemIdEntity,
        lib);
  NSAssert(publicIdEntity || systemIdEntity,
           @"resolveEntity:systemIdEntity: publicIdEntity and systemIdEntity are both nil");
  if (systemIdEntity)
    {
      externalContent=[[self class] cachedDTDContentForKey:systemIdEntity];
      if (!externalContent)
        {
          NSString* fileName=nil;
          NSString* resourceName=systemIdEntity;
          if ([[resourceName pathExtension] isEqual:@"dtd"])
            resourceName=[resourceName stringByDeletingPathExtension];
          fileName = [[NSBundle bundleForClass: [self class]]
		       pathForResource:resourceName
		       ofType:@"dtd"
		       inDirectory:@"DTDs"];
          NSDebugMLLog(@"GSWTemplateParser",@"systemIdEntity: fileName=%@ for Resource:%@",fileName,resourceName);
          if (fileName)
            {
              externalContent=[NSString stringWithContentsOfFile:fileName];
            };
          externalContent=[NSString stringWithContentsOfFile:fileName];
          if (externalContent)
            {
              NSString* gswebTag=@"\n<!ELEMENT gsweb %Flow;>\n<!ATTLIST gsweb\n  %attrs;\n  >\n";
              //  name       NMTOKEN;       #IMPLIED
              NSDebugMLLog(@"GSWTemplateParser",@"gswebTag=\n%@",gswebTag);
              externalContent=[externalContent stringByAppendingString:gswebTag];

              [[self class] setCachedDTDContent:externalContent
                            forKey:systemIdEntity];
            };
        };
    };
  if (!externalContent && publicIdEntity)
    {
      externalContent=[[self class] cachedDTDContentForKey:publicIdEntity];
      if (!externalContent)
        {
          //Well Known DTDs / Entities
          if ([publicIdEntity hasPrefix:@"-//"])
            {
              // 0: -
              // 1: W3C or IETF
              // 2: DTD ... or ENTITIES ...
              // 3: EN or ... (language)
              NSArray* parts=[publicIdEntity componentsSeparatedByString:@"//"];
              if ([parts count]>=2)
                {
                  NSString* whatPart=[parts objectAtIndex:2];
                  if ([whatPart hasPrefix:@"DTD"])
                    {
                      NSString* resourceName=nil;
                      NSString* fileName=nil;
                      if ([whatPart rangeOfString:@"Transitional"].length>0)
                        resourceName=@"xhtml1-transitional.dtd";
                      else if ([whatPart rangeOfString:@"Strict"].length>0)
                        resourceName=@"xhtml1-strict.dtd";
                      else if ([whatPart rangeOfString:@"Frameset"].length>0)
                        resourceName=@"xhtml1-frameset.dtd";
                      else
                        {
                          NSDebugMLog(@"Unknown DTD: %@. Choose default: xhtml1-transitional.dtd",publicIdEntity);
                          resourceName=@"xhtml1-transitional.dtd"; // guess
                        };
                      if (resourceName)
                        {
                          if ([[resourceName pathExtension] isEqual:@"dtd"])
                            resourceName=[resourceName stringByDeletingPathExtension];
                          fileName = [[NSBundle bundleForClass: [self class]]
				       pathForResource:resourceName
				       ofType:@"dtd"
				       inDirectory:@"DTDs"];
                          NSDebugMLLog(@"GSWTemplateParser",@"systemIdEntity: fileName=%@ for Resource:%@",fileName,publicIdEntity);
                          if (fileName)
                            {
                              externalContent=[NSString stringWithContentsOfFile:fileName];
                            };
                        };
                    }
                  else if ([whatPart hasPrefix:@"ENTITIES"])
                    {
                      NSString* resourceName=nil;
                      NSString* fileName=nil;
                      if ([whatPart rangeOfString:@"Symbols"].length>0)
                        resourceName=@"xhtml-symbol.ent";
                      else if ([whatPart rangeOfString:@"Special"].length>0)
                        resourceName=@"xhtml-special.ent";
                      else if ([whatPart rangeOfString:@"Latin 1"].length>0)
                        resourceName=@"xhtml-lat1.ent";
                      else
                        {
                          NSDebugMLog(@"Unknown ENTITIES: %@",publicIdEntity);
                        };
                      if (resourceName)
                        {
                          if ([[resourceName pathExtension] isEqual:@"ent"])
                            resourceName=[resourceName stringByDeletingPathExtension];
                          fileName = [[NSBundle bundleForClass: [self class]]
				       pathForResource:resourceName
				       ofType:@"ent"
				       inDirectory:@"DTDs"];
                          NSDebugMLLog(@"GSWTemplateParser",@"systemIdEntity: fileName=%@ for Resource:%@",fileName,publicIdEntity);
                          if (fileName)
                            {
                              externalContent=[NSString stringWithContentsOfFile:fileName];
                            };
                        };
                    }
                  else
                    {
                      NSDebugMLog(@"Unknown publicIdEntity %@",publicIdEntity);
                    };
                }
              else
                {
                  NSDebugMLog(@"Don't know how to parse publicIdEntity %@",publicIdEntity);
                };
            }
          else
            {
              NSDebugMLog(@"Don't know what to do with publicIdEntity %@",publicIdEntity);
            };
          if (externalContent)
            [[self class] setCachedDTDContent:externalContent
                          forKey:publicIdEntity];
        };
    };
  if (externalContent)
    {
      result=xmlNewStringInputStream(lib,[externalContent cString]);
    };
  NSAssert2(result,@"Can't load external (publicIdEntity:%@ systemIdEntity:%@)",publicIdEntity,systemIdEntity);
  NSDebugMLLog(@"GSWTemplateParser",@"LOADED: resolveEntity:%@ systemID:%@ inParserContext:%p\n",
        publicIdEntity,
        systemIdEntity,
        lib);
  LOGObjectFnStop();
  return result;
};

//--------------------------------------------------------------------
-(void)warning:(NSString*)message
     colNumber:(int)colNumber
    lineNumber:(int)lineNumber
{
  [[GSWApplication application] logWithFormat:@"%@ Warning (col %d,line %d): %@",
                                [_templateParser logPrefix],
                                colNumber,
                                lineNumber,
                                message];
};

//--------------------------------------------------------------------
-(void)error: (NSString*)message
     colNumber:(int)colNumber
    lineNumber:(int)lineNumber
{
  NSString* testMessage=[[message lowercaseString] stringByTrimmingSpaces];
  if (![testMessage isEqualToString:@"tag webobject invalid"]
      && ![testMessage isEqualToString:@"tag gsweb invalid"]
      && ![testMessage isEqualToString:@"htmlparsestarttag: misplaced <html> tag"]
      && ![testMessage isEqualToString:@"htmlparsestarttag: misplaced <head> tag"]
      && ![testMessage isEqualToString:@"unexpected end tag : head"])
    {
      [[GSWApplication application] logErrorWithFormat:@"%@ Error (line %d,col %d): %@",
                                    [_templateParser logPrefix],
                                    lineNumber,
                                    colNumber,
                                    message];
    };
};

//--------------------------------------------------------------------
-(void)fatalError: (NSString*)message
     colNumber:(int)colNumber
    lineNumber:(int)lineNumber
{
  [[GSWApplication application] logErrorWithFormat:@"%@ Fatal Error (line %d,col %d): %@",
                                [_templateParser logPrefix],
                                lineNumber,
                                colNumber,
                                message];
};

@end

//====================================================================
@implementation GSWTemplateParserXML

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_xmlDocument);
  [super dealloc];
};

//--------------------------------------------------------------------
static NSString* TabsForLevel(int level)
{
  int i=0;
  NSMutableString* tabs=[NSMutableString string];
  for (i=0;i<level;i++)
    {
      [tabs appendString:@"\t"];
    };
  return tabs;
};

//--------------------------------------------------------------------
-(NSString*)dumpNode:(GSXMLNode*)node
             atLevel:(int)level
{
  NSString* dumpString=[NSString string];
  LOGObjectFnStart();
  while (node)
    {
      const char* content=[[node content] lossyCString];
      dumpString=[dumpString stringByAppendingFormat:@"%@%@ [Type:%@] [%@]%s%s\n",
                             TabsForLevel(level),
                             [node name],
                             [node typeDescription],
                             [node propertiesAsDictionaryWithKeyTransformationSel:NULL],
                             (content ? ":\n" : ""),
                             (content ? content : "")];
      if ([node firstChild])
        dumpString=[dumpString stringByAppendingString:[self dumpNode:[node firstChild]
                                                             atLevel:level+1]];
      node=[node next];
    };
  LOGObjectFnStop();
  return dumpString;
};

//--------------------------------------------------------------------
-(NSArray*)templateElements
{
  NSArray* elements=nil;
  LOGObjectFnStart();
  if (!_xmlDocument)
    {
      BOOL parseOk=NO;
      GSXMLParser* parser=nil;
      GSWTemplateParserSAXHandler* sax=nil;
      NSStringEncoding stringEncoding=_stringEncoding;

      if (stringEncoding==GSUndefinedEncoding)
        stringEncoding=[GSWMessage defaultEncoding];
        
      sax=[GSWTemplateParserSAXHandler handlerWithTemplateParser:self];
      if ([self isKindOfClass:[GSWTemplateParserXMLHTML class]])
        {
          NSRange tagRange=NSMakeRange(NSNotFound,0);
          tagRange=[_string rangeOfString:@"<HTML"
                            options:NSCaseInsensitiveSearch];
          //NSDebugMLLog(@"GSWTemplateParser",@"HTML Tag Range length=%d",tagRange.length);
          if (tagRange.length>0)
            _isHTMLTag=YES;
          tagRange=[_string rangeOfString:@"<BODY"
                            options:NSCaseInsensitiveSearch];
          //NSDebugMLLog(@"GSWTemplateParser",@"BODY Tag Range length=%d",tagRange.length);
          if (tagRange.length>0)
            _isBodyTag=YES;
          parser=[GSHTMLParser parserWithSAXHandler:sax
                               withData:[_string dataUsingEncoding:stringEncoding]];
          NSDebugMLog(@"_string (%d)=%@",[_string length],_string);
        }
      else
        {
          NSData* dataToParse=nil;
          NSString* xmlHeader=nil;
          //NSRange docTypeRange=NSMakeRange(NSNotFound,0);
          NSString* stringToParse=nil;
          NSString* encodingString=nil;
          encodingString=[GSXMLParser xmlEncodingStringForStringEncoding:stringEncoding];
          if (encodingString)
            encodingString=[NSString stringWithFormat:@" encoding=\"%@\"",encodingString];
          else
            encodingString=@"";
          
          stringToParse=_string;

          // Add a <gsweb> null tag around the code because libxml parser doesn't support <tag>..</tag><tag>..</tag>...
          stringToParse=[NSString stringWithFormat:@"<gsweb>\n%@\n</gsweb>\n",stringToParse];

          // Build the header
          xmlHeader=[NSString stringWithFormat:@"<?xml version=\"%@\"%@?>\n",
                              @"1.0",
                              encodingString];

          /* Don't care about DOCTYPE !
            docTypeRange=[stringToParse rangeOfString:@"<!DOCTYPE"];
            if (docTypeRange.length==0)
            stringToParse=[@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"xhtml1-transitional.dtd\">\n" 
            stringByAppendingString:stringToParse];
          */
          stringToParse=[xmlHeader stringByAppendingString:stringToParse];
          NSDebugMLog(@"stringToParse (%d)=%@",[stringToParse length],stringToParse);
          dataToParse=[stringToParse dataUsingEncoding:stringEncoding];
          _isHTMLTag=YES; // Don't remove HTML tags in parsed tree
          _isBodyTag=YES; // Don't remove BODY tags in parsed tree
          parser=[GSXMLParser parserWithSAXHandler:sax
                              withData:dataToParse];
          [parser keepBlanks:YES];
        };
      [parser doValidityChecking:YES];
      [parser getWarnings:YES];
      //[parser setExternalEntityLoader:GSWTemplateParserSAXHandler_ExternalLoader];
      NS_DURING
        {
          parseOk=[parser parse];
        }
      NS_HANDLER
        {
          LOGError(@"%@ Exception in parse! Exception: %@",
                   [self logPrefix],
                   localException);
          localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                  @"%@ - In [parser parse] Exception!",
                                                                  [self logPrefix]);
          [localException retain];
          [localException autorelease];
          [localException raise];
        }
      NS_ENDHANDLER;
      if (!parseOk)
        {
          int errNo=[parser errNo];
          // We point out only deep error
          switch(errNo)
            {
            case XML_ERR_NO_DTD:
              NSDebugMLLog(@"GSWTemplateParser",@"%@ - Warning: No DTD",
                           [self logPrefix]);
              break;
            default:              
              NSDebugMLLog(@"GSWTemplateParser",@"######Parse FAILED errNo=%d [parser document]=%p",
                           [parser errNo],
                           [parser document]);
              break;
            };
          // May be validity errors only (like no HTML root)
          if ([parser document])
            parseOk=YES;
        };
      if (parseOk)
        {
          GSXMLNode* node=nil;
          NSDebugMLLog(@"GSWTemplateParser",@"Root");
          ASSIGN(_xmlDocument,[parser document]);
          node=[_xmlDocument root];
          NSAssert1(node,@"%@ Empty Document (root)",
                    [self logPrefix]);
#ifndef NDEBUG
          {
	    NSString* dumpString=[self dumpNode:node
                                       atLevel:0];
            NSDebugMLLog0(@"low",@"Will dump _xmlDocument");
            NSDebugMLLog(@"GSWTemplateParser",@"%@ _xmlDocument=\n%@",
                         [self logPrefix],
                         dumpString);
            NSDebugMLLog0(@"low",@"_xmlDocument dumped");
          };
#endif
/*
	  if ([node type]==XML_DTD_NODE) {
			NSLog(@"GSWTemplateParserXML: XML_DTD_NODE is found");
	  }

      NSLog(@"ROOT node=%p %@ [Type:%@] [%@] ##%s##\n",
                  node,
                  [node name],
                  [node typeDescription],
                  [node propertiesAsDictionaryWithKeyTransformationSel:NULL],
                  [[node content] lossyCString]);
*/

          /*			  if (node->type!=XML_DTD_NODE)
                                  {
                                  NSLog(@"Bad first node type: %@ instead of %@",
                                  [nodeTypes objectForKey:[NSString stringWithFormat:@"%d",(int)node->type]],
                                  [nodeTypes objectForKey:[NSString stringWithFormat:@"%d",(int)XML_DTD_NODE]]);
                                  };
          */
//          NSDebugMLLog(@"GSWTemplateParser",@"Test Root");
          if ([node type]!=XML_ELEMENT_NODE)
            node=[node firstChild];
//          NSDebugMLLog(@"GSWTemplateParser",@"Test Root children");
          NSAssert1(node,@"%@ Empty Document ([root firstChild])",
                    [self logPrefix]);
          if ([node type]!=XML_ELEMENT_NODE)
            node=[node next];
//          NSDebugMLLog(@"GSWTemplateParser",@"Test Root children Next");
          NSAssert1(node,@"%@ Empty Document ([[root firstChild] next])",
                    [self logPrefix]);
          //Remove html and body node when they have been added by html parser
          if (!_isHTMLTag || !_isBodyTag)
          {
            BOOL cont=YES;
            while (node && cont)
              {
                cont=NO;
                if ([node type]==XML_ELEMENT_NODE)
                  {
                    NSString* nodeName=[node name];
/*                    NSDebugMLLog(@"GSWTemplateParser",@"node name=%@",nodeName);
                    NSDebugMLLog(@"GSWTemplateParser",@"_isHTMLTag=%s _isBodyTag=%s",
                          (_isHTMLTag ? "YES" : "NO"),
                          (_isBodyTag ? "YES" : "NO"));
*/                  
/*
      NSLog(@"while1 node=%p %@ [Type:%@] [%@] ##%s##\n",
                  node,
                  [node name],
                  [node typeDescription],
                  [node propertiesAsDictionaryWithKeyTransformationSel:NULL],
                  [[node content] lossyCString]);
*/
                    if ((!_isHTMLTag && [nodeName caseInsensitiveCompare:@"html"]==NSOrderedSame)
                        || (!_isBodyTag && [nodeName caseInsensitiveCompare:@"body"]==NSOrderedSame))
                      {
//                        NSDebugMLLog(@"GSWTemplateParser",@"==> Children");
                        node=[node firstChild];
                        cont=YES;
                      };
                  };
              };
          };
          if (node)
            {
              //NSDebugMLLog(@"GSWTemplateParser",@"Call createElementsFromNode:");
              NS_DURING
                {
                  gswebTagN=0;
                  tagN=0;
                  elements=[self createElementsFromNode:node];
                  // If we've found error raise exception
                  NSDebugMLog(@"_errorMessages=%@",_errorMessages);
                  if ([[self errorMessages]count]>0)
                    {
                      NSDebugMLog(@"declarationsFilePath=%@",_declarationsFilePath);
                      ExceptionRaise(@"GSWTemplateParser",@"%@\nDefinitionFiles: %@",
                                     [self errorMessagesAsText],
                                     _processedDeclarationsFilePaths);
                    };
                }
              NS_HANDLER
                {
                  LOGError(@"%@ Exception in elements creation!",
                           [self logPrefix]);
                  localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                                          @"%@ - Exception in elements creation",
                                                                          [self logPrefix]);
                  [localException retain];
                  [localException autorelease];
                  [localException raise];
                }
              NS_ENDHANDLER;
            };
        };
    };
  LOGObjectFnStop();
  return elements;
};

//--------------------------------------------------------------------

/*
text [Type:XML_TEXT_NODE] [{}] ####
head [Type:XML_ELEMENT_NODE] [{}] ##(null)##
        title [Type:XML_ELEMENT_NODE] [{}] ##(null)##
                text [Type:XML_TEXT_NODE] [{}] ##MyTitle##
text [Type:XML_TEXT_NODE] [{}] ####
body [Type:XML_ELEMENT_NODE] [{bgcolor = white; }] ##(null)##
        text [Type:XML_TEXT_NODE] [{}] ####
        gsweb [Type:XML_ELEMENT_NODE] [{name = MyObject; }] ##(null)##
                text [Type:XML_TEXT_NODE] [{}] ##AText##
                p [Type:XML_ELEMENT_NODE] [{align = center; }] ##(null)##
                        text [Type:XML_TEXT_NODE] [{}] ##Text2##
                        b [Type:XML_ELEMENT_NODE] [{}] ##(null)##
                                text [Type:XML_TEXT_NODE] [{}] ##Text3##
                text [Type:XML_TEXT_NODE] [{}] ####
        text [Type:XML_TEXT_NODE] [{}] ##TEXTB##
        comment [Type:XML_COMMENT_NODE] [{}] ##MyComment##
        text [Type:XML_TEXT_NODE] [{}] ##TEXTC##
text [Type:XML_TEXT_NODE] [{}] ####
*/
-(NSArray*)createElementsFromNode:(GSXMLNode*)node
{
  GSXMLNode* currentNode=node;
  NSMutableArray* _elements=nil;
  NSAutoreleasePool* arp = nil;
  BOOL includesComment = NO;
  LOGObjectFnStart();
  includesComment=[GSWApplication includeCommentsInResponses];
  _elements=[NSMutableArray array];
  arp=[NSAutoreleasePool new];
  GSWLogMemCF("New NSAutoreleasePool: %p",arp);
  NS_DURING
    {
      while(currentNode)
        {
          GSWElement* elem=nil;
          NSDebugMLLog(@"GSWTemplateParser",@"BEGIN node=%p %@ [Type:%@] [%@] ##%s##\n",
                       currentNode,
                       [currentNode name],
                       [currentNode typeDescription],
                       [currentNode propertiesAsDictionaryWithKeyTransformationSel:NULL],
                       /*				((xmlNodePtr)[currentNode lib])->content,
                                                        [currentNode content],*/
                       [[currentNode content] lossyCString]);

          switch([currentNode type])
            {
            case XML_TEXT_NODE:
              {
                NSDebugMLog0(@"TEXT");

                if ([currentNode content] && ([[currentNode content] length] > 0) ) {

                  elem=[GSWHTMLBareString elementWithString:
                  	                    [NSString stringWithCString:
                                                        [[[currentNode content]
                  	                                   stringByConvertingToHTMLEntities]
                                                          lossyCString]]];//Because XML Parser decode characters
                } else {
                  elem = nil;
                }

                NSDebugMLLog(@"GSWTemplateParser",@"TEXT element=%@",elem);
              };
              break;
            case XML_CDATA_SECTION_NODE:
              {
                NSDebugMLog0(@"CDATA_SECTION");
                NSDebugMLLog(@"GSWTemplateParser",@"CDATA_SECTION content=%s",[[currentNode content] lossyCString]);
                elem=[GSWHTMLBareString elementWithString:[currentNode content]];
                NSDebugMLLog(@"GSWTemplateParser",@"CDATA_SECTION element=%@",elem);
              };
              break;
            case XML_COMMENT_NODE:
              {
                NSDebugMLog0(@"COMMENT");
                if (includesComment)
                  {
                    elem=[GSWHTMLBareString elementWithString:[NSString stringWithFormat:@"<!-- %s -->",[[currentNode content] lossyCString]]];
                    NSDebugMLLog(@"GSWTemplateParser",@"COMMENT element=%@",elem);
                  };
              };
              break;
            default:
              {
                int currentGSWebTagN=0;
                int currentTagN=0;
                NSArray* children=nil;
                NSDictionary* nodeAttributes=nil;
                NSString* nodeName=nil;
                NSString* nodeNameAttribute=nil;
                nodeName=[currentNode name];
                NSDebugMLLog(@"GSWTemplateParser",@"DEFAULT (name=%@ type=%@)",nodeName,[currentNode typeDescription]);
                //if (currentNode->type==XML_ELEMENT_NODE)
                {
                  nodeAttributes=[currentNode propertiesAsDictionaryWithKeyTransformationSel:@selector(lowercaseString)];              
                  nodeNameAttribute=[nodeAttributes objectForKey:@"name"];
                  NSDebugMLLog(@"GSWTemplateParser",@"node=%p nodeAttributes=%@",currentNode,nodeAttributes);
                  NSDebugMLLog(@"GSWTemplateParser",@"node=%p nodeNameAttribute=%@",currentNode,nodeNameAttribute); 
                  tagN++;
                  if ([nodeName caseInsensitiveCompare:GSWTag_Name[GSWNAMES_INDEX]]==NSOrderedSame
                      ||[nodeName caseInsensitiveCompare:GSWTag_Name[WONAMES_INDEX]]==NSOrderedSame)
                    gswebTagN++;
                  currentGSWebTagN=gswebTagN;
                  currentTagN=tagN;
                  if ([currentNode firstChild])
                    {
                      children=[self createElementsFromNode:[currentNode firstChild]];
                      NSDebugMLLog(@"GSWTemplateParser",@"node=%p children=%@",currentNode,children);
                    };
                  if ([nodeName caseInsensitiveCompare:GSWTag_Name[GSWNAMES_INDEX]]==NSOrderedSame
                      ||[nodeName caseInsensitiveCompare:GSWTag_Name[WONAMES_INDEX]]==NSOrderedSame)
                    {
                      GSWDeclaration* declaration=nil;
                      if (!nodeNameAttribute)
                        {
                          // allow null name tags
                          elem=[GSWHTMLStaticGroup elementWithContentElements:children];
                        }
                      else
                        {
                          NSDictionary* _associations=nil;
                          NSString* className=nil;
                          GSWHTMLStaticGroup* aStaticGroup=nil;
                          declaration=[_declarations objectForKey:nodeNameAttribute];
                          NSDebugMLLog(@"GSWTemplateParser",@"declaration:[%@]",
                                       declaration);
                          NSDebugMLLog(@"GSWTemplateParser",@"GSWeb Tag declaration:[%@]",
                                       declaration);
                          if (!declaration)
                            {
                              // We don't raise exception know because it's better for developper to collect and report all errors before :-)
                              [self addErrorMessageFormat:@"No element definition for tag named:%@ [#%d,#%d]",
                                    nodeNameAttribute,
                                    currentGSWebTagN,
                                    currentTagN];
                            }
                          else
                            {
                              _associations=[declaration associations];
                              className=[declaration type];
                              NSDebugMLLog(@"GSWTemplateParser",@"node=%p GSWeb Tag className:[%@]",currentNode,className);
                              if (!className)
                                {
                                  // We don't raise exception know because it's better for developper to collect and report all errors before :-)
                                  [self addErrorMessageFormat:@"No class name in page definition for tag named:%@ declaration=%@ [#%d,#%d]",
                                        nodeNameAttribute,
                                        declaration,
                                        currentGSWebTagN,
                                        currentTagN];
                                };
                            };
                          // No class name mean we'll raise an exception after so don't care about this part...
                          if (className) //
                            {
                              NSDebugMLLog(@"GSWTemplateParser",@"node=%p associations:%@",currentNode,_associations);
                              {
                                NSEnumerator* _nodeAttributesEnum = [nodeAttributes keyEnumerator];
                                id _tagAttrKey=nil;
                                id _tagAttrValue=nil;
                                NSMutableDictionary* _addedAssoc=nil;
                                while ((_tagAttrKey = [_nodeAttributesEnum nextObject]))
                                  {
                                    if (![_tagAttrKey isEqualToString:@"name"] && ![_associations objectForKey:_tagAttrKey])
                                      {
                                        if (!_addedAssoc)
                                          _addedAssoc=(NSMutableDictionary*)[NSMutableDictionary dictionary];
                                        _tagAttrValue=[nodeAttributes objectForKey:_tagAttrKey];
                                        [_addedAssoc setObject:[GSWAssociation associationWithValue:_tagAttrValue]
                                                     forKey:_tagAttrKey];
                                      };
                                  };
                                if (_addedAssoc)
                                  {
                                    _associations=[_associations dictionaryByAddingEntriesFromDictionary:_addedAssoc];
                                  };
                              };
                              NSDebugMLLog(@"GSWTemplateParser",@"node=%p gsweb name=%@ dynamicElementWithName: children=%@",
                                           currentNode,
                                           nodeNameAttribute,
                                           children);
                              NSDebugMLLog(@"GSWTemplateParser",@"node=%p %@ [Type:%@] [%@] ##%s##\n",
                                           currentNode,
                                           [currentNode name],
                                           [currentNode typeDescription],
                                           [currentNode propertiesAsDictionaryWithKeyTransformationSel:NULL],
                                           [[currentNode content] lossyCString]);
                              aStaticGroup=[[[GSWHTMLStaticGroup alloc]initWithContentElements:children]autorelease];
                              elem=[GSWApp dynamicElementWithName:className
                                           associations:_associations
                                           template:aStaticGroup
                                           languages:_languages];
                              NSDebugMLLog(@"GSWTemplateParser",@"node=%p element=%@ StaticGroup %p=%@",currentNode,elem,aStaticGroup,aStaticGroup);
                              if (elem)
                                [elem setDeclarationName:[declaration name]];
                              else
                                {
                                  // We don't raise exception know because it's better for developper to collect and report all errors before :-)
                                  [self addErrorMessageFormat:@"Creation failed for element named:%@ className:%@",
                                        [declaration name],
                                        className];
                                };
                            };
                        };
                    }
                  else
                    {
                      //It's a hack to remove html & body elements where there's not in the template (HTML parser add them when there are missing)
                      if ((!_isHTMLTag
                           && [nodeName caseInsensitiveCompare:@"html"]==NSOrderedSame
                           && [nodeAttributes count]==0)
                          || (!_isBodyTag
                              && [nodeName caseInsensitiveCompare:@"body"]==NSOrderedSame
                              && [nodeAttributes count]==0))
                        {
                          NSDebugMLLog(@"GSWTemplateParser",@"node=%p StaticElement: children=%@",currentNode,children);
                          elem=[[[GSWHTMLStaticElement alloc]initWithName:nil
                                                             attributeDictionary:nil
                                                             contentElements:children]autorelease];
                          NSDebugMLLog(@"GSWTemplateParser",@"node=%p element=%@",currentNode,elem);
                        }
                      else
                        {
                          NSDictionary* _associations=nil;
                          NSEnumerator* _nodeAttributesEnum = [nodeAttributes keyEnumerator];
                          id _tagAttrKey=nil;
                          id _tagAttrValue=nil;
                          NSMutableDictionary* _addedAssoc=nil;
                          NSDebugMLLog(@"GSWTemplateParser",@"node=%p Create nodeName=%@ nodeAttributes=%@",
                                       currentNode,nodeName,nodeAttributes);
                          while ((_tagAttrKey = [_nodeAttributesEnum nextObject]))
                            {
                              //Don't remove name for not gsweb tag
                              //if (![_tagAttrKey isEqualToString:@"name"] && ![_associations objectForKey:_tagAttrKey])
                              if (![_associations objectForKey:_tagAttrKey])
                                {
                                  if (!_addedAssoc)
                                    _addedAssoc=(NSMutableDictionary*)[NSMutableDictionary dictionary];
                                  _tagAttrValue=[nodeAttributes objectForKey:_tagAttrKey];
                                  [_addedAssoc setObject:[GSWAssociation associationWithValue:_tagAttrValue]
                                               forKey:_tagAttrKey];
                                };
                            };
                          if (_addedAssoc)
                            {
                              _associations=[NSDictionary dictionaryWithDictionary:_addedAssoc];
                            };
                          NSDebugMLLog(@"GSWTemplateParser",@"node=%p Create nodeName=%@ nodeAttributes=%@ _associations=%@",
                                       currentNode,nodeName,nodeAttributes,_associations);
                          //To know if it's an autoclose tag
                          if (!children && [self isKindOfClass:[GSWTemplateParserXMLHTML class]])
                            {
                              const htmlElemDesc* elemDscr=htmlTagLookup([nodeName lossyCString]);
                              if (elemDscr
                                  && elemDscr->endTag!=2 //Forbidden End Tag
                                  && elemDscr->endTag!=1) //End can be omitted
                                {
                                  children=[NSArray array];
                                };
                            };
                          NSDebugMLLog(@"GSWTemplateParser",@"node=%p StaticElement: children=%@",currentNode,children);
                          elem=[[[GSWHTMLStaticElement alloc]initWithName:nodeName
                                                             attributeDictionary:_associations
                                                             contentElements:children]autorelease];
                          NSDebugMLLog(@"GSWTemplateParser",@"node=%p element=%@",currentNode,elem);
                        };
                    };
                };
              };
              break;
            };
          if (elem)
            [_elements addObject:elem];
          NSDebugMLLog(@"GSWTemplateParser",@"END node=%p %@ [Type:%@] [%@] ##%s##\n",
                       currentNode,
                       [currentNode name],
                       [currentNode typeDescription],
                       [currentNode propertiesAsDictionaryWithKeyTransformationSel:NULL],
                       [[currentNode content] lossyCString]);
          currentNode=[currentNode next];
        };
    }
  NS_HANDLER
    {
      LOGError(@"%@ createElementsFromNode: Exception",
               [self logPrefix]);
      localException=ExceptionByAddingUserInfoObjectFrameInfo(localException,
                                                              @"%@ In [GSWTemplateParserXML createElementsFromNode:]...",
                                                              [self logPrefix]);
      [localException retain];
      GSWLogMemCF("Destroy NSAutoreleasePool: %p",arp);
      DESTROY(arp);
      [localException autorelease];
      [localException raise];
    }
  NS_ENDHANDLER;
  GSWLogMemCF("Destroy NSAutoreleasePool: %p",arp);
  DESTROY(arp);
  LOGObjectFnStop();
  NSDebugMLLog(@"GSWTemplateParser",@"_elements=%@",_elements);
  return _elements;
};

@end


//====================================================================
// used only for XML/XMLHTML differences
@implementation GSWTemplateParserXMLHTML

/** call htmlHandleOmittedElem(0) if YES, htmlHandleOmittedElem(1) if NO; **/
-(void)setNoOmittedTags:(BOOL)yn
{
  htmlHandleOmittedElem(yn ? 0 : 1);
};

@end


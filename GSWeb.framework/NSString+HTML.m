/** NSString+HTML.m - <title>GSWeb: NSString / HTML</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#include <limits.h>

static NSArray* normalChars=nil;
static NSArray* htmlChars=nil;


/*
  <!ENTITY amp CDATA "&#38;"     -- ampersand          -->
  <!ENTITY gt CDATA "&#62;"      -- greater than       -->
  <!ENTITY lt CDATA "&#60;"      -- less than          -->
  <!ENTITY quot CDATA "&#34;"    -- double quote       -->
  <!ENTITY nbsp   CDATA "&#160;" -- no-break space -->
  <!ENTITY iexcl  CDATA "&#161;" -- inverted exclamation mark -->
  <!ENTITY cent   CDATA "&#162;" -- cent sign -->
  <!ENTITY pound  CDATA "&#163;" -- pound sterling sign -->
  <!ENTITY curren CDATA "&#164;" -- general currency sign -->
  <!ENTITY yen    CDATA "&#165;" -- yen sign -->
  <!ENTITY brvbar CDATA "&#166;" -- broken (vertical) bar -->
  <!ENTITY sect   CDATA "&#167;" -- section sign -->
  <!ENTITY uml    CDATA "&#168;" -- umlaut (dieresis) -->
  <!ENTITY copy   CDATA "&#169;" -- copyright sign -->
  <!ENTITY ordf   CDATA "&#170;" -- ordinal indicator, feminine -->
  <!ENTITY laquo  CDATA "&#171;" -- angle quotation mark, left -->
  <!ENTITY not    CDATA "&#172;" -- not sign -->
  <!ENTITY shy    CDATA "&#173;" -- soft hyphen -->
  <!ENTITY reg    CDATA "&#174;" -- registered sign -->
  <!ENTITY macr   CDATA "&#175;" -- macron -->
  <!ENTITY deg    CDATA "&#176;" -- degree sign -->
  <!ENTITY plusmn CDATA "&#177;" -- plus-or-minus sign -->
  <!ENTITY sup2   CDATA "&#178;" -- superscript two -->
  <!ENTITY sup3   CDATA "&#179;" -- superscript three -->
  <!ENTITY acute  CDATA "&#180;" -- acute accent -->
  <!ENTITY micro  CDATA "&#181;" -- micro sign -->
  <!ENTITY para   CDATA "&#182;" -- pilcrow (paragraph sign) -->
  <!ENTITY middot CDATA "&#183;" -- middle dot -->
  <!ENTITY cedil  CDATA "&#184;" -- cedilla -->
  <!ENTITY sup1   CDATA "&#185;" -- superscript one -->
  <!ENTITY ordm   CDATA "&#186;" -- ordinal indicator, masculine -->
  <!ENTITY raquo  CDATA "&#187;" -- angle quotation mark, right -->
  <!ENTITY frac14 CDATA "&#188;" -- fraction one-quarter -->
  <!ENTITY frac12 CDATA "&#189;" -- fraction one-half -->
  <!ENTITY frac34 CDATA "&#190;" -- fraction three-quarters -->
  <!ENTITY iquest CDATA "&#191;" -- inverted question mark -->
  <!ENTITY Agrave CDATA "&#192;" -- capital A, grave accent -->
  <!ENTITY Aacute CDATA "&#193;" -- capital A, acute accent -->
  <!ENTITY Acirc  CDATA "&#194;" -- capital A, circumflex accent -->
  <!ENTITY Atilde CDATA "&#195;" -- capital A, tilde -->
  <!ENTITY Auml   CDATA "&#196;" -- capital A, dieresis or umlaut -->
  <!ENTITY Aring  CDATA "&#197;" -- capital A, ring -->
  <!ENTITY AElig  CDATA "&#198;" -- capital AE diphthong (ligature) -->
  <!ENTITY Ccedil CDATA "&#199;" -- capital C, cedilla -->
  <!ENTITY Egrave CDATA "&#200;" -- capital E, grave accent -->
  <!ENTITY Eacute CDATA "&#201;" -- capital E, acute accent -->
  <!ENTITY Ecirc  CDATA "&#202;" -- capital E, circumflex accent -->
  <!ENTITY Euml   CDATA "&#203;" -- capital E, dieresis or umlaut -->
  <!ENTITY Igrave CDATA "&#204;" -- capital I, grave accent -->
  <!ENTITY Iacute CDATA "&#205;" -- capital I, acute accent -->
  <!ENTITY Icirc  CDATA "&#206;" -- capital I, circumflex accent -->
  <!ENTITY Iuml   CDATA "&#207;" -- capital I, dieresis or umlaut -->
  <!ENTITY ETH    CDATA "&#208;" -- capital Eth, Icelandic -->
  <!ENTITY Ntilde CDATA "&#209;" -- capital N, tilde -->
  <!ENTITY Ograve CDATA "&#210;" -- capital O, grave accent -->
  <!ENTITY Oacute CDATA "&#211;" -- capital O, acute accent -->
  <!ENTITY Ocirc  CDATA "&#212;" -- capital O, circumflex accent -->
  <!ENTITY Otilde CDATA "&#213;" -- capital O, tilde -->
  <!ENTITY Ouml   CDATA "&#214;" -- capital O, dieresis or umlaut -->
  <!ENTITY times  CDATA "&#215;" -- multiply sign -->
  <!ENTITY Oslash CDATA "&#216;" -- capital O, slash -->
  <!ENTITY Ugrave CDATA "&#217;" -- capital U, grave accent -->
  <!ENTITY Uacute CDATA "&#218;" -- capital U, acute accent -->
  <!ENTITY Ucirc  CDATA "&#219;" -- capital U, circumflex accent -->
  <!ENTITY Uuml   CDATA "&#220;" -- capital U, dieresis or umlaut -->
  <!ENTITY Yacute CDATA "&#221;" -- capital Y, acute accent -->
  <!ENTITY THORN  CDATA "&#222;" -- capital Thorn, Icelandic -->
  <!ENTITY szlig  CDATA "&#223;" -- small sharp s, German (sz ligature) -->
  <!ENTITY agrave CDATA "&#224;" -- small a, grave accent -->
  <!ENTITY aacute CDATA "&#225;" -- small a, acute accent -->
  <!ENTITY acirc  CDATA "&#226;" -- small a, circumflex accent -->
  <!ENTITY atilde CDATA "&#227;" -- small a, tilde -->
  <!ENTITY auml   CDATA "&#228;" -- small a, dieresis or umlaut -->
  <!ENTITY aring  CDATA "&#229;" -- small a, ring -->
  <!ENTITY aelig  CDATA "&#230;" -- small ae diphthong (ligature) -->
  <!ENTITY ccedil CDATA "&#231;" -- small c, cedilla -->
  <!ENTITY egrave CDATA "&#232;" -- small e, grave accent -->
  <!ENTITY eacute CDATA "&#233;" -- small e, acute accent -->
  <!ENTITY ecirc  CDATA "&#234;" -- small e, circumflex accent -->
  <!ENTITY euml   CDATA "&#235;" -- small e, dieresis or umlaut -->
  <!ENTITY igrave CDATA "&#236;" -- small i, grave accent -->
  <!ENTITY iacute CDATA "&#237;" -- small i, acute accent -->
  <!ENTITY icirc  CDATA "&#238;" -- small i, circumflex accent -->
  <!ENTITY iuml   CDATA "&#239;" -- small i, dieresis or umlaut -->
  <!ENTITY eth    CDATA "&#240;" -- small eth, Icelandic -->
  <!ENTITY ntilde CDATA "&#241;" -- small n, tilde -->
  <!ENTITY ograve CDATA "&#242;" -- small o, grave accent -->
  <!ENTITY oacute CDATA "&#243;" -- small o, acute accent -->
  <!ENTITY ocirc  CDATA "&#244;" -- small o, circumflex accent -->
  <!ENTITY otilde CDATA "&#245;" -- small o, tilde -->
  <!ENTITY ouml   CDATA "&#246;" -- small o, dieresis or umlaut -->
  <!ENTITY divide CDATA "&#247;" -- divide sign -->
  <!ENTITY oslash CDATA "&#248;" -- small o, slash -->
  <!ENTITY ugrave CDATA "&#249;" -- small u, grave accent -->
  <!ENTITY uacute CDATA "&#250;" -- small u, acute accent -->
  <!ENTITY ucirc  CDATA "&#251;" -- small u, circumflex accent -->
  <!ENTITY uuml   CDATA "&#252;" -- small u, dieresis or umlaut -->
  <!ENTITY yacute CDATA "&#253;" -- small y, acute accent -->
  <!ENTITY thorn  CDATA "&#254;" -- small thorn, Icelandic -->
  <!ENTITY yuml   CDATA "&#255;" -- small y, dieresis or umlaut -->
*/

#define NORMAL_CHARS @"(\"&\", \
                        \">\", \
                        \"<\", \
                        \"\\\"\", \
                        \"\\U00A3\", \
                        \"|\", \
                        \"\\U00B0\", \
                        \"\\U00E9\", \
                        \"\\U00E7\", \
                        \"\\U00E0\", \
                        \"\\U00E2\", \
                        \"\\U00E3\", \
                        \"\\U00E8\", \
                        \"\\U00EA\", \
                        \"\\U00EC\", \
                        \"\\U00EE\", \
                        \"\\U00F1\", \
                        \"\\U00F4\", \
                        \"\\U00F5\", \
                        \"\\U00F9\", \
                        \"\\U00FB\")"

static void
initHtmlChars()
{
  if (!normalChars)
    {
      normalChars = [[NORMAL_CHARS  propertyList] retain];
    };
  if (!htmlChars)
    {
      htmlChars=[[NSArray arrayWithObjects:
                            @"&amp;",
                          @"&gt;",	
                          @"&lt;",	
                          @"&quot;",
                          @"&pound;",
                          @"&brvbar;",	
                          @"&deg;",
                          @"&eacute;",							
                          @"&ccedil;",
                          @"&agrave;",
                          @"&acirc;",
                          @"&atilde;",
                          @"&egrave;",
                          @"&ecirc;",	
                          @"&igrave;",
                          @"&icirc;",							
                          @"&ntilde;",
                          @"&ocirc;",
                          @"&otilde;",
                          @"&ugrave;",
                          @"&ucirc;",
                          nil
                  ] retain];
    };
};

//====================================================================
@implementation NSString (HTMLString)

//--------------------------------------------------------------------
-(NSString*)htmlPlus2Space
{
  return [self stringByReplacingString:@"+"
               withString:@" "];
};

//--------------------------------------------------------------------
// void decodeURL(String &str)
//   Convert the given URL string to a normal string.  This means that
//   all escaped characters are converted to their normal values.  The
//   escape character is '%' and is followed by 2 hex digits
//   representing the octet.
//
-(NSString*)decodeURL
{
  //TODO speed
  unichar* unichars=NULL;
  unichar uniChar=0;
  NSString* voidString=nil;
  NSString* temp=nil;
  const char* p=NULL;
  int uniCharsIndex=0;
  NSDebugMLLog(@"low",@"self=%@",self);
  voidString=[self htmlPlus2Space];  
  NSDebugMLLog(@"low",@"voidString=%@",voidString);
  unichars=GSAutoreleasedBuffer(sizeof(unichar)*([voidString length]+1));
  NSDebugMLLog(@"low",@"[voidString cString]=%s",[voidString cString]);
  for (p=[voidString cString];p && *p;p++)
    {
      if (*p == '%')
        {
          //
          // 2 hex digits follow...
          //
          int i=0;
          uniChar=0;
          for (i=0;p[1] && i<2;i++)
            {
              p++;
              NSDebugMLLog(@"low",@"*p=%c %u",(char)*p,(unsigned int)*p);
              uniChar <<= 4;
              NSDebugMLLog(@"low",@"uniChar=%x",(unsigned int)uniChar);
              if (isdigit(*p))
                uniChar+=*p-'0';
              else
                uniChar+=toupper(*p)-'A'+10;
              NSDebugMLLog(@"low",@"uniChar=%x",(unsigned int)uniChar);
            };
        }
      else
        uniChar=(unsigned char)*p;
      unichars[uniCharsIndex]=uniChar;
      uniCharsIndex++;
    };
  temp=[NSString stringWithCharacters:unichars
                 length:uniCharsIndex];
  NSDebugMLLog(@"low",@"temp=%@",temp);
  NSDebugMLLog(@"low",@"temp data=%@",
	       [temp dataUsingEncoding: [GSWMessage defaultEncoding]]);
  return temp;
};


//--------------------------------------------------------------------
// void encodeURL(String &str, char *valid)
//   Convert a normal string to a URL 'safe' string.  This means that
//   all characters not explicitly mentioned in the URL BNF will be
//   escaped.  The escape character is '%' and is followed by 2 hex
//   digits representing the octet.
//
-(NSString*)encodeURL
{
  return [self encodeURLWithValid:nil];
};

//--------------------------------------------------------------------
-(NSString*)encodeURLWithValid:(NSString*)validString
{
  NSMutableString* temp=[NSMutableString stringWithCapacity:[self length]];
  const char* p=NULL;
  const char* valid=[validString cString];
  static char *digits = "0123456789ABCDEF";
  for (p =[self cString]; p && *p; p++)
    {
      if (isdigit(*p) || isalpha(*p) || (valid && strchr(valid, *p)))
        [temp appendFormat:@"%c",*p];
      else
        [temp appendFormat:@"%%%c%c",digits[(*p >> 4) & 0x0f],digits[*p & 0x0f]];
    };
  return [NSString stringWithString:temp];
}

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryQueryString
{
  return [self dictionaryWithSep1:@"&"
               withSep2:@"="
               withOptionUnescape:YES
               forceArray:YES];
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryWithSep1:(NSString*)sep1
                          withSep2:(NSString*)sep2
                withOptionUnescape:(BOOL)unescape
{
  return [self dictionaryWithSep1:sep1
               withSep2:sep2
               withOptionUnescape:unescape
               forceArray:NO];
};
//--------------------------------------------------------------------
-(NSDictionary*)dictionaryWithSep1:(NSString*)sep1
                          withSep2:(NSString*)sep2
                withOptionUnescape:(BOOL)unescape
                        forceArray:(BOOL)forceArray// Put value in array even if there's only one value
{
  NSMutableDictionary*  pDico=nil;
  if	([self length]>0)
    {
      NSArray* listItems = [self componentsSeparatedByString:sep1];
      int iCount=0;
      pDico=(NSMutableDictionary*)[NSMutableDictionary dictionary];
      for(iCount=0;iCount<[listItems count];iCount++)
        {
          if ([[listItems objectAtIndex:iCount] length]>0)
            {
              NSArray* listParam = [[listItems objectAtIndex:iCount] componentsSeparatedByString:sep2];
              id key=nil;
              id value=nil;
              if ([listParam count]==1)
                {
                  key=[listParam objectAtIndex:0];
                  if (unescape)
                    key=[key decodeURL];
                }
              else if ([listParam count]==2)
                {
                  key=[listParam objectAtIndex:0];
                  value=[listParam objectAtIndex:1];
                  if (unescape)
                    {
                      key=[key decodeURL];
                      value=[value decodeURL];
                    };
                };
              if (key)
                {
                  id newValue=nil;
                  id prevValue=[pDico objectForKey:key];
                  if (!value)
                    value=[NSString string];
                  if (prevValue)
                    {
                      if (!forceArray || [prevValue isKindOfClass:[NSArray class]])
                        newValue=[prevValue arrayByAddingObject:value];
                      else
                        newValue=[NSArray arrayWithObjects:prevValue,value,nil];
                    }
                  else
                    {
                      if (forceArray)
                        newValue=[NSArray arrayWithObject:value];
                      else
                        newValue=value;
                    };
                  [pDico setObject:newValue
                         forKey: key];
                };
            };
        };
      pDico=[NSDictionary dictionaryWithDictionary:pDico];
    };
  return pDico;
};

//--------------------------------------------------------------------
-(BOOL)ismapCoordx:(int*)x
                 y:(int*)y
{
  BOOL ok=NO;
  NSScanner* scanner=[NSScanner scannerWithString:self];
  if ([scanner scanInt:x])
    {
      if (x)
        {
          NSDebugMLLog(@"low",@"x=%d",*x);
        };
      if ([scanner scanString:@"," 
                   intoString:NULL])
        {
          if ([scanner scanInt:y])
            {
              if (y)
                {
                  NSDebugMLLog(@"low",@"y=%d",*y);
                };
              NSDebugMLLog(@"low",@"[scanner isAtEnd]=%d",(int)[scanner isAtEnd]);
              if ([scanner isAtEnd])
                {
                  ok=YES;
                };
            };
        };
    };
  if (!ok)
    {
      if (x)
        *x=INT_MAX;
      if (y)
        *y=INT_MAX;
    };
  return ok;
};

//--------------------------------------------------------------------
-(NSString*)stringByEscapingHTMLString
{
  //TODO speed
  NSString* str=nil;
  if ([self length]>0)
    {
      NSMutableString* tmp=[self mutableCopy];
      [tmp replaceString:@"&" withString:@"&amp;"];
      [tmp replaceString:@"\"" withString:@"&quot;"];
      [tmp replaceString:@"<" withString:@"&lt;"];
      [tmp replaceString:@">" withString:@"&gt;"];
      str = AUTORELEASE([tmp copy]);
      RELEASE(tmp);
    };
  return str;
};

//--------------------------------------------------------------------
-(NSString*)stringByEscapingHTMLAttributeValue
{
  //TODO speed
  NSString* str=nil;
  if ([self length]>0)
    {
      NSMutableString* tmp=[self mutableCopy];
      [tmp replaceString:@"&" withString:@"&amp;"];
      [tmp replaceString:@"\"" withString:@"&quot;"];
      [tmp replaceString:@"<" withString:@"&lt;"];
      [tmp replaceString:@">" withString:@"&gt;"];
      [tmp replaceString:@"\t" withString:@"&#9;"];
      [tmp replaceString:@"\n" withString:@"&#10;"];
      [tmp replaceString:@"\r" withString:@"&#13;"];
      str = AUTORELEASE([tmp copy]);
      RELEASE(tmp);
    };
  return str;
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingToHTMLEntities
{
  //TODO speed
  NSString* str=nil;
  if ([self length]>0)
    {
      int i=0;
      NSMutableString* tmp=[self mutableCopy];
      if (!normalChars)
        initHtmlChars();
      for(i=0;i<[normalChars count];i++)
        {
          [tmp replaceString:[normalChars objectAtIndex:i]
               withString:[htmlChars objectAtIndex:i]];
        };
      str = AUTORELEASE([tmp copy]);
      RELEASE(tmp);
    };
  return str;
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingFromHTMLEntities
{
  NSString* str=nil;
  if ([self length]>0)
    {
      int i=0;
      NSMutableString* tmp=[self mutableCopy];
      if (!normalChars)
        initHtmlChars();
      for(i=0;i<[normalChars count];i++)
        {
          [tmp replaceString:[htmlChars objectAtIndex:i]
               withString:[normalChars objectAtIndex:i]];
        };
      str = AUTORELEASE([tmp copy]);
      RELEASE(tmp);
    };
  return str;
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingToHTML
{
  NSString* str=nil;
  if ([self length]>0)
    {
      //TODO speed
      //From -stringByConvertingToHTMLEntities
      int i=0;
      NSMutableString* tmp=[self mutableCopy];
      if (!normalChars)
        initHtmlChars();
      for(i=0;i<[normalChars count];i++)
        {
          [tmp replaceString:[normalChars objectAtIndex:i]
               withString:[htmlChars objectAtIndex:i]];
        };
      //End From -stringByConvertingToHTMLEntities

      [tmp replaceString:@"\r\n" withString:@"<BR>"];
      [tmp replaceString:@"\r" withString:@"<BR>"];
      [tmp replaceString:@"\n" withString:@"<BR>"];
      str = AUTORELEASE([tmp copy]);
      RELEASE(tmp);
    };
  return str;
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingFromHTML
{
  NSString* str=nil;
  if ([self length]>0)
    {
      //TODO speed
      //From -stringByConvertingFromHTMLEntities
      int i=0;
      NSMutableString* tmp=[self mutableCopy];
      if (!normalChars)
        initHtmlChars();
      for(i=0;i<[normalChars count];i++)
        {
          [tmp replaceString:[htmlChars objectAtIndex:i]
               withString:[normalChars objectAtIndex:i]];
        };
      //End From -stringByConvertingFromHTMLEntities

      [tmp replaceString:@"<BR>" withString:@"\n"];
      str = AUTORELEASE([tmp copy]);
      RELEASE(tmp);
    };
  return str;
};

@end


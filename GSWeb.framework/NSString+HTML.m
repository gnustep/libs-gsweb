/** NSString+HTML.m - <title>GSWeb: NSString / HTML</title>

   Copyright (C) 1999-2005 Free Software Foundation, Inc.
  
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

#define HTML_CHARS @"(    \"&amp;\",	\
                          \"&gt;\",	\
                          \"&lt;\",	\
                          \"&quot;\",	\
                          \"&pound;\",	\
                          \"&brvbar;\",	\
                          \"&deg;\",	\
                          \"&eacute;\",	\
                          \"&ccedil;\",	\
                          \"&agrave;\",	\
                          \"&acirc;\",	\
                          \"&atilde;\",	\
                          \"&egrave;\",	\
                          \"&ecirc;\",	\
                          \"&igrave;\",	\
                          \"&icirc;\",	\
                          \"&ntilde;\",	\
                          \"&ocirc;\",	\
                          \"&otilde;\",	\
                          \"&ugrave;\",	\
                          \"&ucirc;\")"

#define ESCAPING_HTML_ATTRIBUTE_VALUE_NORMAL_CHARS @"( 	\
      \"&\",	\
      \"\\\"\",	\
      \"<\",	\
      \">\",	\
      \"\t\",	\
      \"\n\",	\
      \"\r\" )"

#define ESCAPING_HTML_ATTRIBUTE_VALUE_HTML_CHARS @"( 	\
      \"&amp;\",  \
      \"&quot;\", \
      \"&lt;\",	\
      \"&gt;\",	\
      \"&#9;\",	\
      \"&#10;\",\
      \"&#13;\" )"	

#define ESCAPING_HTML_STRING_NORMAL_CHARS @"( 	\
      \"&\",	\
      \"\\\"\",	\
      \"<\",	\
      \">\" )"

#define ESCAPING_HTML_STRING_HTML_CHARS @"( 	\
      \"&amp;\",  \
      \"&quot;\", \
      \"&lt;\",	\
      \"&gt;\" )"	

GSWHTMLConvertingStruct htmlConvertStruct;
GSWHTMLConvertingStruct htmlConvertAttributeValueStruct;
GSWHTMLConvertingStruct htmlConvertHTMLString;

static unichar unicodeBR[5];
static int unicodeBRLen=4;
#define htmlCharsMaxLength 9
#define htmlCharsAtIndex(convStructPtr,i)	(((convStructPtr)->htmlChars)+((i)*(htmlCharsMaxLength+1)))


static Class mutableStringClass = Nil;
static Class stringClass=Nil;
static SEL stringWithCharactersSEL=NULL;
static SEL stringWithStringSEL=NULL;
static IMP stringClass_stringWithCharactersIMP=NULL;
static IMP stringClass_stringWithStringIMP=NULL;

static void initNormalHTMLChars(GSWHTMLConvertingStruct* htmlConvertStruct,
                                NSString* normalCharsPropertyListString,
                                NSString* htmlCharsPropertyListString)
{
  NSArray* normalCharsStringArray=[normalCharsPropertyListString propertyList];
  NSArray* htmlCharsStringArray=[htmlCharsPropertyListString propertyList];      
  int i=0;
  htmlConvertStruct->charsCount=[normalCharsStringArray count];
  NSCAssert([htmlCharsStringArray count]==htmlConvertStruct->charsCount,
                @"html and normal characters array have not the same count of elements");
  htmlConvertStruct->normalChars=NSZoneMalloc(NSDefaultMallocZone(),sizeof(unichar)*(htmlConvertStruct->charsCount));
  htmlConvertStruct->htmlChars=NSZoneMalloc(NSDefaultMallocZone(),sizeof(unichar)*(htmlCharsMaxLength+1)*(htmlConvertStruct->charsCount));
  htmlConvertStruct->htmlCharsLen=NSZoneMalloc(NSDefaultMallocZone(),sizeof(int)*(htmlConvertStruct->charsCount));
  
  for(i=0;i<(htmlConvertStruct->charsCount);i++)
    {
      NSString* htmlString=[htmlCharsStringArray objectAtIndex:i];
      htmlConvertStruct->htmlCharsLen[i]=[htmlString length];
      NSCAssert1(htmlConvertStruct->htmlCharsLen[i]<=htmlCharsMaxLength,
                 @"html character at inde i is too long",i);
      
      htmlConvertStruct->normalChars[i]=[[normalCharsStringArray objectAtIndex:i]characterAtIndex:0];
      [htmlString getCharacters:htmlCharsAtIndex(htmlConvertStruct,i)];
    };
}

static void testStringByConvertingHTML();

void NSStringHTML_Initialize()
{
  static BOOL initialized=NO;
  if (!initialized)
    {
      initialized=YES;

      initNormalHTMLChars(&htmlConvertStruct,
                          NORMAL_CHARS,
                          HTML_CHARS);

      initNormalHTMLChars(&htmlConvertAttributeValueStruct,
                          ESCAPING_HTML_ATTRIBUTE_VALUE_NORMAL_CHARS,
                          ESCAPING_HTML_ATTRIBUTE_VALUE_HTML_CHARS);

      initNormalHTMLChars(&htmlConvertHTMLString,
                          ESCAPING_HTML_STRING_NORMAL_CHARS,
                          ESCAPING_HTML_STRING_HTML_CHARS);

      [@"<BR>" getCharacters:unicodeBR];

      ASSIGN(mutableStringClass,[NSMutableString class]);
      ASSIGN(stringClass,[NSString class]);

      stringWithCharactersSEL=@selector(stringWithCharacters:length:);
      stringWithStringSEL=@selector(stringWithString:);
      stringClass_stringWithCharactersIMP=[stringClass methodForSelector:stringWithCharactersSEL];
      stringClass_stringWithStringIMP=[stringClass methodForSelector:stringWithStringSEL];

      //testStringByConvertingHTML();
    };
};

//====================================================================
#define GSWMemMove(dst,src,size);		\
{						\
int __size=(size);				\
unsigned char* __src=((char*)(src));		\
unsigned char* __dst=((char*)(dst));		\
unsigned char* __pDst=__dst+__size-1;		\
unsigned char* __pSrc=__src+__size-1;		\
if (__dst>__src)				\
   while(__pDst>=__dst) { *__pDst--=*__pSrc--; }	\
else							\
   while(__pDst>=__dst) { *__dst++=*__src++; };		\
};

#define HTML_TEST_STRINGS @"(\"\", \
                        \"ABCDEF\", \
                        \"&12\\U00E9\", \
                        \"&\n1\", \
                        \"&\r\n2\\U00E8\", \
                        \"<ee>\")"

void testStringByConvertingHTML()
{
  NSArray* testStrings=[HTML_TEST_STRINGS propertyList];
  int i=0;
  for(i=0;i<[testStrings count];i++)
    {
      NSString* string=[testStrings objectAtIndex:i];
      NSString* result=[string stringByConvertingToHTML];
      NSString* reverse=[result stringByConvertingFromHTML];
      NSDebugFLog(@"RESULT: %d: '%@' => '%@'",i,string,result);
      NSDebugFLog(@"Reverse RESULT: %d: '%@' => '%@'",i,result,reverse);
    };
};

void allocOrReallocUnicharString(unichar** ptrPtr,int* capacityPtr,int length,int newCapacity)
{
  //Really need ?  
  if (newCapacity>*capacityPtr)
    {
      int allocSize=newCapacity*sizeof(unichar);
      unichar* newPtr=GSAutoreleasedBuffer(allocSize);

      NSCAssert1(newPtr,@"Can't alloc %d allocSize bytes",
                 allocSize);

      if (length>0)
        {
          // Copy previous parts
          GSWMemMove(newPtr,*ptrPtr,length*sizeof(unichar));
        };

      *capacityPtr=newCapacity;
      *ptrPtr=newPtr;
    };

};

//--------------------------------------------------------------------
NSString* baseStringByConvertingToHTML(NSString* string,GSWHTMLConvertingStruct* convStructPtr,BOOL includeCRLF)
{
  NSString* str=nil;
  int length=[string length];
  NSCAssert(convStructPtr->charsCount>0,@"normalChars not initialized");
  if (length>0)
    {
      BOOL changed=NO;
      int srcLen=0;
      int dstLen=0;
      unichar* dstChars=NULL;
      int capacity=0;
      unichar* pString=NULL;
      int i=0;
      int j=0;
      int allocMargin=max(128,length/2);
      allocOrReallocUnicharString(&pString,&capacity,0,length+1+allocMargin);
      [string getCharacters:pString];
      //NSDebugFLog(@"string=%@",string);
      while(i<length)
        {
          srcLen=0;
          unichar c=pString[i];
          //NSDebugFLog(@"i=%d: c=%c",i,(char)c);
          if (includeCRLF && c=='\r')
            {
              if (i<(length-1)
                  && pString[i+1]=='\n')
                {
                  srcLen=2;
                  dstLen=unicodeBRLen;
                  dstChars=unicodeBR;
                }
              else
                {
                  srcLen=1;
                  dstLen=unicodeBRLen;
                  dstChars=unicodeBR;
                };
            }
          else if (c=='\n' && includeCRLF)
            {
              srcLen=1;
              dstLen=4;
              dstChars=unicodeBR;
            }
          else
            {
              for(j=0;j<convStructPtr->charsCount;j++)
                {
                  if (c==convStructPtr->normalChars[j])
                    {
                      srcLen=1;
                      dstLen=convStructPtr->htmlCharsLen[j];
                      dstChars=htmlCharsAtIndex(convStructPtr,j);
                      break;
                    };
                };
            };
          if (srcLen>0)
            {
              /*NSDebugFLog(@"i=%d j=%d: srcLen=%d dstLen=%d by '%@'",i,j,srcLen,dstLen,[NSString stringWithCharacters:dstChars
                length:dstLen]);*/
              changed=YES;
              /*NSDebugFLog(@"-1==> %@",[NSString stringWithCharacters:pString
                                                length:length]);*/
              if (length+1+dstLen-srcLen>capacity)
                allocOrReallocUnicharString(&pString,&capacity,length,capacity+allocMargin);
              /*NSDebugFLog(@"0==> %@",[NSString stringWithCharacters:pString
                                               length:length]);
              NSDebugFLog(@"Copy %d characters from pos %d to pos %d",(length-i-srcLen),i+srcLen,i+dstLen);*/
              GSWMemMove(pString+i+dstLen,pString+i+srcLen,sizeof(unichar)*(length-i-srcLen));
              /*NSDebugFLog(@"1==> %@",[NSString stringWithCharacters:pString
                                               length:length+dstLen-srcLen]);
              NSDebugFLog(@"Copy %d characters to pos %d",dstLen,i);*/
              GSWMemMove(pString+i,dstChars,sizeof(unichar)*dstLen);
              i+=dstLen;
              length+=dstLen-srcLen;
              /*NSDebugFLog(@"2==> i=%d length=%d %@",i,length,[NSString stringWithCharacters:pString
                length:length]);*/
              
            }
          else
            i++;
        };
      if (changed)
        str=(*stringClass_stringWithCharactersIMP)(stringClass,stringWithCharactersSEL,pString,length);
      else if ([string isKindOfClass:mutableStringClass])
        str=(*stringClass_stringWithStringIMP)(stringClass,stringWithStringSEL,string);
      else
        str=string;
    }
  else if ([string isKindOfClass:mutableStringClass])
    str=@"";
  else
    str=AUTORELEASE(RETAIN(string));
  return str;
};

inline BOOL areUnicharEquals(unichar* p1,unichar* p2,int len)
{
  switch(len)
    {
    case 0:
      NSCAssert(NO,@"Too short comparaison");
      return NO;
    case 1:
      return *p1==*p2;
    case 2:
      return (*p1==*p2
              && *(p1+1)==*(p2+1));
    case 3:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2));
    case 4:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2)
              && *(p1+3)==*(p2+3));
    case 5:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2)
              && *(p1+3)==*(p2+3)
              && *(p1+4)==*(p2+4));
    case 6:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2)
              && *(p1+3)==*(p2+3)
              && *(p1+4)==*(p2+4)
              && *(p1+5)==*(p2+5));
    case 7:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2)
              && *(p1+3)==*(p2+3)
              && *(p1+4)==*(p2+4)
              && *(p1+5)==*(p2+5)
              && *(p1+6)==*(p2+6));
    case 8:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2)
              && *(p1+3)==*(p2+3)
              && *(p1+4)==*(p2+4)
              && *(p1+5)==*(p2+5)
              && *(p1+6)==*(p2+6)
              && *(p1+7)==*(p2+7));
    case 9:
      return (*p1==*p2
              && *(p1+1)==*(p2+1)
              && *(p1+2)==*(p2+2)
              && *(p1+3)==*(p2+3)
              && *(p1+4)==*(p2+4)
              && *(p1+5)==*(p2+5)
              && *(p1+6)==*(p2+6)
              && *(p1+7)==*(p2+7)
              && *(p1+8)==*(p2+8));
    default:
      NSCAssert(NO,@"Compraison too long");
      return NO;
    };
};

//--------------------------------------------------------------------
NSString* baseStringByConvertingFromHTML(NSString* string,GSWHTMLConvertingStruct* convStructPtr,BOOL includeBR)
{
  NSString* str=nil;
  int length=[string length];
  NSCAssert(convStructPtr->charsCount>0,@"normalChars not initialized");
  if (length>0)
    {
      BOOL changed=NO;
      int srcLen=0;
      int dstLen=0;
      unichar dstUnichar;
      unichar* pString=GSAutoreleasedBuffer((length+1)*sizeof(unichar));
      int i=0;
      int j=0;
      [string getCharacters:pString];
      //NSDebugFLog(@"string=%@",string);
      while(i<(length-2)) // at least 2 characters for html coded
        {
          srcLen=0;
          /*NSDebugFLog(@"i=%d: c=%@",i,[NSString stringWithCharacters:pString+i
                                                length:length-i]);*/
          if (includeBR
              && length-i>=unicodeBRLen
              && areUnicharEquals(pString+i,unicodeBR,unicodeBRLen))
            {
              srcLen=unicodeBRLen;
              dstLen=1;
              dstUnichar='\n';
            }
          else
            {
              for(j=0;j<convStructPtr->charsCount;j++)
                {
                  if (length-i>=convStructPtr->htmlCharsLen[j]
                      && areUnicharEquals(pString+i,htmlCharsAtIndex(convStructPtr,j),convStructPtr->htmlCharsLen[j]))
                    {
                      srcLen=convStructPtr->htmlCharsLen[j];
                      dstLen=1;
                      dstUnichar=convStructPtr->normalChars[j];
                      break;
                    }
                };
            };
          if (srcLen>0)
            {
              /*NSDebugFLog(@"i=%d j=%d: srcLen=%d dstLen=%d by '%@'",i,j,srcLen,dstLen,[NSString stringWithCharacters:&dstUnichar
                                                                                                length:dstLen]);*/
              changed=YES;
              /*
              NSDebugFLog(@"-1==> %@",[NSString stringWithCharacters:pString
                                                length:length]);
              NSDebugFLog(@"0==> %@",[NSString stringWithCharacters:pString
                                               length:length]);
              NSDebugFLog(@"Copy %d characters from pos %d to pos %d",(length-i-srcLen),i+srcLen,i+dstLen);
              */
              GSWMemMove(pString+i+dstLen,pString+i+srcLen,sizeof(unichar)*(length-i-srcLen));
              /*
              NSDebugFLog(@"1==> %@",[NSString stringWithCharacters:pString
                                               length:length+dstLen-srcLen]);
              NSDebugFLog(@"Copy %d characters to pos %d",dstLen,i);
              */
              GSWMemMove(pString+i,&dstUnichar,sizeof(unichar)*dstLen);
              i+=dstLen;
              length+=dstLen-srcLen;
              /*
              NSDebugFLog(@"2==> i=%d %@",i,[NSString stringWithCharacters:pString
              length:length]);
              */
            };
          if (srcLen==0)
            i++;
        };
      if (changed)
        str=(*stringClass_stringWithCharactersIMP)(stringClass,stringWithCharactersSEL,pString,length);
      else if ([string isKindOfClass:mutableStringClass])
        str=(*stringClass_stringWithStringIMP)(stringClass,stringWithStringSEL,string);
      else
        str=string;
    }
  else if ([string isKindOfClass:mutableStringClass])
    str=@"";
  else
    str=AUTORELEASE(RETAIN(string));
  return str;
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
-(NSString*) decodeURLEncoding:(NSStringEncoding) encoding
{
  unsigned orglen = [self length];
  NSMutableData *new = [NSMutableData dataWithLength: orglen];
  const unsigned char *read;
  unsigned char *write;
  unsigned i,n,l;

  read  = [self UTF8String];
  write = [new mutableBytes];
  for (l=0,i=0,n=orglen;i<n;i++,l++)
    {
      switch (read[i])
    	{
    	    case '%':
   	      {
         		unsigned char chh, chl;
         
         		chh = read[++i];
         		chh = isdigit(chh) ? chh - '0' : (toupper(chh) - 'A') + 10;
                     
         		chl = read[++i];
         		chl = isdigit(chl) ? chl - '0' : (toupper(chl) - 'A') + 10;
         
         		*write++ = (chh << 4)|chl;
         		break;
   	      }
    	    case '+':
    	      {
          		*write++ = ' ';
          		break;
    	      }
    	    default:
    	      {
          		*write++ = read[i];
    	      }
    	}
    }
  [new setLength: l];

  return AUTORELEASE([[NSString alloc] initWithData: new 
                                           encoding: encoding]);
}


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
-(NSDictionary*) dictionaryQueryStringWithEncoding: (NSStringEncoding) encoding
{
  return [self dictionaryWithSep1:@"&"
               withSep2:@"="
               withOptionUnescape:YES
               forceArray:YES
               encoding: encoding];
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryWithSep1:(NSString*)sep1
                          withSep2:(NSString*)sep2
                withOptionUnescape:(BOOL)unescape
{
  return [self dictionaryWithSep1:sep1
               withSep2:sep2
               withOptionUnescape:unescape
               forceArray:NO
               encoding:[GSWMessage defaultEncoding]];
};

//--------------------------------------------------------------------
-(NSDictionary*)dictionaryWithSep1:(NSString*)sep1
                          withSep2:(NSString*)sep2
                withOptionUnescape:(BOOL)unescape
                        forceArray:(BOOL)forceArray// Put value in array even if there's only one value
                          encoding:(NSStringEncoding) encoding
{
  NSMutableDictionary*  pDico=nil;
  if ([self length]>0)
    {
      NSArray* listItems = [self componentsSeparatedByString:sep1];
      int iCount=0;
      int itemsCount=[listItems count];

      pDico=(NSMutableDictionary*)[NSMutableDictionary dictionary];

      for(iCount=0;iCount<itemsCount;iCount++)
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
                    key=[key decodeURLEncoding: encoding];
                }
              else if ([listParam count]==2)
                {
                  key=[listParam objectAtIndex:0];
                  value=[listParam objectAtIndex:1];
                  if (unescape)
                    {
                      key=[key decodeURLEncoding: encoding];
                      value= [value decodeURLEncoding: encoding];
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
  return stringByEscapingHTMLString(self);
};

//--------------------------------------------------------------------
-(NSString*)stringByEscapingHTMLAttributeValue
{
return stringByEscapingHTMLAttributeValue(self);
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingToHTMLEntities
{
  return stringByConvertingToHTMLEntities(self);
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingFromHTMLEntities
{
  return stringByConvertingFromHTMLEntities(self);
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingToHTML
{
  return stringByConvertingToHTML(self);
};

//--------------------------------------------------------------------
-(NSString*)stringByConvertingFromHTML
{
  return stringByConvertingFromHTML(self);
};

@end


/** GSWDeclarationParser - <title>GSWeb: Class GSWDeclarationParser</title>

   Copyright (C) 2004 Free Software Foundation, Inc.
  
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Mar 2004
   
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

// $Id$

#ifndef _GSWDeclarationParser_h__
	#define _GSWDeclarationParser_h__

typedef struct _GSWDeclarationParserIMPs
{
  GSWIMP_BOOL _skipBlanksIMP;
  GSWIMP_BOOL _skipCommentIMP;
  GSWIMP_BOOL _skipBlanksAndCommentsIMP;
  IMP _parsePragmaIMP;
  IMP _parseIdentifierIMP;
  IMP _parseKeyIMP;
  IMP _parseQuotedStringIMP;
  IMP _parseHexDataIMP;
  IMP _parseKeyPathIMP;
  IMP _tryParseBooleanIMP;
  IMP _parseNumberIMP;
  IMP _parseHexNumberIMP;
  IMP _parseValueAsAssociationIMP;
  IMP _parseDictionaryWithValuesAsAssociationsIMP;
  IMP _parseArrayIMP;
  IMP _parseDeclarationIMP;
} GSWDeclarationParserIMPs;

/** Fill impsPtr structure with IMPs for context **/
GSWEB_EXPORT void GetGSWDeclarationParserIMPS(GSWDeclarationParserIMPs* impsPtr,GSWDeclarationParser* declarationParser);


GS_EXPORT NSString* const GSWDFEMissingDeclarationForElement;
GS_EXPORT NSString* const GSWDFEMissingElementName;
GS_EXPORT NSString* const GSWDFEMissingClassNameForElement;
GS_EXPORT NSString* const GSWDFEElementCreationFailed;
GS_EXPORT NSString* const GSWDFEMissingIdentifier;
GS_EXPORT NSString* const GSWDFEMissingPragmaDelegate;
GS_EXPORT NSString* const GSWDFEUnknownPragmaDirective;
GS_EXPORT NSString* const GSWDFEMissingQuotedStringEnd;
GS_EXPORT NSString* const GSWDFEMissingHexStringDataEnd;
GS_EXPORT NSString* const GSWDFEMissingQuotedKeyPathEnd;
GS_EXPORT NSString* const GSWDFEWrongKeyPathFormat;
GS_EXPORT NSString* const GSWDFEEmptyKeyPath;
GS_EXPORT NSString* const GSWDFEWrongNumberFormat;
GS_EXPORT NSString* const GSWDFEWrongHexNumberFormat;
GS_EXPORT NSString* const GSWDFEUnexpectedBufferEnd;
GS_EXPORT NSString* const GSWDFEMissingValue;
GS_EXPORT NSString* const GSWDFEMissingSeparator;
GS_EXPORT NSString* const GSWDFEDictionaryParsingError;
GS_EXPORT NSString* const GSWDFEArrayParsingError;
GS_EXPORT NSString* const GSWDFEUnexpectedCharacter;
GS_EXPORT NSString* const GSWDFEMissingAliasedDeclaration;


//====================================================================
@interface GSWDeclarationFormatException : NSException
/** Returns YES if we can delay exception reporting (so all errors are 
accumulated instead of blocking on first error) **/
-(BOOL)canDelay;
@end

//====================================================================
@protocol GSWDeclarationParserPragmaDelegate
-(NSDictionary*)includedDeclarationsFromFilePath:(NSString*)file
                              fromFrameworkNamed:(NSString*)frameworkName;
@end

//====================================================================
@interface GSWDeclarationParser : GSWBaseParser
{
  id<GSWDeclarationParserPragmaDelegate> _pragmaDelegate;
  NSMutableDictionary* _declarations;
  NSString* _fileName;
  NSString* _frameworkName;

@public
  GSWDeclarationParserIMPs _selfIMPs;
}
+(GSWDeclarationParser*)declarationParserWithPragmaDelegate:(id<GSWDeclarationParserPragmaDelegate>)pragmaDelegate;
-(id)initWithPragmaDelegate:(id<GSWDeclarationParserPragmaDelegate>)pragmaDelegate;
-(NSDictionary*)parseDeclarationString:(NSString*)declarationString;

-(NSDictionary*)parseDeclarationString:(NSString*)declarationString
                                 named:(NSString*)declarationFileName
                      inFrameworkNamed:(NSString*)declarationFrameworkName;

-(BOOL)skipBlanks;
-(BOOL)skipComment;
-(BOOL)skipBlanksAndComments;
-(void)parsePragma;
-(NSString*)parseIdentifier;
-(NSData*)parseHexData;
-(NSNumber*)tryParseBoolean;
-(NSNumber*)parseNumber;
-(NSNumber*)parseHexNumber;
-(id)parseValueAsAssociation:(BOOL)asAssociation;
-(NSDictionary*)parseDictionaryWithValuesAsAssociations:(BOOL)valuesAsAssociations;
-(NSArray*)parseArray;
-(GSWDeclaration*)parseDeclaration;
@end

#endif // _GSWDeclarationParser_h__

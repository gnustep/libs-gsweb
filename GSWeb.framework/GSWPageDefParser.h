#ifndef INC_GSWPageDefParser_h_
#define INC_GSWPageDefParser_h_

/*
 * ANTLR-generated file resulting from grammar /tmp/PageDef.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.5.0; 1996,1997,1998,1999
 */


#include "GSWeb.h"

#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRTokenizer.h"
#include "gsantlr/ANTLRTokenBuffer.h"
#include "gsantlr/ANTLRLLkParser.h"

@class ANTLRBitSet;

@interface GSWPageDefParser : ANTLRLLkParser
 {

	NSMutableDictionary* elements;
	GSWPageDefElement* currentElement;
	NSString* currentMemberName;
	GSWAssociation* currentAssociation;
	NSMutableArray* includes;
	NSMutableArray* errors;
	NSMutableArray* warnings;
 };
	-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer maxK:(int)_k;
	-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer;
	-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer maxK:(int)_k;
	-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer;
	/*public: */-(void) document;
	/*public: */-(void) object;
	/*public: */-(void) include;
	/*public: */-(void) definition;
	/*public: */-(void) classname;
	/*public: */-(void) member;
	/*public: */-(void) mname;
	/*public: */-(void) mvalue;
	/*public: */-(void) idref;
@end;


GSWEB_EXPORT CONST NSString* GSWPageDefParser___tokenNames[];

GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_0_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_0;
GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_1_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_1;
GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_2_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_2;
GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_3_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_3;
GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_4_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_4;
GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_5_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_5;
GSWEB_EXPORT CONST unsigned long GSWPageDefParser___tokenSet_6_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefParser___tokenSet_6;

#endif /*INC_GSWPageDefParser_h_*/

#ifndef INC_GSWHTMLAttrParser_h_
#define INC_GSWHTMLAttrParser_h_

/*
 * ANTLR-generated file resulting from grammar htmltag.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.5.0; 1996,1997,1998,1999
 */


#include <GSWeb/GSWeb.h>

#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRTokenizer.h"
#include "gsantlr/ANTLRTokenBuffer.h"
#include "gsantlr/ANTLRLLkParser.h"

@class ANTLRBitSet;

@interface GSWHTMLAttrParser : ANTLRLLkParser
 {

	NSString* tagName;
	NSMutableDictionary* attributes;
	NSString* currentAttrName; //no retain
	id currentValue; //no retain
	NSMutableArray* errors;
	NSMutableArray* warnings;
 };
	-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer maxK:(int)_k;
	-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer;
	-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer maxK:(int)_k;
	-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer;
	/*public: */-(void) tag;
	/*public: */-(void) attr;
	/*public: */-(void) mvalue;
@end;


extern CONST NSString* GSWHTMLAttrParser___tokenNames[];

extern CONST unsigned long GSWHTMLAttrParser___tokenSet_0_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_0;
extern CONST unsigned long GSWHTMLAttrParser___tokenSet_1_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_1;
extern CONST unsigned long GSWHTMLAttrParser___tokenSet_2_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_2;
extern CONST unsigned long GSWHTMLAttrParser___tokenSet_3_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_3;
extern CONST unsigned long GSWHTMLAttrParser___tokenSet_4_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_4;
extern CONST unsigned long GSWHTMLAttrParser___tokenSet_5_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_5;
extern CONST unsigned long GSWHTMLAttrParser___tokenSet_6_data_[];
extern ANTLRBitSet* GSWHTMLAttrParser___tokenSet_6;

#endif /*INC_GSWHTMLAttrParser_h_*/

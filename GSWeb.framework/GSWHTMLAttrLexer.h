#ifndef INC_GSWHTMLAttrLexer_h_
#define INC_GSWHTMLAttrLexer_h_

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
#include "gsantlr/ANTLRCommonToken.h"
#include "gsantlr/ANTLRCharBuffer.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRCharScanner.h"
@interface GSWHTMLAttrLexer : ANTLRCharScanner
 {
 };
	-(void) initLiterals;
	-(BOOL)getCaseSensitiveLiterals;
	-(id)initWithTextStream:(ANTLRDefTextInputStream)_in;
	-(id)initWithCharBuffer:(ANTLRCharBuffer*)_buffer;
	-(ANTLRDefToken) nextToken;
	/*public: */-(void) mIDENTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLETTERWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mDIGITWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mASSIGNWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mWSWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mSTRINGWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPOINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPCINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mHEXNUMWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXINTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXDIGITWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLCLETTERWithCreateToken:(BOOL)_createToken ;
@end



extern CONST unsigned long GSWHTMLAttrLexer___tokenSet_0_data_[];
extern ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_0;
extern CONST unsigned long GSWHTMLAttrLexer___tokenSet_1_data_[];
extern ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_1;
extern CONST unsigned long GSWHTMLAttrLexer___tokenSet_2_data_[];
extern ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_2;
extern CONST unsigned long GSWHTMLAttrLexer___tokenSet_3_data_[];
extern ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_3;

#endif /*INC_GSWHTMLAttrLexer_h_*/

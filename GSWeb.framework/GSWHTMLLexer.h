#ifndef INC_GSWHTMLLexer_h_
#define INC_GSWHTMLLexer_h_

/*
 * ANTLR-generated file resulting from grammar html.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.7.1; 1996,1997,1998,1999,2000
 */


#include <GSWeb/GSWeb.h>


#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRCommonToken.h"
#include "gsantlr/ANTLRCharBuffer.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRCharScanner.h"

@interface GSWHTMLLexer : ANTLRCharScanner
 {
 };
	-(void) initLiterals;
	-(BOOL)getCaseSensitiveLiterals;
	-(id)initWithTextStream:(ANTLRDefTextInputStream)_in;
	-(id)initWithCharBuffer:(ANTLRCharBuffer*)_buffer;
	-(ANTLRDefToken) nextToken;
	/*public: */-(void) mOPENTAGWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mWORDWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLETTERWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mWSWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mATTRWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mCLOSETAGWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mINTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mSTRINGWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXNUMWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mTEXTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mCOMMENTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mCOMMENT_DATAWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mDIGITWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mWSCHARSWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mSPECIALWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXINTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXDIGITWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLCLETTERWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mUPLETTERWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mUNDEFINED_TOKENWithCreateToken:(BOOL)_createToken ;
@end



extern CONST unsigned long GSWHTMLLexer___tokenSet_0_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_0;
extern CONST unsigned long GSWHTMLLexer___tokenSet_1_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_1;
extern CONST unsigned long GSWHTMLLexer___tokenSet_2_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_2;
extern CONST unsigned long GSWHTMLLexer___tokenSet_3_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_3;
extern CONST unsigned long GSWHTMLLexer___tokenSet_4_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_4;
extern CONST unsigned long GSWHTMLLexer___tokenSet_5_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_5;
extern CONST unsigned long GSWHTMLLexer___tokenSet_6_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_6;
extern CONST unsigned long GSWHTMLLexer___tokenSet_7_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_7;
extern CONST unsigned long GSWHTMLLexer___tokenSet_8_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_8;
extern CONST unsigned long GSWHTMLLexer___tokenSet_9_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_9;
extern CONST unsigned long GSWHTMLLexer___tokenSet_10_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_10;
extern CONST unsigned long GSWHTMLLexer___tokenSet_11_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_11;
extern CONST unsigned long GSWHTMLLexer___tokenSet_12_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_12;
extern CONST unsigned long GSWHTMLLexer___tokenSet_13_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_13;
extern CONST unsigned long GSWHTMLLexer___tokenSet_14_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_14;
extern CONST unsigned long GSWHTMLLexer___tokenSet_15_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_15;
extern CONST unsigned long GSWHTMLLexer___tokenSet_16_data_[];
extern ANTLRBitSet* GSWHTMLLexer___tokenSet_16;

#endif /*INC_GSWHTMLLexer_h_*/

#ifndef INC_GSWPageDefLexer_h_
#define INC_GSWPageDefLexer_h_

/*
 * ANTLR-generated file resulting from grammar PageDef.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.5.0; 1996,1997,1998,1999
 */


#include <gsweb/GSWeb.framework/GSWeb.h>


#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRCommonToken.h"
#include "gsantlr/ANTLRCharBuffer.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRCharScanner.h"
@interface GSWPageDefLexer : ANTLRCharScanner
 {
 };
	-(void) initLiterals;
	-(BOOL)getCaseSensitiveLiterals;
	-(id)initWithTextStream:(ANTLRDefTextInputStream)_in;
	-(id)initWithCharBuffer:(ANTLRCharBuffer*)_buffer;
	-(ANTLRDefToken) nextToken;
	/*public: */-(void) mSL_COMMENTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mML_COMMENTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mINCLUDEWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mIDENTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLETTERWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mDIGITWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPIDENTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPOINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mSTRINGWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mYESWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mNOWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mLCURLYWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mRCURLYWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mSEMIWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mCIRCWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mTILDEWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mCOLUMNWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mASSIGNWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mWSWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mESCWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mHEXNUMWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXINTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXDIGITWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLCLETTERWithCreateToken:(BOOL)_createToken ;
@end



extern CONST unsigned long GSWPageDefLexer___tokenSet_0_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_0;
extern CONST unsigned long GSWPageDefLexer___tokenSet_1_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_1;
extern CONST unsigned long GSWPageDefLexer___tokenSet_2_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_2;
extern CONST unsigned long GSWPageDefLexer___tokenSet_3_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_3;
extern CONST unsigned long GSWPageDefLexer___tokenSet_4_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_4;
extern CONST unsigned long GSWPageDefLexer___tokenSet_5_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_5;
extern CONST unsigned long GSWPageDefLexer___tokenSet_6_data_[];
extern ANTLRBitSet* GSWPageDefLexer___tokenSet_6;

#endif /*INC_GSWPageDefLexer_h_*/

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
#include "GSWHTMLParser.h"
#include "GSWHTMLTokenTypes.h"
#include "gsantlr/ANTLRNoViableAltException.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRAST.h"
#include "gsantlr/ANTLRASTPair.h"
@implementation GSWHTMLParser
-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer maxK:(int)_k
{
	//LOGObjectFnStart();
	self=[super initWithTokenBuffer:_buffer maxK:_k];
	[self setTokenNames:GSWHTMLParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer
{
	//LOGObjectFnStart();
	self=[super initWithTokenBuffer:_buffer maxK:5];
	[self setTokenNames:GSWHTMLParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer maxK:(int)_k
{
	//LOGObjectFnStart();
	self=[super initWithTokenizer:_lexer maxK:_k];
	[self setTokenNames:GSWHTMLParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer
{
	//LOGObjectFnStart();
	self=[self initWithTokenizer:_lexer maxK:5];
	[self setTokenNames:GSWHTMLParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(void) document
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST document_AST = ANTLRnullAST;
	ANTLRDefToken  ot = nil;
	ANTLRDefAST ot_AST = ANTLRnullAST;
	ANTLRDefToken  ct = nil;
	ANTLRDefAST ct_AST = ANTLRnullAST;
	ANTLRDefToken  com = nil;
	ANTLRDefAST com_AST = ANTLRnullAST;
	
		DESTROY(errors);
		DESTROY(warnings);
	
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			int _cnt3=0;
			do
			{
				switch ( [self LA:1])
				{
				case GSWHTMLTokenType_WS:
				{
					{
						ANTLRDefAST tmp1_AST = ANTLRnullAST;
						tmp1_AST = [astFactory create:[self LT:1]];
						[astFactory addASTChild:tmp1_AST in:currentAST];
					}
					[self matchTokenType:GSWHTMLTokenType_WS];
					break;
				}
				case GSWHTMLTokenType_TEXT:
				{
					{
						ANTLRDefAST tmp2_AST = ANTLRnullAST;
						tmp2_AST = [astFactory create:[self LT:1]];
						[astFactory addASTChild:tmp2_AST in:currentAST];
					}
					[self matchTokenType:GSWHTMLTokenType_TEXT];
					break;
				}
				case GSWHTMLTokenType_OPENTAG:
				{
					ot = [self LT:1];
					{
						ot_AST = [astFactory create:ot];
						[astFactory addASTChild:ot_AST in:currentAST];
					}
					[self matchTokenType:GSWHTMLTokenType_OPENTAG];
					[ot_AST setText:[[[ot_AST text] stringByDeletingPrefix:@"<"] stringByDeletingSuffix:@">"]];
					break;
				}
				case GSWHTMLTokenType_CLOSETAG:
				{
					ct = [self LT:1];
					{
						ct_AST = [astFactory create:ct];
						[astFactory addASTChild:ct_AST in:currentAST];
					}
					[self matchTokenType:GSWHTMLTokenType_CLOSETAG];
					[ct_AST setText:[[[ct_AST text] stringByDeletingPrefix:@"</"] stringByDeletingSuffix:@">"]];
					break;
				}
				case GSWHTMLTokenType_COMMENT:
				{
					com = [self LT:1];
					{
						com_AST = [astFactory create:com];
						[astFactory addASTChild:com_AST in:currentAST];
					}
					[self matchTokenType:GSWHTMLTokenType_COMMENT];
					[com_AST setText:[[[com_AST text] stringByDeletingPrefix:@"<!--"] stringByDeletingSuffix:@"-->"]];
					break;
				}
				default:
				{
					if ( _cnt3>=1 ) { goto _loop3; } else {[ANTLRNoViableAltException raiseWithToken:[self LT:1]];}
				}
				}
				_cnt3++;
			} while (YES);
			_loop3:;
		}
		document_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWHTMLParser___tokenSet_0];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,document_AST);
	//LOGObjectFnStop();
}

static CONST NSString* GSWHTMLParser___tokenNames[] = {
	@"<0>",
	@"EOF",
	@"<2>",
	@"NULL_TREE_LOOKAHEAD",
	@"WS",
	@"TEXT",
	@"OPENTAG",
	@"CLOSETAG",
	@"COMMENT",
	@"ATTR",
	@"COMMENT_DATA",
	@"WORD",
	@"STRING",
	@"WSCHARS",
	@"SPECIAL",
	@"HEXNUM",
	@"INT",
	@"HEXINT",
	@"DIGIT",
	@"HEXDIGIT",
	@"LCLETTER",
	@"UPLETTER",
	@"LETTER",
	@"UNDEFINED_TOKEN",
0
};

CONST unsigned long GSWHTMLParser___tokenSet_0_data_[] = { 2UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLParser___tokenSet_0=nil;
+(void)initialize
{
	if (!GSWHTMLParser___tokenSet_0)
		GSWHTMLParser___tokenSet_0=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLParser___tokenSet_0_data_ length:8] retain];
}
+(void)dealloc
{
	DESTROY(GSWHTMLParser___tokenSet_0);
	[[self superclass] dealloc];
}
@end


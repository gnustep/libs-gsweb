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
#include "GSWHTMLAttrParser.h"
#include "GSWHTMLAttrTokenTypes.h"
#include "gsantlr/ANTLRNoViableAltException.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRAST.h"
#include "gsantlr/ANTLRASTPair.h"
@implementation GSWHTMLAttrParser
-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer maxK:(int)_k
{
	//LOGObjectFnStart();
	self=[super initWithTokenBuffer:_buffer maxK:_k];
	[self setTokenNames:GSWHTMLAttrParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer
{
	//LOGObjectFnStart();
	self=[super initWithTokenBuffer:_buffer maxK:5];
	[self setTokenNames:GSWHTMLAttrParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer maxK:(int)_k
{
	//LOGObjectFnStart();
	self=[super initWithTokenizer:_lexer maxK:_k];
	[self setTokenNames:GSWHTMLAttrParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer
{
	//LOGObjectFnStart();
	self=[self initWithTokenizer:_lexer maxK:5];
	[self setTokenNames:GSWHTMLAttrParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(void) tag
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST tag_AST = ANTLRnullAST;
	ANTLRDefToken  tagNameLocal = nil;
	ANTLRDefAST tagNameLocal_AST = ANTLRnullAST;
	
		DESTROY(attributes);
		DESTROY(tagName);
		DESTROY(errors);
		DESTROY(warnings);
		attributes=[NSMutableDictionary new];
	
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		tagNameLocal = [self LT:1];
		{
			tagNameLocal_AST = [astFactory create:tagNameLocal];
			[astFactory addASTChild:tagNameLocal_AST in:currentAST];
		}
		[self matchTokenType:GSWHTMLAttrTokenType_IDENT];
		NSDebugMLLog(@"template",@"tagNameLocal:%@",[tagNameLocal_AST text]); ASSIGN(tagName,[tagNameLocal_AST text]); NSDebugMLLog(@"template",@"Found tagName=[%@]",tagName);
		{
			if (([self LA:1]==ANTLRToken_EOF_TYPE||[self LA:1]==GSWHTMLAttrTokenType_IDENT||[self LA:1]==GSWHTMLAttrTokenType_WS) && ([GSWHTMLAttrParser___tokenSet_0 isMember:[self LA:2]]))
			{
				{
					do
					{
						if (([self LA:1]==GSWHTMLAttrTokenType_IDENT||[self LA:1]==GSWHTMLAttrTokenType_WS))
						{
							{
								do
								{
									if (([self LA:1]==GSWHTMLAttrTokenType_WS))
									{
										{
											ANTLRDefAST tmp1_AST = ANTLRnullAST;
											tmp1_AST = [astFactory create:[self LT:1]];
											[astFactory addASTChild:tmp1_AST in:currentAST];
										}
										[self matchTokenType:GSWHTMLAttrTokenType_WS];
									}
									else
									{
										goto _loop5;
									}
									
								} while (YES);
								_loop5:;
							}
							{
								[self attr];
								[astFactory addASTChild:returnAST in:currentAST];
							}
						}
						else
						{
							goto _loop7;
						}
						
					} while (YES);
					_loop7:;
				}
			}
			else if (([self LA:1]==ANTLRToken_EOF_TYPE) && ([self LA:2]==ANTLRToken_EOF_TYPE))
			{
			}
			else
			{
				[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
			}
			
		}
		tag_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWHTMLAttrParser___tokenSet_1];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,tag_AST);
	//LOGObjectFnStop();
}

-(void) attr
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST attr_AST = ANTLRnullAST;
	ANTLRDefToken  attrName = nil;
	ANTLRDefAST attrName_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		attrName = [self LT:1];
		{
			attrName_AST = [astFactory create:attrName];
			[astFactory addASTChild:attrName_AST in:currentAST];
		}
		[self matchTokenType:GSWHTMLAttrTokenType_IDENT];
			DESTROY(currentValue); currentAttrName=[[attrName text]lowercaseString]; 
								NSDebugMLLog(@"template",@"Found currentAttrName=[%@]",currentAttrName);
							
		{
			if (([GSWHTMLAttrParser___tokenSet_0 isMember:[self LA:1]]) && ([GSWHTMLAttrParser___tokenSet_2 isMember:[self LA:2]]))
			{
				{
					do
					{
						if (([self LA:1]==GSWHTMLAttrTokenType_WS) && ([GSWHTMLAttrParser___tokenSet_0 isMember:[self LA:2]]))
						{
							{
								ANTLRDefAST tmp2_AST = ANTLRnullAST;
								tmp2_AST = [astFactory create:[self LT:1]];
								[astFactory addASTChild:tmp2_AST in:currentAST];
							}
							[self matchTokenType:GSWHTMLAttrTokenType_WS];
						}
						else
						{
							goto _loop11;
						}
						
					} while (YES);
					_loop11:;
				}
			}
			else if (([GSWHTMLAttrParser___tokenSet_0 isMember:[self LA:1]]) && ([GSWHTMLAttrParser___tokenSet_2 isMember:[self LA:2]]))
			{
			}
			else
			{
				[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
			}
			
		}
		{
			switch ( [self LA:1])
			{
			case GSWHTMLAttrTokenType_ASSIGN:
			{
				{
					ANTLRDefAST tmp3_AST = ANTLRnullAST;
					tmp3_AST = [astFactory create:[self LT:1]];
					[astFactory addASTChild:tmp3_AST in:currentAST];
				}
				[self matchTokenType:GSWHTMLAttrTokenType_ASSIGN];
				{
					if (([GSWHTMLAttrParser___tokenSet_3 isMember:[self LA:1]]) && ([GSWHTMLAttrParser___tokenSet_4 isMember:[self LA:2]]))
					{
						{
							do
							{
								if (([self LA:1]==GSWHTMLAttrTokenType_WS))
								{
									{
										ANTLRDefAST tmp4_AST = ANTLRnullAST;
										tmp4_AST = [astFactory create:[self LT:1]];
										[astFactory addASTChild:tmp4_AST in:currentAST];
									}
									[self matchTokenType:GSWHTMLAttrTokenType_WS];
								}
								else
								{
									goto _loop15;
								}
								
							} while (YES);
							_loop15:;
						}
					}
					else if (([GSWHTMLAttrParser___tokenSet_5 isMember:[self LA:1]]) && ([self LA:2]==ANTLRToken_EOF_TYPE||[self LA:2]==GSWHTMLAttrTokenType_IDENT||[self LA:2]==GSWHTMLAttrTokenType_WS))
					{
					}
					else
					{
						[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
					}
					
				}
				{
					[self mvalue];
					[astFactory addASTChild:returnAST in:currentAST];
				}
				break;
			}
			case ANTLRToken_EOF_TYPE:
			case GSWHTMLAttrTokenType_IDENT:
			case GSWHTMLAttrTokenType_WS:
			{
				break;
			}
			default:
			{
				[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
			}
			}
		}
		NSDebugMLLog(@"template",@"Add currentValue=[%@]",currentValue); [attributes setObject:currentValue forKey:currentAttrName];
		attr_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWHTMLAttrParser___tokenSet_6];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,attr_AST);
	//LOGObjectFnStop();
}

-(void) mvalue
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST mvalue_AST = ANTLRnullAST;
	ANTLRDefToken  intValue = nil;
	ANTLRDefAST intValue_AST = ANTLRnullAST;
	ANTLRDefToken  stringValue = nil;
	ANTLRDefAST stringValue_AST = ANTLRnullAST;
	ANTLRDefToken  hexNumValue = nil;
	ANTLRDefAST hexNumValue_AST = ANTLRnullAST;
	ANTLRDefToken  pcValue = nil;
	ANTLRDefAST pcValue_AST = ANTLRnullAST;
	ANTLRDefToken  identValue = nil;
	ANTLRDefAST identValue_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			switch ( [self LA:1])
			{
			case GSWHTMLAttrTokenType_INT:
			{
				intValue = [self LT:1];
				{
					intValue_AST = [astFactory create:intValue];
					[astFactory addASTChild:intValue_AST in:currentAST];
				}
				[self matchTokenType:GSWHTMLAttrTokenType_INT];
				ASSIGN(currentValue,[NSNumber valueFromString:[intValue text]]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue);
				break;
			}
			case GSWHTMLAttrTokenType_STRING:
			{
				stringValue = [self LT:1];
				{
					stringValue_AST = [astFactory create:stringValue];
					[astFactory addASTChild:stringValue_AST in:currentAST];
				}
				[self matchTokenType:GSWHTMLAttrTokenType_STRING];
					ASSIGN(currentValue,[stringValue text]);
								if ([currentValue isQuotedWith:@"\""])
									{
										ASSIGN(currentValue,[currentValue stringWithoutQuote:@"\""]);
									};
								NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue);
							
				break;
			}
			case GSWHTMLAttrTokenType_HEXNUM:
			{
				hexNumValue = [self LT:1];
				{
					hexNumValue_AST = [astFactory create:hexNumValue];
					[astFactory addASTChild:hexNumValue_AST in:currentAST];
				}
				[self matchTokenType:GSWHTMLAttrTokenType_HEXNUM];
				ASSIGN(currentValue,[NSNumber valueFromString:[hexNumValue text]]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue);
				break;
			}
			case GSWHTMLAttrTokenType_INTPC:
			{
				pcValue = [self LT:1];
				{
					pcValue_AST = [astFactory create:pcValue];
					[astFactory addASTChild:pcValue_AST in:currentAST];
				}
				[self matchTokenType:GSWHTMLAttrTokenType_INTPC];
				ASSIGN(currentValue,[pcValue text]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue);
				break;
			}
			case GSWHTMLAttrTokenType_IDENT:
			{
				identValue = [self LT:1];
				{
					identValue_AST = [astFactory create:identValue];
					[astFactory addASTChild:identValue_AST in:currentAST];
				}
				[self matchTokenType:GSWHTMLAttrTokenType_IDENT];
				ASSIGN(currentValue,[identValue text]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue);
				break;
			}
			default:
			{
				[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
			}
			}
		}
		mvalue_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWHTMLAttrParser___tokenSet_6];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,mvalue_AST);
	//LOGObjectFnStop();
}

static CONST NSString* GSWHTMLAttrParser___tokenNames[] = {
	@"<0>",
	@"EOF",
	@"<2>",
	@"NULL_TREE_LOOKAHEAD",
	@"IDENT",
	@"WS",
	@"ASSIGN",
	@"INT",
	@"STRING",
	@"HEXNUM",
	@"INTPC",
	@"POINT",
	@"PCINT",
	@"HEXINT",
	@"DIGIT",
	@"HEXDIGIT",
	@"LCLETTER",
	@"LETTER",
0
};

CONST unsigned long GSWHTMLAttrParser___tokenSet_0_data_[] = { 114UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_0=nil;
CONST unsigned long GSWHTMLAttrParser___tokenSet_1_data_[] = { 2UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_1=nil;
CONST unsigned long GSWHTMLAttrParser___tokenSet_2_data_[] = { 2034UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_2=nil;
CONST unsigned long GSWHTMLAttrParser___tokenSet_3_data_[] = { 1968UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_3=nil;
CONST unsigned long GSWHTMLAttrParser___tokenSet_4_data_[] = { 1970UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_4=nil;
CONST unsigned long GSWHTMLAttrParser___tokenSet_5_data_[] = { 1936UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_5=nil;
CONST unsigned long GSWHTMLAttrParser___tokenSet_6_data_[] = { 50UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrParser___tokenSet_6=nil;
+(void)initialize
{
	if (!GSWHTMLAttrParser___tokenSet_0)
		GSWHTMLAttrParser___tokenSet_0=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_0_data_ length:8] retain];
	if (!GSWHTMLAttrParser___tokenSet_1)
		GSWHTMLAttrParser___tokenSet_1=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_1_data_ length:8] retain];
	if (!GSWHTMLAttrParser___tokenSet_2)
		GSWHTMLAttrParser___tokenSet_2=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_2_data_ length:8] retain];
	if (!GSWHTMLAttrParser___tokenSet_3)
		GSWHTMLAttrParser___tokenSet_3=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_3_data_ length:8] retain];
	if (!GSWHTMLAttrParser___tokenSet_4)
		GSWHTMLAttrParser___tokenSet_4=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_4_data_ length:8] retain];
	if (!GSWHTMLAttrParser___tokenSet_5)
		GSWHTMLAttrParser___tokenSet_5=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_5_data_ length:8] retain];
	if (!GSWHTMLAttrParser___tokenSet_6)
		GSWHTMLAttrParser___tokenSet_6=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrParser___tokenSet_6_data_ length:8] retain];
}
+(void)dealloc
{
	DESTROY(GSWHTMLAttrParser___tokenSet_0);
	DESTROY(GSWHTMLAttrParser___tokenSet_1);
	DESTROY(GSWHTMLAttrParser___tokenSet_2);
	DESTROY(GSWHTMLAttrParser___tokenSet_3);
	DESTROY(GSWHTMLAttrParser___tokenSet_4);
	DESTROY(GSWHTMLAttrParser___tokenSet_5);
	DESTROY(GSWHTMLAttrParser___tokenSet_6);
	[[self superclass] dealloc];
}
@end


/*
 * ANTLR-generated file resulting from grammar PageDef.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.5.0; 1996,1997,1998,1999
 */


#include <GSWeb/GSWeb.h>

#include "gsantlr/ANTLRCommon.h"
#include "GSWPageDefParser.h"
#include "GSWPageDefTokenTypes.h"
#include "gsantlr/ANTLRNoViableAltException.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRAST.h"
#include "gsantlr/ANTLRASTPair.h"
@implementation GSWPageDefParser
-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer maxK:(int)_k
{
	//LOGObjectFnStart();
	self=[super initWithTokenBuffer:_buffer maxK:_k];
	[self setTokenNames:GSWPageDefParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenBuffer:(ANTLRTokenBuffer *)_buffer
{
	//LOGObjectFnStart();
	self=[super initWithTokenBuffer:_buffer maxK:5];
	[self setTokenNames:GSWPageDefParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer maxK:(int)_k
{
	//LOGObjectFnStart();
	self=[super initWithTokenizer:_lexer maxK:_k];
	[self setTokenNames:GSWPageDefParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithTokenizer:(ANTLRDefTokenizer)_lexer
{
	//LOGObjectFnStart();
	self=[self initWithTokenizer:_lexer maxK:5];
	[self setTokenNames:GSWPageDefParser___tokenNames];
	//LOGObjectFnStop();
	return self;
}

-(void) document
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST document_AST = ANTLRnullAST;
	
		DESTROY(elements);
		elements=[NSMutableDictionary new];
		DESTROY(includes);
		includes=[NSMutableArray new];
		DESTROY(errors);
		DESTROY(warnings);
	
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			int _cnt5=0;
			do
			{
				switch ( [self LA:1])
				{
				case GSWPageDefTokenType_IDENT:
				{
					{
						[self object];
						[astFactory addASTChild:returnAST in:currentAST];
						[elements setObject:currentElement forKey:[currentElement elementName]];
					}
					break;
				}
				case GSWPageDefTokenType_INCLUDE:
				{
					{
						[self include];
						[astFactory addASTChild:returnAST in:currentAST];
					}
					break;
				}
				default:
				{
					if ( _cnt5>=1 ) { goto _loop5; } else {[ANTLRNoViableAltException raiseWithToken:[self LT:1]];}
				}
				}
				_cnt5++;
			} while (YES);
			_loop5:;
		}
		document_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_0];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,document_AST);
	//LOGObjectFnStop();
}

-(void) object
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST object_AST = ANTLRnullAST;
	ANTLRDefToken  objectId = nil;
	ANTLRDefAST objectId_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		objectId = [self LT:1];
		{
			objectId_AST = [astFactory create:objectId];
			[astFactory makeASTRoot:objectId_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_IDENT];
		currentElement=[[GSWPageDefElement new] autorelease]; [currentElement setElementName:[objectId_AST text]];
		{
			ANTLRDefAST tmp1_AST = ANTLRnullAST;
			tmp1_AST = [astFactory create:[self LT:1]];
			[astFactory makeASTRoot:tmp1_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_COLUMN];
		{
			[self definition];
			[astFactory addASTChild:returnAST in:currentAST];
		}
		object_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_1];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,object_AST);
	//LOGObjectFnStop();
}

-(void) include
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST include_AST = ANTLRnullAST;
	ANTLRDefToken  includeObj = nil;
	ANTLRDefAST includeObj_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			{
				ANTLRDefAST tmp2_AST = ANTLRnullAST;
				tmp2_AST = [astFactory create:[self LT:1]];
				[astFactory addASTChild:tmp2_AST in:currentAST];
			}
			[self matchTokenType:GSWPageDefTokenType_INCLUDE];
			{
				do
				{
					if (([self LA:1]==GSWPageDefTokenType_WS))
					{
						{
							ANTLRDefAST tmp3_AST = ANTLRnullAST;
							tmp3_AST = [astFactory create:[self LT:1]];
							[astFactory addASTChild:tmp3_AST in:currentAST];
						}
						[self matchTokenType:GSWPageDefTokenType_WS];
					}
					else
					{
						goto _loop9;
					}
					
				} while (YES);
				_loop9:;
			}
		}
		includeObj = [self LT:1];
		{
			includeObj_AST = [astFactory create:includeObj];
			[astFactory addASTChild:includeObj_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_STRING];
		[includes addObject:[self unescapedString:[[[includeObj  text] stringWithoutPrefix:@"\""] stringWithoutSuffix:@"\""]]];
		include_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_1];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,include_AST);
	//LOGObjectFnStop();
}

-(void) definition
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST definition_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			[self classname];
			[astFactory addASTChild:returnAST in:currentAST];
		}
		{
			ANTLRDefAST tmp4_AST = ANTLRnullAST;
			tmp4_AST = [astFactory create:[self LT:1]];
			[astFactory makeASTRoot:tmp4_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_LCURLY];
		{
			do
			{
				if (([self LA:1]==GSWPageDefTokenType_IDENT))
				{
					[self member];
					[astFactory addASTChild:returnAST in:currentAST];
					[currentElement setAssociation:currentAssociation forKey:currentMemberName]; DESTROY(currentMemberName); DESTROY(currentAssociation);
				}
				else
				{
					goto _loop15;
				}
				
			} while (YES);
			_loop15:;
		}
		{
			ANTLRDefAST tmp5_AST = ANTLRnullAST;
			tmp5_AST = [astFactory create:[self LT:1]];
		}
		[self matchTokenType:GSWPageDefTokenType_RCURLY];
		{
			switch ( [self LA:1])
			{
			case GSWPageDefTokenType_SEMI:
			{
				{
					ANTLRDefAST tmp6_AST = ANTLRnullAST;
					tmp6_AST = [astFactory create:[self LT:1]];
					[astFactory addASTChild:tmp6_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_SEMI];
				break;
			}
			case ANTLRToken_EOF_TYPE:
			case GSWPageDefTokenType_INCLUDE:
			case GSWPageDefTokenType_IDENT:
			{
				break;
			}
			default:
			{
				[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
			}
			}
		}
		definition_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_1];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,definition_AST);
	//LOGObjectFnStop();
}

-(void) classname
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST classname_AST = ANTLRnullAST;
	ANTLRDefToken  objectClass = nil;
	ANTLRDefAST objectClass_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		objectClass = [self LT:1];
		{
			objectClass_AST = [astFactory create:objectClass];
			[astFactory addASTChild:objectClass_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_IDENT];
		[currentElement setClassName:[objectClass text]];
		classname_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_2];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,classname_AST);
	//LOGObjectFnStop();
}

-(void) member
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST member_AST = ANTLRnullAST;
	ANTLRDefToken  memberName = nil;
	ANTLRDefAST memberName_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		memberName = [self LT:1];
		{
			memberName_AST = [astFactory create:memberName];
			[astFactory makeASTRoot:memberName_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_IDENT];
		ASSIGN(currentMemberName,[memberName text]);
		{
			ANTLRDefAST tmp7_AST = ANTLRnullAST;
			tmp7_AST = [astFactory create:[self LT:1]];
			[astFactory addASTChild:tmp7_AST in:currentAST];
		}
		[self matchTokenType:GSWPageDefTokenType_ASSIGN];
		{
			[self mvalue];
			[astFactory addASTChild:returnAST in:currentAST];
		}
		{
			do
			{
				if (([self LA:1]==GSWPageDefTokenType_SEMI))
				{
					{
						ANTLRDefAST tmp8_AST = ANTLRnullAST;
						tmp8_AST = [astFactory create:[self LT:1]];
						[astFactory addASTChild:tmp8_AST in:currentAST];
					}
					[self matchTokenType:GSWPageDefTokenType_SEMI];
				}
				else
				{
					goto _loop21;
				}
				
			} while (YES);
			_loop21:;
		}
		member_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_3];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,member_AST);
	//LOGObjectFnStop();
}

-(void) mvalue
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST mvalue_AST = ANTLRnullAST;
	ANTLRDefAST assocKeyPath_AST = ANTLRnullAST;
	ANTLRDefToken  assocConstantInt = nil;
	ANTLRDefAST assocConstantInt_AST = ANTLRnullAST;
	ANTLRDefToken  assocConstantString = nil;
	ANTLRDefAST assocConstantString_AST = ANTLRnullAST;
	ANTLRDefToken  assocConstantHexNum = nil;
	ANTLRDefAST assocConstantHexNum_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			switch ( [self LA:1])
			{
			case GSWPageDefTokenType_IDENT:
			case GSWPageDefTokenType_CIRC:
			case GSWPageDefTokenType_TILDE:
			{
				[self idref];
				assocKeyPath_AST = returnAST;
				[astFactory addASTChild:returnAST in:currentAST];
				{ GSWAssociation* assoc=[GSWAssociation associationWithKeyPath:[assocKeyPath_AST toStringListWithSiblingSeparator:@"" openSeparator:@"" closeSeparator:@""]];
								 ASSIGN(currentAssociation,assoc); };
				break;
			}
			case GSWPageDefTokenType_INT:
			{
				assocConstantInt = [self LT:1];
				{
					assocConstantInt_AST = [astFactory create:assocConstantInt];
					[astFactory addASTChild:assocConstantInt_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_INT];
				{ GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber valueFromString:[assocConstantInt text]]];
								 ASSIGN(currentAssociation,assoc); };
				break;
			}
			case GSWPageDefTokenType_YES:
			{
				{
					ANTLRDefAST tmp9_AST = ANTLRnullAST;
					tmp9_AST = [astFactory create:[self LT:1]];
					[astFactory addASTChild:tmp9_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_YES];
				{ GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber numberWithBool:YES]];
								 ASSIGN(currentAssociation,assoc); };
				break;
			}
			case GSWPageDefTokenType_NO:
			{
				{
					ANTLRDefAST tmp10_AST = ANTLRnullAST;
					tmp10_AST = [astFactory create:[self LT:1]];
					[astFactory addASTChild:tmp10_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_NO];
				{ GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber numberWithBool:NO]];
								 ASSIGN(currentAssociation,assoc); };
				break;
			}
			case GSWPageDefTokenType_STRING:
			{
				assocConstantString = [self LT:1];
				{
					assocConstantString_AST = [astFactory create:assocConstantString];
					[astFactory addASTChild:assocConstantString_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_STRING];
				{ GSWAssociation* assoc=[GSWAssociation associationWithValue:[self unescapedString:[[[assocConstantString text] stringWithoutPrefix:@"\""] stringWithoutSuffix:@"\""]]];
								ASSIGN(currentAssociation,assoc); };
				break;
			}
			case GSWPageDefTokenType_HEXNUM:
			{
				assocConstantHexNum = [self LT:1];
				{
					assocConstantHexNum_AST = [astFactory create:assocConstantHexNum];
					[astFactory addASTChild:assocConstantHexNum_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_HEXNUM];
				{ GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber valueFromString:[assocConstantHexNum text]]];
								ASSIGN(currentAssociation,assoc); };
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
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_4];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,mvalue_AST);
	//LOGObjectFnStop();
}

-(void) idref
{
	
	ANTLRASTPair* currentAST=[[ANTLRASTPair new] autorelease];
	ANTLRDefAST idref_AST = ANTLRnullAST;
	
	//LOGObjectFnStart();
	ASSIGN(returnAST,ANTLRnullAST);
	NS_DURING      // for error handling
	{
		{
			switch ( [self LA:1])
			{
			case GSWPageDefTokenType_CIRC:
			{
				{
					ANTLRDefAST tmp11_AST = ANTLRnullAST;
					tmp11_AST = [astFactory create:[self LT:1]];
					[astFactory addASTChild:tmp11_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_CIRC];
				break;
			}
			case GSWPageDefTokenType_TILDE:
			{
				{
					ANTLRDefAST tmp12_AST = ANTLRnullAST;
					tmp12_AST = [astFactory create:[self LT:1]];
					[astFactory addASTChild:tmp12_AST in:currentAST];
				}
				[self matchTokenType:GSWPageDefTokenType_TILDE];
				break;
			}
			case GSWPageDefTokenType_IDENT:
			{
				break;
			}
			default:
			{
				[ANTLRNoViableAltException raiseWithToken:[self LT:1]];
			}
			}
		}
		{
			{
				ANTLRDefAST tmp13_AST = ANTLRnullAST;
				tmp13_AST = [astFactory create:[self LT:1]];
				[astFactory addASTChild:tmp13_AST in:currentAST];
			}
			[self matchTokenType:GSWPageDefTokenType_IDENT];
		}
		{
			do
			{
				if (([self LA:1]==GSWPageDefTokenType_PIDENT))
				{
					{
						ANTLRDefAST tmp14_AST = ANTLRnullAST;
						tmp14_AST = [astFactory create:[self LT:1]];
						[astFactory addASTChild:tmp14_AST in:currentAST];
					}
					[self matchTokenType:GSWPageDefTokenType_PIDENT];
				}
				else
				{
					goto _loop28;
				}
				
			} while (YES);
			_loop28:;
		}
		idref_AST = [currentAST root];
	}
	NS_HANDLER
	{
		[self reportErrorWithException:localException];
		[self consume];
		[self consumeUntilTokenBitSet:GSWPageDefParser___tokenSet_4];
	}
	NS_ENDHANDLER;
	ASSIGN(returnAST,idref_AST);
	//LOGObjectFnStop();
}

static CONST NSString* GSWPageDefParser___tokenNames[] = {
	@"<0>",
	@"EOF",
	@"<2>",
	@"NULL_TREE_LOOKAHEAD",
	@"INCLUDE",
	@"WS",
	@"STRING",
	@"IDENT",
	@"COLUMN",
	@"LCURLY",
	@"RCURLY",
	@"SEMI",
	@"ASSIGN",
	@"INT",
	@"YES",
	@"NO",
	@"HEXNUM",
	@"CIRC",
	@"TILDE",
	@"PIDENT",
	@"SL_COMMENT",
	@"ML_COMMENT",
	@"POINT",
	@"ESC",
	@"HEXINT",
	@"DIGIT",
	@"HEXDIGIT",
	@"LCLETTER",
	@"LETTER",
0
};

CONST unsigned long GSWPageDefParser___tokenSet_0_data_[] = { 2UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefParser___tokenSet_0=nil;
CONST unsigned long GSWPageDefParser___tokenSet_1_data_[] = { 146UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefParser___tokenSet_1=nil;
CONST unsigned long GSWPageDefParser___tokenSet_2_data_[] = { 512UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefParser___tokenSet_2=nil;
CONST unsigned long GSWPageDefParser___tokenSet_3_data_[] = { 1152UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefParser___tokenSet_3=nil;
CONST unsigned long GSWPageDefParser___tokenSet_4_data_[] = { 3200UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefParser___tokenSet_4=nil;
+(void)initialize
{
	if (!GSWPageDefParser___tokenSet_0)
		GSWPageDefParser___tokenSet_0=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefParser___tokenSet_0_data_ length:8] retain];
	if (!GSWPageDefParser___tokenSet_1)
		GSWPageDefParser___tokenSet_1=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefParser___tokenSet_1_data_ length:8] retain];
	if (!GSWPageDefParser___tokenSet_2)
		GSWPageDefParser___tokenSet_2=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefParser___tokenSet_2_data_ length:8] retain];
	if (!GSWPageDefParser___tokenSet_3)
		GSWPageDefParser___tokenSet_3=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefParser___tokenSet_3_data_ length:8] retain];
	if (!GSWPageDefParser___tokenSet_4)
		GSWPageDefParser___tokenSet_4=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefParser___tokenSet_4_data_ length:8] retain];
}
+(void)dealloc
{
	DESTROY(GSWPageDefParser___tokenSet_0);
	DESTROY(GSWPageDefParser___tokenSet_1);
	DESTROY(GSWPageDefParser___tokenSet_2);
	DESTROY(GSWPageDefParser___tokenSet_3);
	DESTROY(GSWPageDefParser___tokenSet_4);
	[[self superclass] dealloc];
}
@end


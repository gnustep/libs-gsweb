/*
 * ANTLR-generated file resulting from grammar htmltag.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.5.0; 1996,1997,1998,1999
 */


#include <gsweb/GSWeb.framework/GSWeb.h>

#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRException.h"
#include "GSWHTMLAttrLexer.h"
#include "GSWHTMLAttrTokenTypes.h"


@implementation GSWHTMLAttrLexer
-(id)initWithTextStream:(ANTLRDefTextInputStream)_in
{
	//LOGObjectFnStart();
	self=[super initWithTextStream:_in];
	[self setCaseSensitive:YES];
	[self initLiterals];
	//LOGObjectFnStop();
	return self;
}

-(id)initWithCharBuffer:(ANTLRCharBuffer*)_buffer
{
	//LOGObjectFnStart();
	self=[super initWithCharBuffer:_buffer];
	[self setCaseSensitive:YES];
	[self initLiterals];
	//LOGObjectFnStop();
	return self;
}

-(void)initLiterals
{
	//LOGObjectFnStart();
	//LOGObjectFnStop();
}
-(BOOL)getCaseSensitiveLiterals
{
	return YES;
}

-(ANTLRDefToken) nextToken
{
	ANTLRDefToken _rettoken=nil;
	BOOL end=NO;
	//LOGObjectFnStart();
	for (;!end;)
	{
		ANTLRDefToken _rettoken;
		ANTLRTokenType _ttype = ANTLRToken_INVALID_TYPE;
		[self resetText];
		NS_DURING   // for error handling
		{
			switch ( [self LA:1])
			{
			case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):  case ((unichar)('D')):
			case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):  case ((unichar)('H')):
			case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):  case ((unichar)('L')):
			case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):  case ((unichar)('P')):
			case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):  case ((unichar)('T')):
			case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):  case ((unichar)('X')):
			case ((unichar)('Y')):  case ((unichar)('Z')):  case ((unichar)('_')):  case ((unichar)('a')):
			case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):  case ((unichar)('e')):
			case ((unichar)('f')):  case ((unichar)('g')):  case ((unichar)('h')):  case ((unichar)('i')):
			case ((unichar)('j')):  case ((unichar)('k')):  case ((unichar)('l')):  case ((unichar)('m')):
			case ((unichar)('n')):  case ((unichar)('o')):  case ((unichar)('p')):  case ((unichar)('q')):
			case ((unichar)('r')):  case ((unichar)('s')):  case ((unichar)('t')):  case ((unichar)('u')):
			case ((unichar)('v')):  case ((unichar)('w')):  case ((unichar)('x')):  case ((unichar)('y')):
			case ((unichar)('z')):
			{
				[self mIDENTWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('=')):
			{
				[self mASSIGNWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('\t')):  case ((unichar)('\n')):  case ((unichar)('\r')):  case ((unichar)(' ')):
			{
				[self mWSWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('"')):  case ((unichar)('\'')):
			{
				[self mSTRINGWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('.')):
			{
				[self mPOINTWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('#')):
			{
				[self mHEXNUMWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			default:
				if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))) && ([GSWHTMLAttrLexer___tokenSet_0 isMember:[self LA:2]]))
				{
					[self mPCINTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))))
				{
					[self mINTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
			else
			{
				if ([self LA:1]!=ANTLR_EOF_CHAR) [ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
[self setReturnToken:[self makeToken:ANTLRToken_EOF_TYPE]];
			}
			}
			_ttype = [_returnToken tokenType];
			_ttype = [self testLiteralsTable:_ttype];
			if ( _ttype!=ANTLRToken_SKIP )
			{
				[_returnToken setTokenType:_ttype];
				end=YES;
			}
		}
		NS_HANDLER
		{
			[self consume];
			[self reportErrorWithException:localException];
		}
		NS_ENDHANDLER;
	}
	//LOGObjectFnStop();
	return _returnToken;
}

-(void) mIDENTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_IDENT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		switch ( [self LA:1])
		{
		case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):  case ((unichar)('D')):
		case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):  case ((unichar)('H')):
		case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):  case ((unichar)('L')):
		case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):  case ((unichar)('P')):
		case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):  case ((unichar)('T')):
		case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):  case ((unichar)('X')):
		case ((unichar)('Y')):  case ((unichar)('Z')):  case ((unichar)('a')):  case ((unichar)('b')):
		case ((unichar)('c')):  case ((unichar)('d')):  case ((unichar)('e')):  case ((unichar)('f')):
		case ((unichar)('g')):  case ((unichar)('h')):  case ((unichar)('i')):  case ((unichar)('j')):
		case ((unichar)('k')):  case ((unichar)('l')):  case ((unichar)('m')):  case ((unichar)('n')):
		case ((unichar)('o')):  case ((unichar)('p')):  case ((unichar)('q')):  case ((unichar)('r')):
		case ((unichar)('s')):  case ((unichar)('t')):  case ((unichar)('u')):  case ((unichar)('v')):
		case ((unichar)('w')):  case ((unichar)('x')):  case ((unichar)('y')):  case ((unichar)('z')):
		{
			[self mLETTERWithCreateToken:NO];
			break;
		}
		case ((unichar)('_')):
		{
			[self matchCharacter:'_'];
			break;
		}
		default:
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		}
	}
	{
		do
		{
			switch ( [self LA:1])
			{
			case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):  case ((unichar)('D')):
			case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):  case ((unichar)('H')):
			case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):  case ((unichar)('L')):
			case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):  case ((unichar)('P')):
			case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):  case ((unichar)('T')):
			case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):  case ((unichar)('X')):
			case ((unichar)('Y')):  case ((unichar)('Z')):  case ((unichar)('a')):  case ((unichar)('b')):
			case ((unichar)('c')):  case ((unichar)('d')):  case ((unichar)('e')):  case ((unichar)('f')):
			case ((unichar)('g')):  case ((unichar)('h')):  case ((unichar)('i')):  case ((unichar)('j')):
			case ((unichar)('k')):  case ((unichar)('l')):  case ((unichar)('m')):  case ((unichar)('n')):
			case ((unichar)('o')):  case ((unichar)('p')):  case ((unichar)('q')):  case ((unichar)('r')):
			case ((unichar)('s')):  case ((unichar)('t')):  case ((unichar)('u')):  case ((unichar)('v')):
			case ((unichar)('w')):  case ((unichar)('x')):  case ((unichar)('y')):  case ((unichar)('z')):
			{
				[self mLETTERWithCreateToken:NO];
				break;
			}
			case ((unichar)('_')):
			{
				[self matchCharacter:'_'];
				break;
			}
			case ((unichar)('-')):
			{
				[self matchCharacter:'-'];
				break;
			}
			case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
			case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
			case ((unichar)('8')):  case ((unichar)('9')):
			{
				[self mDIGITWithCreateToken:NO];
				break;
			}
			default:
			{
				goto _loop22;
			}
			}
		} while (YES);
		_loop22:;
	}
	_ttype = [self testLiteralsTable:_ttype];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mLETTERWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_LETTER;
	int _saveIndex;
	
	//LOGObjectFnStart();
	switch ( [self LA:1])
	{
	case ((unichar)('a')):  case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):
	case ((unichar)('e')):  case ((unichar)('f')):  case ((unichar)('g')):  case ((unichar)('h')):
	case ((unichar)('i')):  case ((unichar)('j')):  case ((unichar)('k')):  case ((unichar)('l')):
	case ((unichar)('m')):  case ((unichar)('n')):  case ((unichar)('o')):  case ((unichar)('p')):
	case ((unichar)('q')):  case ((unichar)('r')):  case ((unichar)('s')):  case ((unichar)('t')):
	case ((unichar)('u')):  case ((unichar)('v')):  case ((unichar)('w')):  case ((unichar)('x')):
	case ((unichar)('y')):  case ((unichar)('z')):
	{
		[self matchRange:'a' :'z'];
		break;
	}
	case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):  case ((unichar)('D')):
	case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):  case ((unichar)('H')):
	case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):  case ((unichar)('L')):
	case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):  case ((unichar)('P')):
	case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):  case ((unichar)('T')):
	case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):  case ((unichar)('X')):
	case ((unichar)('Y')):  case ((unichar)('Z')):
	{
		[self matchRange:'A' :'Z'];
		break;
	}
	default:
	{
		[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
	}
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mDIGITWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_DIGIT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchRange:'0' :'9'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mASSIGNWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_ASSIGN;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'='];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mWSWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_WS;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		switch ( [self LA:1])
		{
		case ((unichar)(' ')):
		{
			[self matchCharacter:' '];
			break;
		}
		case ((unichar)('\t')):
		{
			[self matchCharacter:'\t'];
			break;
		}
		case ((unichar)('\n')):
		{
			[self matchCharacter:'\n'];
			break;
		}
		default:
			if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))))
			{
				[self matchString:@"\r\n"];
			}
			else if (([self LA:1]==((unichar)('\r'))))
			{
				[self matchCharacter:'\r'];
			}
		else
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		}
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mSTRINGWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_STRING;
	int _saveIndex;
	
	//LOGObjectFnStart();
	switch ( [self LA:1])
	{
	case ((unichar)('"')):
	{
		[self matchCharacter:'"'];
		{
			do
			{
				if (([GSWHTMLAttrLexer___tokenSet_1 isMember:[self LA:1]]))
				{
					[self matchNotCharacter:'"'];
				}
				else
				{
					goto _loop28;
				}
				
			} while (YES);
			_loop28:;
		}
		[self matchCharacter:'"'];
		break;
	}
	case ((unichar)('\'')):
	{
		[self matchCharacter:'\''];
		{
			do
			{
				if (([GSWHTMLAttrLexer___tokenSet_2 isMember:[self LA:1]]))
				{
					[self matchNotCharacter:'\''];
				}
				else
				{
					goto _loop30;
				}
				
			} while (YES);
			_loop30:;
		}
		[self matchCharacter:'\''];
		break;
	}
	default:
	{
		[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
	}
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mPOINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_POINT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'.'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_INT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt34=0;
		do
		{
			if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))))
			{
				[self mDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt34>=1 ) { goto _loop34; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt34++;
		} while (YES);
		_loop34:;
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mPCINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_PCINT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt37=0;
		do
		{
			if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))))
			{
				[self mDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt37>=1 ) { goto _loop37; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt37++;
		} while (YES);
		_loop37:;
	}
	[self matchCharacter:'%'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mHEXNUMWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_HEXNUM;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'#'];
	[self mHEXINTWithCreateToken:NO];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mHEXINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_HEXINT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt41=0;
		do
		{
			if (([GSWHTMLAttrLexer___tokenSet_3 isMember:[self LA:1]]))
			{
				[self mHEXDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt41>=1 ) { goto _loop41; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt41++;
		} while (YES);
		_loop41:;
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mHEXDIGITWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_HEXDIGIT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	switch ( [self LA:1])
	{
	case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
	case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
	case ((unichar)('8')):  case ((unichar)('9')):
	{
		[self matchRange:'0' :'9'];
		break;
	}
	case ((unichar)('a')):  case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):
	case ((unichar)('e')):  case ((unichar)('f')):
	{
		[self matchRange:'a' :'f'];
		break;
	}
	default:
	{
		[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
	}
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mLCLETTERWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLAttrTokenType_LCLETTER;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchRange:'a' :'z'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}


CONST unsigned long GSWHTMLAttrLexer___tokenSet_0_data_[] = { 0UL, 67043360UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_0=nil;
CONST unsigned long GSWHTMLAttrLexer___tokenSet_1_data_[] = { 4294967288UL, 4294967291UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_1=nil;
CONST unsigned long GSWHTMLAttrLexer___tokenSet_2_data_[] = { 4294967288UL, 4294967167UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_2=nil;
CONST unsigned long GSWHTMLAttrLexer___tokenSet_3_data_[] = { 0UL, 67043328UL, 0UL, 126UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLAttrLexer___tokenSet_3=nil;
+(void)initialize
{
	if (!GSWHTMLAttrLexer___tokenSet_0)
		GSWHTMLAttrLexer___tokenSet_0=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrLexer___tokenSet_0_data_ length:20] retain];
	if (!GSWHTMLAttrLexer___tokenSet_1)
		GSWHTMLAttrLexer___tokenSet_1=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrLexer___tokenSet_1_data_ length:32] retain];
	if (!GSWHTMLAttrLexer___tokenSet_2)
		GSWHTMLAttrLexer___tokenSet_2=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrLexer___tokenSet_2_data_ length:32] retain];
	if (!GSWHTMLAttrLexer___tokenSet_3)
		GSWHTMLAttrLexer___tokenSet_3=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLAttrLexer___tokenSet_3_data_ length:20] retain];
}
+(void)dealloc
{
	DESTROY(GSWHTMLAttrLexer___tokenSet_0);
	DESTROY(GSWHTMLAttrLexer___tokenSet_1);
	DESTROY(GSWHTMLAttrLexer___tokenSet_2);
	DESTROY(GSWHTMLAttrLexer___tokenSet_3);
	[[self superclass] dealloc];
}
@end


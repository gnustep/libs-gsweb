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
#include "gsantlr/ANTLRException.h"
#include "GSWPageDefLexer.h"
#include "GSWPageDefParserTokenTypes.h"


@implementation GSWPageDefLexer
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
			case ((unichar)('"')):  case ((unichar)('\'')):
			{
				[self mSTRINGWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
			case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
			case ((unichar)('8')):  case ((unichar)('9')):
			{
				[self mINTWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('{')):
			{
				[self mLCURLYWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('}')):
			{
				[self mRCURLYWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)(';')):
			{
				[self mSEMIWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('^')):
			{
				[self mCIRCWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('~')):
			{
				[self mTILDEWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)(':')):
			{
				[self mCOLUMNWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('=')):
			{
				[self mASSIGNWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('?')):
			{
				[self mQUESTIONMARKWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			case ((unichar)('\t')):  case ((unichar)('\n')):  case ((unichar)('\r')):  case ((unichar)(' ')):
			{
				[self mWSWithCreateToken:YES];
				_rettoken=_returnToken;
				break;
			}
			default:
				if (([self LA:1]==((unichar)('Y'))) && ([self LA:2]==((unichar)('E'))) && ([self LA:3]==((unichar)('S'))))
				{
					[self mYESWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('/'))) && ([self LA:2]==((unichar)('/'))))
				{
					[self mSL_COMMENTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('/'))) && ([self LA:2]==((unichar)('*'))))
				{
					[self mML_COMMENTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('#'))) && ([self LA:2]==((unichar)('i'))))
				{
					[self mINCLUDEWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('.'))) && ([GSWPageDefLexer___tokenSet_0 isMember:[self LA:2]]))
				{
					[self mPIDENTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('.'))) && ([GSWPageDefLexer___tokenSet_1 isMember:[self LA:2]]))
				{
					[self mPIDENTREFWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('N'))) && ([self LA:2]==((unichar)('O'))))
				{
					[self mNOWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('#'))) && ([GSWPageDefLexer___tokenSet_2 isMember:[self LA:2]]))
				{
					[self mHEXNUMWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([GSWPageDefLexer___tokenSet_3 isMember:[self LA:1]]))
				{
					[self mIDENTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([self LA:1]==((unichar)('.'))))
				{
					[self mPOINTWithCreateToken:YES];
					_rettoken=_returnToken;
				}
				else if (([GSWPageDefLexer___tokenSet_4 isMember:[self LA:1]]))
				{
					[self mIDENTREFWithCreateToken:YES];
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

-(void) mSL_COMMENTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_SL_COMMENT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"//"];
	{
		do
		{
			if (([GSWPageDefLexer___tokenSet_5 isMember:[self LA:1]]))
			{
				{
					[self matchCharSet:GSWPageDefLexer___tokenSet_5];
				}
			}
			else
			{
				goto _loop35;
			}
			
		} while (YES);
		_loop35:;
	}
	{
		switch ( [self LA:1])
		{
		case ((unichar)('\n')):
		{
			[self matchCharacter:'\n'];
			break;
		}
		case ((unichar)('\r')):
		{
			[self matchCharacter:'\r'];
			{
				if (([self LA:1]==((unichar)('\n'))))
				{
					[self matchCharacter:'\n'];
				}
				else
				{
				}
				
			}
			break;
		}
		default:
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		}
	}
	_ttype = ANTLRToken_SKIP; [self newline];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mML_COMMENTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_ML_COMMENT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"/*"];
	{
		do
		{
			switch ( [self LA:1])
			{
			case ((unichar)('\n')):
			{
				[self matchCharacter:'\n'];
				[self newline];
				break;
			}
			case ((unichar)(0x3)):  case ((unichar)(0x4)):  case ((unichar)(0x5)):  case ((unichar)(0x6)):
			case ((unichar)(0x7)):  case ((unichar)(0x8)):  case ((unichar)('\t')):  case ((unichar)(0xb)):
			case ((unichar)(0xc)):  case ((unichar)(0xe)):  case ((unichar)(0xf)):  case ((unichar)(0x10)):
			case ((unichar)(0x11)):  case ((unichar)(0x12)):  case ((unichar)(0x13)):  case ((unichar)(0x14)):
			case ((unichar)(0x15)):  case ((unichar)(0x16)):  case ((unichar)(0x17)):  case ((unichar)(0x18)):
			case ((unichar)(0x19)):  case ((unichar)(0x1a)):  case ((unichar)(0x1b)):  case ((unichar)(0x1c)):
			case ((unichar)(0x1d)):  case ((unichar)(0x1e)):  case ((unichar)(0x1f)):  case ((unichar)(' ')):
			case ((unichar)('!')):  case ((unichar)('"')):  case ((unichar)('#')):  case ((unichar)('$')):
			case ((unichar)('%')):  case ((unichar)('&')):  case ((unichar)('\'')):  case ((unichar)('(')):
			case ((unichar)(')')):  case ((unichar)('+')):  case ((unichar)(',')):  case ((unichar)('-')):
			case ((unichar)('.')):  case ((unichar)('/')):  case ((unichar)('0')):  case ((unichar)('1')):
			case ((unichar)('2')):  case ((unichar)('3')):  case ((unichar)('4')):  case ((unichar)('5')):
			case ((unichar)('6')):  case ((unichar)('7')):  case ((unichar)('8')):  case ((unichar)('9')):
			case ((unichar)(':')):  case ((unichar)(';')):  case ((unichar)('<')):  case ((unichar)('=')):
			case ((unichar)('>')):  case ((unichar)('?')):  case ((unichar)('@')):  case ((unichar)('A')):
			case ((unichar)('B')):  case ((unichar)('C')):  case ((unichar)('D')):  case ((unichar)('E')):
			case ((unichar)('F')):  case ((unichar)('G')):  case ((unichar)('H')):  case ((unichar)('I')):
			case ((unichar)('J')):  case ((unichar)('K')):  case ((unichar)('L')):  case ((unichar)('M')):
			case ((unichar)('N')):  case ((unichar)('O')):  case ((unichar)('P')):  case ((unichar)('Q')):
			case ((unichar)('R')):  case ((unichar)('S')):  case ((unichar)('T')):  case ((unichar)('U')):
			case ((unichar)('V')):  case ((unichar)('W')):  case ((unichar)('X')):  case ((unichar)('Y')):
			case ((unichar)('Z')):  case ((unichar)('[')):  case ((unichar)('\\')):  case ((unichar)(']')):
			case ((unichar)('^')):  case ((unichar)('_')):  case ((unichar)('`')):  case ((unichar)('a')):
			case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):  case ((unichar)('e')):
			case ((unichar)('f')):  case ((unichar)('g')):  case ((unichar)('h')):  case ((unichar)('i')):
			case ((unichar)('j')):  case ((unichar)('k')):  case ((unichar)('l')):  case ((unichar)('m')):
			case ((unichar)('n')):  case ((unichar)('o')):  case ((unichar)('p')):  case ((unichar)('q')):
			case ((unichar)('r')):  case ((unichar)('s')):  case ((unichar)('t')):  case ((unichar)('u')):
			case ((unichar)('v')):  case ((unichar)('w')):  case ((unichar)('x')):  case ((unichar)('y')):
			case ((unichar)('z')):  case ((unichar)('{')):  case ((unichar)('|')):  case ((unichar)('}')):
			case ((unichar)('~')):  case ((unichar)(0x7f)):  case ((unichar)(0x80)):  case ((unichar)(0x81)):
			case ((unichar)(0x82)):  case ((unichar)(0x83)):  case ((unichar)(0x84)):  case ((unichar)(0x85)):
			case ((unichar)(0x86)):  case ((unichar)(0x87)):  case ((unichar)(0x88)):  case ((unichar)(0x89)):
			case ((unichar)(0x8a)):  case ((unichar)(0x8b)):  case ((unichar)(0x8c)):  case ((unichar)(0x8d)):
			case ((unichar)(0x8e)):  case ((unichar)(0x8f)):  case ((unichar)(0x90)):  case ((unichar)(0x91)):
			case ((unichar)(0x92)):  case ((unichar)(0x93)):  case ((unichar)(0x94)):  case ((unichar)(0x95)):
			case ((unichar)(0x96)):  case ((unichar)(0x97)):  case ((unichar)(0x98)):  case ((unichar)(0x99)):
			case ((unichar)(0x9a)):  case ((unichar)(0x9b)):  case ((unichar)(0x9c)):  case ((unichar)(0x9d)):
			case ((unichar)(0x9e)):  case ((unichar)(0x9f)):  case ((unichar)(0xa0)):  case ((unichar)(0xa1)):
			case ((unichar)(0xa2)):  case ((unichar)(0xa3)):  case ((unichar)(0xa4)):  case ((unichar)(0xa5)):
			case ((unichar)(0xa6)):  case ((unichar)(0xa7)):  case ((unichar)(0xa8)):  case ((unichar)(0xa9)):
			case ((unichar)(0xaa)):  case ((unichar)(0xab)):  case ((unichar)(0xac)):  case ((unichar)(0xad)):
			case ((unichar)(0xae)):  case ((unichar)(0xaf)):  case ((unichar)(0xb0)):  case ((unichar)(0xb1)):
			case ((unichar)(0xb2)):  case ((unichar)(0xb3)):  case ((unichar)(0xb4)):  case ((unichar)(0xb5)):
			case ((unichar)(0xb6)):  case ((unichar)(0xb7)):  case ((unichar)(0xb8)):  case ((unichar)(0xb9)):
			case ((unichar)(0xba)):  case ((unichar)(0xbb)):  case ((unichar)(0xbc)):  case ((unichar)(0xbd)):
			case ((unichar)(0xbe)):  case ((unichar)(0xbf)):  case ((unichar)(0xc0)):  case ((unichar)(0xc1)):
			case ((unichar)(0xc2)):  case ((unichar)(0xc3)):  case ((unichar)(0xc4)):  case ((unichar)(0xc5)):
			case ((unichar)(0xc6)):  case ((unichar)(0xc7)):  case ((unichar)(0xc8)):  case ((unichar)(0xc9)):
			case ((unichar)(0xca)):  case ((unichar)(0xcb)):  case ((unichar)(0xcc)):  case ((unichar)(0xcd)):
			case ((unichar)(0xce)):  case ((unichar)(0xcf)):  case ((unichar)(0xd0)):  case ((unichar)(0xd1)):
			case ((unichar)(0xd2)):  case ((unichar)(0xd3)):  case ((unichar)(0xd4)):  case ((unichar)(0xd5)):
			case ((unichar)(0xd6)):  case ((unichar)(0xd7)):  case ((unichar)(0xd8)):  case ((unichar)(0xd9)):
			case ((unichar)(0xda)):  case ((unichar)(0xdb)):  case ((unichar)(0xdc)):  case ((unichar)(0xdd)):
			case ((unichar)(0xde)):  case ((unichar)(0xdf)):  case ((unichar)(0xe0)):  case ((unichar)(0xe1)):
			case ((unichar)(0xe2)):  case ((unichar)(0xe3)):  case ((unichar)(0xe4)):  case ((unichar)(0xe5)):
			case ((unichar)(0xe6)):  case ((unichar)(0xe7)):  case ((unichar)(0xe8)):  case ((unichar)(0xe9)):
			case ((unichar)(0xea)):  case ((unichar)(0xeb)):  case ((unichar)(0xec)):  case ((unichar)(0xed)):
			case ((unichar)(0xee)):  case ((unichar)(0xef)):  case ((unichar)(0xf0)):  case ((unichar)(0xf1)):
			case ((unichar)(0xf2)):  case ((unichar)(0xf3)):  case ((unichar)(0xf4)):  case ((unichar)(0xf5)):
			case ((unichar)(0xf6)):  case ((unichar)(0xf7)):  case ((unichar)(0xf8)):  case ((unichar)(0xf9)):
			case ((unichar)(0xfa)):  case ((unichar)(0xfb)):  case ((unichar)(0xfc)):  case ((unichar)(0xfd)):
			case ((unichar)(0xfe)):  case ((unichar)(0xff)):
			{
				{
					[self matchCharSet:GSWPageDefLexer___tokenSet_6];
				}
				break;
			}
			default:
				if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))) && (([self LA:4] >= ((unichar)(0x3)) && [self LA:4] <= ((unichar)(0xff)))))
				{
					[self matchCharacter:'\r'];
					[self matchCharacter:'\n'];
					[self newline];
				}
				else if ((([self LA:1]==((unichar)('*'))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))&&( [self LA:2]!='/' ))
				{
					[self matchCharacter:'*'];
				}
				else if (([self LA:1]==((unichar)('\r'))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))
				{
					[self matchCharacter:'\r'];
					[self newline];
				}
			else
			{
				goto _loop41;
			}
			}
		} while (YES);
		_loop41:;
	}
	[self matchString:@"*/"];
	_ttype = ANTLRToken_SKIP;
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mINCLUDEWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_INCLUDE;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"#include"];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mIDENTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_IDENT;
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
			case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
			case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
			case ((unichar)('8')):  case ((unichar)('9')):
			{
				[self mDIGITWithCreateToken:NO];
				break;
			}
			default:
			{
				goto _loop46;
			}
			}
		} while (YES);
		_loop46:;
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_LETTER;
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_DIGIT;
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

-(void) mPIDENTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_PIDENT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self mPOINTWithCreateToken:NO];
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
			[self mIDENTWithCreateToken:NO];
			break;
		}
		case ((unichar)('"')):  case ((unichar)('\'')):
		{
			[self mSTRINGWithCreateToken:NO];
			break;
		}
		default:
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		}
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

-(void) mPOINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_POINT;
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

-(void) mSTRINGWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_STRING;
	int _saveIndex;
	
	//LOGObjectFnStart();
	switch ( [self LA:1])
	{
	case ((unichar)('\'')):
	{
		[self matchCharacter:'\''];
		{
			do
			{
				switch ( [self LA:1])
				{
				case ((unichar)('\\')):
				{
					[self mESCWithCreateToken:NO];
					break;
				}
				case ((unichar)(0x3)):  case ((unichar)(0x4)):  case ((unichar)(0x5)):  case ((unichar)(0x6)):
				case ((unichar)(0x7)):  case ((unichar)(0x8)):  case ((unichar)('\t')):  case ((unichar)('\n')):
				case ((unichar)(0xb)):  case ((unichar)(0xc)):  case ((unichar)('\r')):  case ((unichar)(0xe)):
				case ((unichar)(0xf)):  case ((unichar)(0x10)):  case ((unichar)(0x11)):  case ((unichar)(0x12)):
				case ((unichar)(0x13)):  case ((unichar)(0x14)):  case ((unichar)(0x15)):  case ((unichar)(0x16)):
				case ((unichar)(0x17)):  case ((unichar)(0x18)):  case ((unichar)(0x19)):  case ((unichar)(0x1a)):
				case ((unichar)(0x1b)):  case ((unichar)(0x1c)):  case ((unichar)(0x1d)):  case ((unichar)(0x1e)):
				case ((unichar)(0x1f)):  case ((unichar)(' ')):  case ((unichar)('!')):  case ((unichar)('"')):
				case ((unichar)('#')):  case ((unichar)('$')):  case ((unichar)('%')):  case ((unichar)('&')):
				case ((unichar)('(')):  case ((unichar)(')')):  case ((unichar)('*')):  case ((unichar)('+')):
				case ((unichar)(',')):  case ((unichar)('-')):  case ((unichar)('.')):  case ((unichar)('/')):
				case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
				case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
				case ((unichar)('8')):  case ((unichar)('9')):  case ((unichar)(':')):  case ((unichar)(';')):
				case ((unichar)('<')):  case ((unichar)('=')):  case ((unichar)('>')):  case ((unichar)('?')):
				case ((unichar)('@')):  case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):
				case ((unichar)('D')):  case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):
				case ((unichar)('H')):  case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):
				case ((unichar)('L')):  case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):
				case ((unichar)('P')):  case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):
				case ((unichar)('T')):  case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):
				case ((unichar)('X')):  case ((unichar)('Y')):  case ((unichar)('Z')):  case ((unichar)('[')):
				case ((unichar)(']')):  case ((unichar)('^')):  case ((unichar)('_')):  case ((unichar)('`')):
				case ((unichar)('a')):  case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):
				case ((unichar)('e')):  case ((unichar)('f')):  case ((unichar)('g')):  case ((unichar)('h')):
				case ((unichar)('i')):  case ((unichar)('j')):  case ((unichar)('k')):  case ((unichar)('l')):
				case ((unichar)('m')):  case ((unichar)('n')):  case ((unichar)('o')):  case ((unichar)('p')):
				case ((unichar)('q')):  case ((unichar)('r')):  case ((unichar)('s')):  case ((unichar)('t')):
				case ((unichar)('u')):  case ((unichar)('v')):  case ((unichar)('w')):  case ((unichar)('x')):
				case ((unichar)('y')):  case ((unichar)('z')):  case ((unichar)('{')):  case ((unichar)('|')):
				case ((unichar)('}')):  case ((unichar)('~')):  case ((unichar)(0x7f)):  case ((unichar)(0x80)):
				case ((unichar)(0x81)):  case ((unichar)(0x82)):  case ((unichar)(0x83)):  case ((unichar)(0x84)):
				case ((unichar)(0x85)):  case ((unichar)(0x86)):  case ((unichar)(0x87)):  case ((unichar)(0x88)):
				case ((unichar)(0x89)):  case ((unichar)(0x8a)):  case ((unichar)(0x8b)):  case ((unichar)(0x8c)):
				case ((unichar)(0x8d)):  case ((unichar)(0x8e)):  case ((unichar)(0x8f)):  case ((unichar)(0x90)):
				case ((unichar)(0x91)):  case ((unichar)(0x92)):  case ((unichar)(0x93)):  case ((unichar)(0x94)):
				case ((unichar)(0x95)):  case ((unichar)(0x96)):  case ((unichar)(0x97)):  case ((unichar)(0x98)):
				case ((unichar)(0x99)):  case ((unichar)(0x9a)):  case ((unichar)(0x9b)):  case ((unichar)(0x9c)):
				case ((unichar)(0x9d)):  case ((unichar)(0x9e)):  case ((unichar)(0x9f)):  case ((unichar)(0xa0)):
				case ((unichar)(0xa1)):  case ((unichar)(0xa2)):  case ((unichar)(0xa3)):  case ((unichar)(0xa4)):
				case ((unichar)(0xa5)):  case ((unichar)(0xa6)):  case ((unichar)(0xa7)):  case ((unichar)(0xa8)):
				case ((unichar)(0xa9)):  case ((unichar)(0xaa)):  case ((unichar)(0xab)):  case ((unichar)(0xac)):
				case ((unichar)(0xad)):  case ((unichar)(0xae)):  case ((unichar)(0xaf)):  case ((unichar)(0xb0)):
				case ((unichar)(0xb1)):  case ((unichar)(0xb2)):  case ((unichar)(0xb3)):  case ((unichar)(0xb4)):
				case ((unichar)(0xb5)):  case ((unichar)(0xb6)):  case ((unichar)(0xb7)):  case ((unichar)(0xb8)):
				case ((unichar)(0xb9)):  case ((unichar)(0xba)):  case ((unichar)(0xbb)):  case ((unichar)(0xbc)):
				case ((unichar)(0xbd)):  case ((unichar)(0xbe)):  case ((unichar)(0xbf)):  case ((unichar)(0xc0)):
				case ((unichar)(0xc1)):  case ((unichar)(0xc2)):  case ((unichar)(0xc3)):  case ((unichar)(0xc4)):
				case ((unichar)(0xc5)):  case ((unichar)(0xc6)):  case ((unichar)(0xc7)):  case ((unichar)(0xc8)):
				case ((unichar)(0xc9)):  case ((unichar)(0xca)):  case ((unichar)(0xcb)):  case ((unichar)(0xcc)):
				case ((unichar)(0xcd)):  case ((unichar)(0xce)):  case ((unichar)(0xcf)):  case ((unichar)(0xd0)):
				case ((unichar)(0xd1)):  case ((unichar)(0xd2)):  case ((unichar)(0xd3)):  case ((unichar)(0xd4)):
				case ((unichar)(0xd5)):  case ((unichar)(0xd6)):  case ((unichar)(0xd7)):  case ((unichar)(0xd8)):
				case ((unichar)(0xd9)):  case ((unichar)(0xda)):  case ((unichar)(0xdb)):  case ((unichar)(0xdc)):
				case ((unichar)(0xdd)):  case ((unichar)(0xde)):  case ((unichar)(0xdf)):  case ((unichar)(0xe0)):
				case ((unichar)(0xe1)):  case ((unichar)(0xe2)):  case ((unichar)(0xe3)):  case ((unichar)(0xe4)):
				case ((unichar)(0xe5)):  case ((unichar)(0xe6)):  case ((unichar)(0xe7)):  case ((unichar)(0xe8)):
				case ((unichar)(0xe9)):  case ((unichar)(0xea)):  case ((unichar)(0xeb)):  case ((unichar)(0xec)):
				case ((unichar)(0xed)):  case ((unichar)(0xee)):  case ((unichar)(0xef)):  case ((unichar)(0xf0)):
				case ((unichar)(0xf1)):  case ((unichar)(0xf2)):  case ((unichar)(0xf3)):  case ((unichar)(0xf4)):
				case ((unichar)(0xf5)):  case ((unichar)(0xf6)):  case ((unichar)(0xf7)):  case ((unichar)(0xf8)):
				case ((unichar)(0xf9)):  case ((unichar)(0xfa)):  case ((unichar)(0xfb)):  case ((unichar)(0xfc)):
				case ((unichar)(0xfd)):  case ((unichar)(0xfe)):  case ((unichar)(0xff)):
				{
					{
						[self matchCharSet:GSWPageDefLexer___tokenSet_7];
					}
					break;
				}
				default:
				{
					goto _loop70;
				}
				}
			} while (YES);
			_loop70:;
		}
		[self matchCharacter:'\''];
		break;
	}
	case ((unichar)('"')):
	{
		[self matchCharacter:'"'];
		{
			do
			{
				switch ( [self LA:1])
				{
				case ((unichar)('\\')):
				{
					[self mESCWithCreateToken:NO];
					break;
				}
				case ((unichar)(0x3)):  case ((unichar)(0x4)):  case ((unichar)(0x5)):  case ((unichar)(0x6)):
				case ((unichar)(0x7)):  case ((unichar)(0x8)):  case ((unichar)('\t')):  case ((unichar)('\n')):
				case ((unichar)(0xb)):  case ((unichar)(0xc)):  case ((unichar)('\r')):  case ((unichar)(0xe)):
				case ((unichar)(0xf)):  case ((unichar)(0x10)):  case ((unichar)(0x11)):  case ((unichar)(0x12)):
				case ((unichar)(0x13)):  case ((unichar)(0x14)):  case ((unichar)(0x15)):  case ((unichar)(0x16)):
				case ((unichar)(0x17)):  case ((unichar)(0x18)):  case ((unichar)(0x19)):  case ((unichar)(0x1a)):
				case ((unichar)(0x1b)):  case ((unichar)(0x1c)):  case ((unichar)(0x1d)):  case ((unichar)(0x1e)):
				case ((unichar)(0x1f)):  case ((unichar)(' ')):  case ((unichar)('!')):  case ((unichar)('#')):
				case ((unichar)('$')):  case ((unichar)('%')):  case ((unichar)('&')):  case ((unichar)('\'')):
				case ((unichar)('(')):  case ((unichar)(')')):  case ((unichar)('*')):  case ((unichar)('+')):
				case ((unichar)(',')):  case ((unichar)('-')):  case ((unichar)('.')):  case ((unichar)('/')):
				case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
				case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
				case ((unichar)('8')):  case ((unichar)('9')):  case ((unichar)(':')):  case ((unichar)(';')):
				case ((unichar)('<')):  case ((unichar)('=')):  case ((unichar)('>')):  case ((unichar)('?')):
				case ((unichar)('@')):  case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):
				case ((unichar)('D')):  case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):
				case ((unichar)('H')):  case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):
				case ((unichar)('L')):  case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):
				case ((unichar)('P')):  case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):
				case ((unichar)('T')):  case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):
				case ((unichar)('X')):  case ((unichar)('Y')):  case ((unichar)('Z')):  case ((unichar)('[')):
				case ((unichar)(']')):  case ((unichar)('^')):  case ((unichar)('_')):  case ((unichar)('`')):
				case ((unichar)('a')):  case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):
				case ((unichar)('e')):  case ((unichar)('f')):  case ((unichar)('g')):  case ((unichar)('h')):
				case ((unichar)('i')):  case ((unichar)('j')):  case ((unichar)('k')):  case ((unichar)('l')):
				case ((unichar)('m')):  case ((unichar)('n')):  case ((unichar)('o')):  case ((unichar)('p')):
				case ((unichar)('q')):  case ((unichar)('r')):  case ((unichar)('s')):  case ((unichar)('t')):
				case ((unichar)('u')):  case ((unichar)('v')):  case ((unichar)('w')):  case ((unichar)('x')):
				case ((unichar)('y')):  case ((unichar)('z')):  case ((unichar)('{')):  case ((unichar)('|')):
				case ((unichar)('}')):  case ((unichar)('~')):  case ((unichar)(0x7f)):  case ((unichar)(0x80)):
				case ((unichar)(0x81)):  case ((unichar)(0x82)):  case ((unichar)(0x83)):  case ((unichar)(0x84)):
				case ((unichar)(0x85)):  case ((unichar)(0x86)):  case ((unichar)(0x87)):  case ((unichar)(0x88)):
				case ((unichar)(0x89)):  case ((unichar)(0x8a)):  case ((unichar)(0x8b)):  case ((unichar)(0x8c)):
				case ((unichar)(0x8d)):  case ((unichar)(0x8e)):  case ((unichar)(0x8f)):  case ((unichar)(0x90)):
				case ((unichar)(0x91)):  case ((unichar)(0x92)):  case ((unichar)(0x93)):  case ((unichar)(0x94)):
				case ((unichar)(0x95)):  case ((unichar)(0x96)):  case ((unichar)(0x97)):  case ((unichar)(0x98)):
				case ((unichar)(0x99)):  case ((unichar)(0x9a)):  case ((unichar)(0x9b)):  case ((unichar)(0x9c)):
				case ((unichar)(0x9d)):  case ((unichar)(0x9e)):  case ((unichar)(0x9f)):  case ((unichar)(0xa0)):
				case ((unichar)(0xa1)):  case ((unichar)(0xa2)):  case ((unichar)(0xa3)):  case ((unichar)(0xa4)):
				case ((unichar)(0xa5)):  case ((unichar)(0xa6)):  case ((unichar)(0xa7)):  case ((unichar)(0xa8)):
				case ((unichar)(0xa9)):  case ((unichar)(0xaa)):  case ((unichar)(0xab)):  case ((unichar)(0xac)):
				case ((unichar)(0xad)):  case ((unichar)(0xae)):  case ((unichar)(0xaf)):  case ((unichar)(0xb0)):
				case ((unichar)(0xb1)):  case ((unichar)(0xb2)):  case ((unichar)(0xb3)):  case ((unichar)(0xb4)):
				case ((unichar)(0xb5)):  case ((unichar)(0xb6)):  case ((unichar)(0xb7)):  case ((unichar)(0xb8)):
				case ((unichar)(0xb9)):  case ((unichar)(0xba)):  case ((unichar)(0xbb)):  case ((unichar)(0xbc)):
				case ((unichar)(0xbd)):  case ((unichar)(0xbe)):  case ((unichar)(0xbf)):  case ((unichar)(0xc0)):
				case ((unichar)(0xc1)):  case ((unichar)(0xc2)):  case ((unichar)(0xc3)):  case ((unichar)(0xc4)):
				case ((unichar)(0xc5)):  case ((unichar)(0xc6)):  case ((unichar)(0xc7)):  case ((unichar)(0xc8)):
				case ((unichar)(0xc9)):  case ((unichar)(0xca)):  case ((unichar)(0xcb)):  case ((unichar)(0xcc)):
				case ((unichar)(0xcd)):  case ((unichar)(0xce)):  case ((unichar)(0xcf)):  case ((unichar)(0xd0)):
				case ((unichar)(0xd1)):  case ((unichar)(0xd2)):  case ((unichar)(0xd3)):  case ((unichar)(0xd4)):
				case ((unichar)(0xd5)):  case ((unichar)(0xd6)):  case ((unichar)(0xd7)):  case ((unichar)(0xd8)):
				case ((unichar)(0xd9)):  case ((unichar)(0xda)):  case ((unichar)(0xdb)):  case ((unichar)(0xdc)):
				case ((unichar)(0xdd)):  case ((unichar)(0xde)):  case ((unichar)(0xdf)):  case ((unichar)(0xe0)):
				case ((unichar)(0xe1)):  case ((unichar)(0xe2)):  case ((unichar)(0xe3)):  case ((unichar)(0xe4)):
				case ((unichar)(0xe5)):  case ((unichar)(0xe6)):  case ((unichar)(0xe7)):  case ((unichar)(0xe8)):
				case ((unichar)(0xe9)):  case ((unichar)(0xea)):  case ((unichar)(0xeb)):  case ((unichar)(0xec)):
				case ((unichar)(0xed)):  case ((unichar)(0xee)):  case ((unichar)(0xef)):  case ((unichar)(0xf0)):
				case ((unichar)(0xf1)):  case ((unichar)(0xf2)):  case ((unichar)(0xf3)):  case ((unichar)(0xf4)):
				case ((unichar)(0xf5)):  case ((unichar)(0xf6)):  case ((unichar)(0xf7)):  case ((unichar)(0xf8)):
				case ((unichar)(0xf9)):  case ((unichar)(0xfa)):  case ((unichar)(0xfb)):  case ((unichar)(0xfc)):
				case ((unichar)(0xfd)):  case ((unichar)(0xfe)):  case ((unichar)(0xff)):
				{
					{
						[self matchCharSet:GSWPageDefLexer___tokenSet_8];
					}
					break;
				}
				default:
				{
					goto _loop73;
				}
				}
			} while (YES);
			_loop73:;
		}
		[self matchCharacter:'"'];
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

-(void) mIDENTREFWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_IDENTREF;
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
		case ((unichar)('@')):
		{
			[self matchCharacter:'@'];
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
			case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
			case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
			case ((unichar)('8')):  case ((unichar)('9')):
			{
				[self mDIGITWithCreateToken:NO];
				break;
			}
			default:
			{
				goto _loop52;
			}
			}
		} while (YES);
		_loop52:;
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

-(void) mPIDENTREFWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_PIDENTREF;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self mPOINTWithCreateToken:NO];
	{
		switch ( [self LA:1])
		{
		case ((unichar)('@')):  case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):
		case ((unichar)('D')):  case ((unichar)('E')):  case ((unichar)('F')):  case ((unichar)('G')):
		case ((unichar)('H')):  case ((unichar)('I')):  case ((unichar)('J')):  case ((unichar)('K')):
		case ((unichar)('L')):  case ((unichar)('M')):  case ((unichar)('N')):  case ((unichar)('O')):
		case ((unichar)('P')):  case ((unichar)('Q')):  case ((unichar)('R')):  case ((unichar)('S')):
		case ((unichar)('T')):  case ((unichar)('U')):  case ((unichar)('V')):  case ((unichar)('W')):
		case ((unichar)('X')):  case ((unichar)('Y')):  case ((unichar)('Z')):  case ((unichar)('_')):
		case ((unichar)('a')):  case ((unichar)('b')):  case ((unichar)('c')):  case ((unichar)('d')):
		case ((unichar)('e')):  case ((unichar)('f')):  case ((unichar)('g')):  case ((unichar)('h')):
		case ((unichar)('i')):  case ((unichar)('j')):  case ((unichar)('k')):  case ((unichar)('l')):
		case ((unichar)('m')):  case ((unichar)('n')):  case ((unichar)('o')):  case ((unichar)('p')):
		case ((unichar)('q')):  case ((unichar)('r')):  case ((unichar)('s')):  case ((unichar)('t')):
		case ((unichar)('u')):  case ((unichar)('v')):  case ((unichar)('w')):  case ((unichar)('x')):
		case ((unichar)('y')):  case ((unichar)('z')):
		{
			[self mIDENTREFWithCreateToken:NO];
			break;
		}
		case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
		case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
		case ((unichar)('8')):  case ((unichar)('9')):
		{
			[self mINTWithCreateToken:NO];
			break;
		}
		case ((unichar)('"')):  case ((unichar)('\'')):
		{
			[self mSTRINGWithCreateToken:NO];
			break;
		}
		default:
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		}
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

-(void) mINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_INT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt77=0;
		do
		{
			if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))))
			{
				[self mDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt77>=1 ) { goto _loop77; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt77++;
		} while (YES);
		_loop77:;
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mYESWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_YES;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"YES"];
	_ttype = [self testLiteralsTable:_ttype];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mNOWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_NO;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"NO"];
	_ttype = [self testLiteralsTable:_ttype];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mLCURLYWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_LCURLY;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'{'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mRCURLYWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_RCURLY;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'}'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mSEMIWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_SEMI;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:';'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mCIRCWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_CIRC;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'^'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mTILDEWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_TILDE;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'~'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mCOLUMNWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_COLUMN;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:':'];
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_ASSIGN;
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

-(void) mQUESTIONMARKWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_QUESTIONMARK;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'?'];
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_WS;
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
			[self newline];
			break;
		}
		default:
			if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))))
			{
				[self matchString:@"\r\n"];
				[self newline];
			}
			else if (([self LA:1]==((unichar)('\r'))))
			{
				[self matchCharacter:'\r'];
				[self newline];
			}
		else
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		}
	}
	_ttype = ANTLRToken_SKIP;
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mESCWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_ESC;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'\\'];
	{
		switch ( [self LA:1])
		{
		case ((unichar)('n')):
		{
			[self matchCharacter:'n'];
			break;
		}
		case ((unichar)('r')):
		{
			[self matchCharacter:'r'];
			break;
		}
		case ((unichar)('t')):
		{
			[self matchCharacter:'t'];
			break;
		}
		case ((unichar)('b')):
		{
			[self matchCharacter:'b'];
			break;
		}
		case ((unichar)('f')):
		{
			[self matchCharacter:'f'];
			break;
		}
		case ((unichar)('"')):
		{
			[self matchCharacter:'"'];
			break;
		}
		case ((unichar)('\'')):
		{
			[self matchCharacter:'\''];
			break;
		}
		case ((unichar)('\\')):
		{
			[self matchCharacter:'\\'];
			break;
		}
		case ((unichar)('u')):
		{
			{
				int _cnt82=0;
				do
				{
					if (([self LA:1]==((unichar)('u'))))
					{
						[self matchCharacter:'u'];
					}
					else
					{
						if ( _cnt82>=1 ) { goto _loop82; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
					}
					
					_cnt82++;
				} while (YES);
				_loop82:;
			}
			[self mHEXDIGITWithCreateToken:NO];
			[self mHEXDIGITWithCreateToken:NO];
			[self mHEXDIGITWithCreateToken:NO];
			[self mHEXDIGITWithCreateToken:NO];
			break;
		}
		case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
		{
			{
				[self matchRange:'0' :'3'];
			}
			{
				if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))))
				{
					{
						[self matchRange:'0' :'9'];
					}
					{
						if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))))
						{
							[self matchRange:'0' :'9'];
						}
						else if ((([self LA:1] >= ((unichar)(0x3)) && [self LA:1] <= ((unichar)(0xff)))))
						{
						}
						else
						{
							[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
						}
						
					}
				}
				else if ((([self LA:1] >= ((unichar)(0x3)) && [self LA:1] <= ((unichar)(0xff)))))
				{
				}
				else
				{
					[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
				}
				
			}
			break;
		}
		case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
		{
			{
				[self matchRange:'4' :'7'];
			}
			{
				if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))))
				{
					{
						[self matchRange:'0' :'9'];
					}
				}
				else if ((([self LA:1] >= ((unichar)(0x3)) && [self LA:1] <= ((unichar)(0xff)))))
				{
				}
				else
				{
					[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
				}
				
			}
			break;
		}
		default:
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

-(void) mHEXNUMWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_HEXNUM;
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_HEXINT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt92=0;
		do
		{
			if (([GSWPageDefLexer___tokenSet_2 isMember:[self LA:1]]))
			{
				[self mHEXDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt92>=1 ) { goto _loop92; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt92++;
		} while (YES);
		_loop92:;
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_HEXDIGIT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		switch ( [self LA:1])
		{
		case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
		case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
		case ((unichar)('8')):  case ((unichar)('9')):
		{
			[self matchRange:'0' :'9'];
			break;
		}
		case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):  case ((unichar)('D')):
		case ((unichar)('E')):  case ((unichar)('F')):
		{
			[self matchRange:'A' :'F'];
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
	ANTLRTokenType _ttype = GSWPageDefParserTokenType_LCLETTER;
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


CONST unsigned long GSWPageDefLexer___tokenSet_0_data_[] = { 0UL, 132UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_0=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_1_data_[] = { 0UL, 67043460UL, 2281701375UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_1=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_2_data_[] = { 0UL, 67043328UL, 126UL, 126UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_2=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_3_data_[] = { 0UL, 0UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_3=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_4_data_[] = { 0UL, 0UL, 2281701375UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_4=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_5_data_[] = { 4294958072UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_5=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_6_data_[] = { 4294958072UL, 4294966271UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_6=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_7_data_[] = { 4294967288UL, 4294967167UL, 4026531839UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_7=nil;
CONST unsigned long GSWPageDefLexer___tokenSet_8_data_[] = { 4294967288UL, 4294967291UL, 4026531839UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWPageDefLexer___tokenSet_8=nil;
+(void)initialize
{
	if (!GSWPageDefLexer___tokenSet_0)
		GSWPageDefLexer___tokenSet_0=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_0_data_ length:20] retain];
	if (!GSWPageDefLexer___tokenSet_1)
		GSWPageDefLexer___tokenSet_1=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_1_data_ length:20] retain];
	if (!GSWPageDefLexer___tokenSet_2)
		GSWPageDefLexer___tokenSet_2=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_2_data_ length:20] retain];
	if (!GSWPageDefLexer___tokenSet_3)
		GSWPageDefLexer___tokenSet_3=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_3_data_ length:20] retain];
	if (!GSWPageDefLexer___tokenSet_4)
		GSWPageDefLexer___tokenSet_4=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_4_data_ length:20] retain];
	if (!GSWPageDefLexer___tokenSet_5)
		GSWPageDefLexer___tokenSet_5=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_5_data_ length:32] retain];
	if (!GSWPageDefLexer___tokenSet_6)
		GSWPageDefLexer___tokenSet_6=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_6_data_ length:32] retain];
	if (!GSWPageDefLexer___tokenSet_7)
		GSWPageDefLexer___tokenSet_7=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_7_data_ length:32] retain];
	if (!GSWPageDefLexer___tokenSet_8)
		GSWPageDefLexer___tokenSet_8=[[ANTLRBitSet bitSetWithULongBits:GSWPageDefLexer___tokenSet_8_data_ length:32] retain];
}
+(void)dealloc
{
	DESTROY(GSWPageDefLexer___tokenSet_0);
	DESTROY(GSWPageDefLexer___tokenSet_1);
	DESTROY(GSWPageDefLexer___tokenSet_2);
	DESTROY(GSWPageDefLexer___tokenSet_3);
	DESTROY(GSWPageDefLexer___tokenSet_4);
	DESTROY(GSWPageDefLexer___tokenSet_5);
	DESTROY(GSWPageDefLexer___tokenSet_6);
	DESTROY(GSWPageDefLexer___tokenSet_7);
	DESTROY(GSWPageDefLexer___tokenSet_8);
	[[self superclass] dealloc];
}
@end


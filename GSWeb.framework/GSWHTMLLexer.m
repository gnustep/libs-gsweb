/*
 * ANTLR-generated file resulting from grammar html.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.7.1; 1996,1997,1998,1999,2000
 */


#include "GSWeb.h"


#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRException.h"
#include "GSWHTMLLexer.h"
#include "GSWHTMLTokenTypes.h"


@implementation GSWHTMLLexer
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
	ANTLRDefToken theRetToken=nil;
	BOOL end=NO;
	//LOGObjectFnStart();
	for (;!end;)
	{
		ANTLRDefToken theRetToken;
		ANTLRTokenType _ttype = ANTLRToken_INVALID_TYPE;
		[self resetText];
		NS_DURING   // for error handling
		{
			if (([self LA:1]==((unichar)('<'))) && ([GSWHTMLLexer___tokenSet_0 isMember:[self LA:2]]))
			{
				[self mOPENTAGWithCreateToken:YES];
				theRetToken=_returnToken;
			}
			else if (([self LA:1]==((unichar)('<'))) && ([self LA:2]==((unichar)('/'))))
			{
				[self mCLOSETAGWithCreateToken:YES];
				theRetToken=_returnToken;
			}
			else if (([self LA:1]==((unichar)('<'))) && ([self LA:2]==((unichar)('!'))))
			{
				[self mCOMMENTWithCreateToken:YES];
				theRetToken=_returnToken;
			}
			else if (([GSWHTMLLexer___tokenSet_1 isMember:[self LA:1]]))
			{
				[self mTEXTWithCreateToken:YES];
				theRetToken=_returnToken;
			}
			else
			{
				if ([self LA:1]!=ANTLR_EOF_CHAR) [ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
[self setReturnToken:[self makeToken:ANTLRToken_EOF_TYPE]];
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

-(void) mOPENTAGWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_OPENTAG;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchCharacter:'<'];
	{
		if (([GSWHTMLLexer___tokenSet_0 isMember:[self LA:1]]) && ([GSWHTMLLexer___tokenSet_2 isMember:[self LA:2]]) && ([GSWHTMLLexer___tokenSet_3 isMember:[self LA:3]]))
		{
			[self mWORDWithCreateToken:NO];
		}
		else if (([GSWHTMLLexer___tokenSet_4 isMember:[self LA:1]]) && ([GSWHTMLLexer___tokenSet_5 isMember:[self LA:2]]))
		{
			[self mLETTERWithCreateToken:NO];
		}
		else
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		
	}
	{
		if (([GSWHTMLLexer___tokenSet_5 isMember:[self LA:1]]))
		{
			{
				do
				{
					if (([GSWHTMLLexer___tokenSet_6 isMember:[self LA:1]]))
					{
						[self mWSWithCreateToken:NO];
					}
					else
					{
						goto _loop8;
					}
					
				} while (YES);
				_loop8:;
			}
			{
				do
				{
					if (([GSWHTMLLexer___tokenSet_0 isMember:[self LA:1]]))
					{
						{
							[self mATTRWithCreateToken:NO];
						}
						{
							do
							{
								if (([GSWHTMLLexer___tokenSet_6 isMember:[self LA:1]]))
								{
									[self mWSWithCreateToken:NO];
								}
								else
								{
									goto _loop12;
								}
								
							} while (YES);
							_loop12:;
						}
					}
					else
					{
						goto _loop13;
					}
					
				} while (YES);
				_loop13:;
			}
		}
		else if (([self LA:1]==((unichar)('>'))))
		{
		}
		else
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		
	}
	[self matchCharacter:'>'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mWORDWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_WORD;
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
		case ((unichar)('.')):
		{
			[self matchCharacter:'.'];
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
		int _cnt41=0;
		do
		{
			switch ( [self LA:1])
			{
			case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
			case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
			case ((unichar)('8')):  case ((unichar)('9')):
			{
				[self mDIGITWithCreateToken:NO];
				break;
			}
			case ((unichar)('-')):
			{
				[self matchCharacter:'-'];
				break;
			}
			default:
				if (([GSWHTMLLexer___tokenSet_4 isMember:[self LA:1]]) && ([GSWHTMLLexer___tokenSet_7 isMember:[self LA:2]]))
				{
					[self mLETTERWithCreateToken:NO];
				}
				else if (([self LA:1]==((unichar)('.'))) && ([GSWHTMLLexer___tokenSet_7 isMember:[self LA:2]]))
				{
					[self matchCharacter:'.'];
				}
				else if (([self LA:1]==((unichar)('_'))) && ([GSWHTMLLexer___tokenSet_7 isMember:[self LA:2]]))
				{
					[self matchCharacter:'_'];
				}
			else
			{
				if ( _cnt41>=1 ) { goto _loop41; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
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

-(void) mLETTERWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_LETTER;
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
		[self mLCLETTERWithCreateToken:NO];
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
		[self mUPLETTERWithCreateToken:NO];
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

-(void) mWSWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_WS;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt37=0;
		do
		{
			if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))))
			{
				[self matchString:@"\r\n"];
				[self newline];
			}
			else if (([self LA:1]==((unichar)(' '))))
			{
				[self matchCharacter:' '];
			}
			else if (([self LA:1]==((unichar)('\t'))))
			{
				[self matchCharacter:'\t'];
			}
			else if (([self LA:1]==((unichar)('\n'))))
			{
				[self matchCharacter:'\n'];
				[self newline];
			}
			else if (([self LA:1]==((unichar)('\r'))))
			{
				[self matchCharacter:'\r'];
				[self newline];
			}
			else
			{
				if ( _cnt37>=1 ) { goto _loop37; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt37++;
		} while (YES);
		_loop37:;
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mATTRWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_ATTR;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self mWORDWithCreateToken:NO];
	{
		if (([GSWHTMLLexer___tokenSet_8 isMember:[self LA:1]]) && ([GSWHTMLLexer___tokenSet_9 isMember:[self LA:2]]) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))
		{
			{
				do
				{
					if (([GSWHTMLLexer___tokenSet_6 isMember:[self LA:1]]))
					{
						[self mWSWithCreateToken:NO];
					}
					else
					{
						goto _loop19;
					}
					
				} while (YES);
				_loop19:;
			}
			[self matchCharacter:'='];
			{
				do
				{
					if (([GSWHTMLLexer___tokenSet_6 isMember:[self LA:1]]))
					{
						[self mWSWithCreateToken:NO];
					}
					else
					{
						goto _loop21;
					}
					
				} while (YES);
				_loop21:;
			}
			{
				switch ( [self LA:1])
				{
				case ((unichar)('.')):  case ((unichar)('A')):  case ((unichar)('B')):  case ((unichar)('C')):
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
					[self mWORDWithCreateToken:NO];
					break;
				}
				case ((unichar)('-')):  case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):
				case ((unichar)('3')):  case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):
				case ((unichar)('7')):  case ((unichar)('8')):  case ((unichar)('9')):
				{
					{
						switch ( [self LA:1])
						{
						case ((unichar)('-')):
						{
							[self matchCharacter:'-'];
							break;
						}
						case ((unichar)('0')):  case ((unichar)('1')):  case ((unichar)('2')):  case ((unichar)('3')):
						case ((unichar)('4')):  case ((unichar)('5')):  case ((unichar)('6')):  case ((unichar)('7')):
						case ((unichar)('8')):  case ((unichar)('9')):
						{
							break;
						}
						default:
						{
							[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
						}
						}
					}
					[self mINTWithCreateToken:NO];
					{
						switch ( [self LA:1])
						{
						case ((unichar)('%')):
						{
							[self matchCharacter:'%'];
							break;
						}
						case ((unichar)('\t')):  case ((unichar)('\n')):  case ((unichar)('\r')):  case ((unichar)(' ')):
						case ((unichar)('.')):  case ((unichar)('>')):  case ((unichar)('A')):  case ((unichar)('B')):
						case ((unichar)('C')):  case ((unichar)('D')):  case ((unichar)('E')):  case ((unichar)('F')):
						case ((unichar)('G')):  case ((unichar)('H')):  case ((unichar)('I')):  case ((unichar)('J')):
						case ((unichar)('K')):  case ((unichar)('L')):  case ((unichar)('M')):  case ((unichar)('N')):
						case ((unichar)('O')):  case ((unichar)('P')):  case ((unichar)('Q')):  case ((unichar)('R')):
						case ((unichar)('S')):  case ((unichar)('T')):  case ((unichar)('U')):  case ((unichar)('V')):
						case ((unichar)('W')):  case ((unichar)('X')):  case ((unichar)('Y')):  case ((unichar)('Z')):
						case ((unichar)('_')):  case ((unichar)('a')):  case ((unichar)('b')):  case ((unichar)('c')):
						case ((unichar)('d')):  case ((unichar)('e')):  case ((unichar)('f')):  case ((unichar)('g')):
						case ((unichar)('h')):  case ((unichar)('i')):  case ((unichar)('j')):  case ((unichar)('k')):
						case ((unichar)('l')):  case ((unichar)('m')):  case ((unichar)('n')):  case ((unichar)('o')):
						case ((unichar)('p')):  case ((unichar)('q')):  case ((unichar)('r')):  case ((unichar)('s')):
						case ((unichar)('t')):  case ((unichar)('u')):  case ((unichar)('v')):  case ((unichar)('w')):
						case ((unichar)('x')):  case ((unichar)('y')):  case ((unichar)('z')):
						{
							break;
						}
						default:
						{
							[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
						}
						}
					}
					break;
				}
				case ((unichar)('"')):  case ((unichar)('\'')):
				{
					[self mSTRINGWithCreateToken:NO];
					break;
				}
				case ((unichar)('#')):
				{
					[self mHEXNUMWithCreateToken:NO];
					break;
				}
				default:
				{
					[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
				}
				}
			}
		}
		else if (([GSWHTMLLexer___tokenSet_5 isMember:[self LA:1]]))
		{
		}
		else
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

-(void) mCLOSETAGWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_CLOSETAG;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"</"];
	{
		if (([GSWHTMLLexer___tokenSet_0 isMember:[self LA:1]]) && ([GSWHTMLLexer___tokenSet_2 isMember:[self LA:2]]))
		{
			[self mWORDWithCreateToken:NO];
		}
		else if (([GSWHTMLLexer___tokenSet_4 isMember:[self LA:1]]) && ([self LA:2]==((unichar)('>'))))
		{
			[self mLETTERWithCreateToken:NO];
		}
		else
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		
	}
	[self matchCharacter:'>'];
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
	ANTLRTokenType _ttype = GSWHTMLTokenType_INT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt52=0;
		do
		{
			if ((([self LA:1] >= ((unichar)('0')) && [self LA:1] <= ((unichar)('9')))))
			{
				[self mDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt52>=1 ) { goto _loop52; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt52++;
		} while (YES);
		_loop52:;
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
	ANTLRTokenType _ttype = GSWHTMLTokenType_STRING;
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
				if (([GSWHTMLLexer___tokenSet_10 isMember:[self LA:1]]))
				{
					[self matchNotCharacter:'"'];
				}
				else
				{
					goto _loop44;
				}
				
			} while (YES);
			_loop44:;
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
				if (([GSWHTMLLexer___tokenSet_11 isMember:[self LA:1]]))
				{
					[self matchNotCharacter:'\''];
				}
				else
				{
					goto _loop46;
				}
				
			} while (YES);
			_loop46:;
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

-(void) mHEXNUMWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_HEXNUM;
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

-(void) mTEXTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_TEXT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt28=0;
		do
		{
			if (([GSWHTMLLexer___tokenSet_6 isMember:[self LA:1]]))
			{
				[self mWSWithCreateToken:NO];
			}
			else if (([GSWHTMLLexer___tokenSet_12 isMember:[self LA:1]]))
			{
				{
					[self matchCharSet:GSWHTMLLexer___tokenSet_12];
				}
			}
			else
			{
				if ( _cnt28>=1 ) { goto _loop28; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt28++;
		} while (YES);
		_loop28:;
	}
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mCOMMENTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_COMMENT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchString:@"<!--"];
	{
		if ((([self LA:1] >= ((unichar)(0x3)) && [self LA:1] <= ((unichar)(0xff)))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))
		{
			[self mCOMMENT_DATAWithCreateToken:NO];
		}
		else if (([self LA:1]==((unichar)('-'))) && ([self LA:2]==((unichar)('-'))) && ([self LA:3]==((unichar)('>'))))
		{
		}
		else
		{
			[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
		}
		
	}
	[self matchString:@"-->"];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mCOMMENT_DATAWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_COMMENT_DATA;
	int _saveIndex;
	
	//LOGObjectFnStart();
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
			case ((unichar)(')')):  case ((unichar)('*')):  case ((unichar)('+')):  case ((unichar)(',')):
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
					[self matchCharSet:GSWHTMLLexer___tokenSet_13];
				}
				break;
			}
			default:
				if ((([self LA:1]==((unichar)('-'))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))&&([self LA:2]!='-' && [self LA:3]!='>'))
				{
					[self matchCharacter:'-'];
				}
				else if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))
				{
					[self matchCharacter:'\r'];
					[self matchCharacter:'\n'];
					[self newline];
				}
				else if (([self LA:1]==((unichar)('\r'))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))) && (([self LA:3] >= ((unichar)(0x3)) && [self LA:3] <= ((unichar)(0xff)))))
				{
					[self matchCharacter:'\r'];
					[self newline];
				}
			else
			{
				goto _loop34;
			}
			}
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

-(void) mDIGITWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_DIGIT;
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

-(void) mWSCHARSWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_WSCHARS;
	int _saveIndex;
	
	//LOGObjectFnStart();
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
	case ((unichar)('\r')):
	{
		[self matchCharacter:'\r'];
		[self newline];
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

-(void) mSPECIALWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_SPECIAL;
	int _saveIndex;
	
	//LOGObjectFnStart();
	switch ( [self LA:1])
	{
	case ((unichar)('<')):
	{
		[self matchCharacter:'<'];
		break;
	}
	case ((unichar)('~')):
	{
		[self matchCharacter:'~'];
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

-(void) mHEXINTWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_HEXINT;
	int _saveIndex;
	
	//LOGObjectFnStart();
	{
		int _cnt55=0;
		do
		{
			if (([GSWHTMLLexer___tokenSet_14 isMember:[self LA:1]]) && ([GSWHTMLLexer___tokenSet_15 isMember:[self LA:2]]))
			{
				[self mHEXDIGITWithCreateToken:NO];
			}
			else
			{
				if ( _cnt55>=1 ) { goto _loop55; } else {[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];}
			}
			
			_cnt55++;
		} while (YES);
		_loop55:;
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
	ANTLRTokenType _ttype = GSWHTMLTokenType_HEXDIGIT;
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
	ANTLRTokenType _ttype = GSWHTMLTokenType_LCLETTER;
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

-(void) mUPLETTERWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_UPLETTER;
	int _saveIndex;
	
	//LOGObjectFnStart();
	[self matchRange:'A' :'Z'];
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}

-(void) mUNDEFINED_TOKENWithCreateToken:(BOOL)_createToken 
{
	ANTLRDefToken _token=nil;
int _begin=[text length];
	ANTLRTokenType _ttype = GSWHTMLTokenType_UNDEFINED_TOKEN;
	int _saveIndex;
	
	//LOGObjectFnStart();
	if (([self LA:1]==((unichar)('<'))) && (([self LA:2] >= ((unichar)(0x3)) && [self LA:2] <= ((unichar)(0xff)))))
	{
		[self matchCharacter:'<'];
		{
			do
			{
				if (([GSWHTMLLexer___tokenSet_16 isMember:[self LA:1]]))
				{
					[self matchNotCharacter:'>'];
				}
				else
				{
					goto _loop64;
				}
				
			} while (YES);
			_loop64:;
		}
		[self matchCharacter:'>'];
		{
			do
			{
				if (([self LA:1]==((unichar)('\n'))||[self LA:1]==((unichar)('\r'))))
				{
					{
						if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))))
						{
							[self matchString:@"\r\n"];
						}
						else if (([self LA:1]==((unichar)('\r'))))
						{
							[self matchCharacter:'\r'];
						}
						else if (([self LA:1]==((unichar)('\n'))))
						{
							[self matchCharacter:'\n'];
						}
						else
						{
							[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
						}
						
					}
					[self newline];
				}
				else
				{
					goto _loop67;
				}
				
			} while (YES);
			_loop67:;
		}
		NSLog(@"invalid tag: %@",[self text]);
	}
	else if (([self LA:1]==((unichar)('\n'))||[self LA:1]==((unichar)('\r'))))
	{
		{
			if (([self LA:1]==((unichar)('\r'))) && ([self LA:2]==((unichar)('\n'))))
			{
				[self matchString:@"\r\n"];
			}
			else if (([self LA:1]==((unichar)('\r'))))
			{
				[self matchCharacter:'\r'];
			}
			else if (([self LA:1]==((unichar)('\n'))))
			{
				[self matchCharacter:'\n'];
			}
			else
			{
				[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
			}
			
		}
		[self newline];
	}
	else if ((([self LA:1] >= ((unichar)(0x3)) && [self LA:1] <= ((unichar)(0xff)))))
	{
		[self matchNotCharacter:ANTLR_EOF_CHAR];
	}
	else
	{
		[ANTLRScannerException raiseWithReason:[NSString stringWithFormat:@"no viable alt for char: %@",[ANTLRCharScanner charName:[self LA:1]]] line:[self line]];
	}
	
	if ( _createToken && _token==0 )
	{
		   _token = [self makeToken:_ttype];
		   [_token setText:[text substringFromIndex:_begin]];
	}
	ASSIGN(_returnToken,_token);
	//LOGObjectFnStop();
}


CONST unsigned long GSWHTMLLexer___tokenSet_0_data_[] = { 0UL, 16384UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_0=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_1_data_[] = { 4294967288UL, 2952790015UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_1=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_2_data_[] = { 0UL, 67067904UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_2=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_3_data_[] = { 9728UL, 1140809729UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_3=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_4_data_[] = { 0UL, 0UL, 134217726UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_4=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_5_data_[] = { 9728UL, 1073758209UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_5=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_6_data_[] = { 9728UL, 1UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_6=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_7_data_[] = { 9728UL, 1677680641UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_7=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_8_data_[] = { 9728UL, 536870913UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_8=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_9_data_[] = { 9728UL, 603938957UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_9=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_10_data_[] = { 4294967288UL, 4294967291UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_10=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_11_data_[] = { 4294967288UL, 4294967167UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_11=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_12_data_[] = { 4294958072UL, 2952790015UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_12=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_13_data_[] = { 4294958072UL, 4294959103UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_13=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_14_data_[] = { 0UL, 67043328UL, 126UL, 126UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_14=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_15_data_[] = { 9728UL, 1140801537UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_15=nil;
CONST unsigned long GSWHTMLLexer___tokenSet_16_data_[] = { 4294967288UL, 3221225471UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
static ANTLRBitSet* GSWHTMLLexer___tokenSet_16=nil;
+(void)initialize
{
	if (!GSWHTMLLexer___tokenSet_0)
		GSWHTMLLexer___tokenSet_0=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_0_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_1)
		GSWHTMLLexer___tokenSet_1=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_1_data_ length:32] retain];
	if (!GSWHTMLLexer___tokenSet_2)
		GSWHTMLLexer___tokenSet_2=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_2_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_3)
		GSWHTMLLexer___tokenSet_3=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_3_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_4)
		GSWHTMLLexer___tokenSet_4=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_4_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_5)
		GSWHTMLLexer___tokenSet_5=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_5_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_6)
		GSWHTMLLexer___tokenSet_6=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_6_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_7)
		GSWHTMLLexer___tokenSet_7=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_7_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_8)
		GSWHTMLLexer___tokenSet_8=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_8_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_9)
		GSWHTMLLexer___tokenSet_9=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_9_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_10)
		GSWHTMLLexer___tokenSet_10=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_10_data_ length:32] retain];
	if (!GSWHTMLLexer___tokenSet_11)
		GSWHTMLLexer___tokenSet_11=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_11_data_ length:32] retain];
	if (!GSWHTMLLexer___tokenSet_12)
		GSWHTMLLexer___tokenSet_12=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_12_data_ length:32] retain];
	if (!GSWHTMLLexer___tokenSet_13)
		GSWHTMLLexer___tokenSet_13=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_13_data_ length:32] retain];
	if (!GSWHTMLLexer___tokenSet_14)
		GSWHTMLLexer___tokenSet_14=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_14_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_15)
		GSWHTMLLexer___tokenSet_15=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_15_data_ length:20] retain];
	if (!GSWHTMLLexer___tokenSet_16)
		GSWHTMLLexer___tokenSet_16=[[ANTLRBitSet bitSetWithULongBits:GSWHTMLLexer___tokenSet_16_data_ length:32] retain];
}
+(void)dealloc
{
	DESTROY(GSWHTMLLexer___tokenSet_0);
	DESTROY(GSWHTMLLexer___tokenSet_1);
	DESTROY(GSWHTMLLexer___tokenSet_2);
	DESTROY(GSWHTMLLexer___tokenSet_3);
	DESTROY(GSWHTMLLexer___tokenSet_4);
	DESTROY(GSWHTMLLexer___tokenSet_5);
	DESTROY(GSWHTMLLexer___tokenSet_6);
	DESTROY(GSWHTMLLexer___tokenSet_7);
	DESTROY(GSWHTMLLexer___tokenSet_8);
	DESTROY(GSWHTMLLexer___tokenSet_9);
	DESTROY(GSWHTMLLexer___tokenSet_10);
	DESTROY(GSWHTMLLexer___tokenSet_11);
	DESTROY(GSWHTMLLexer___tokenSet_12);
	DESTROY(GSWHTMLLexer___tokenSet_13);
	DESTROY(GSWHTMLLexer___tokenSet_14);
	DESTROY(GSWHTMLLexer___tokenSet_15);
	DESTROY(GSWHTMLLexer___tokenSet_16);
	[[self superclass] dealloc];
}
@end


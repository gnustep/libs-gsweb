/*	
*/
header {
#include <GSWeb/GSWeb.h>
}

options {
	language="Objc";
}

class GSWHTMLAttrParser extends Parser;
options {
	exportVocab=GSWHTMLAttr;
    buildAST=true;
	k = 2;
}
{
	NSString* tagName;
	NSMutableDictionary* attributes;
	NSString* currentAttrName; //no retain
	id currentValue; //no retain
	NSMutableArray* errors;
	NSMutableArray* warnings;
}
tag
{
	DESTROY(attributes);
	DESTROY(tagName);
	DESTROY(errors);
	DESTROY(warnings);
	attributes=[NSMutableDictionary new];
}
: 	tagNameLocal:IDENT { NSDebugMLLog(@"template",@"tagNameLocal:%@",[tagNameLocal_AST text]); ASSIGN(tagName,[tagNameLocal_AST text]); NSDebugMLLog(@"template",@"Found tagName=[%@]",tagName); }
	(((WS)* (attr))*)?
	;

attr:
	attrName:IDENT 	{ 	DESTROY(currentValue); currentAttrName=[[attrName text]lowercaseString]; 
						NSDebugMLLog(@"template",@"Found currentAttrName=[%@]",currentAttrName);
					}
	((WS)*)?
	(ASSIGN ((WS)*)? ( mvalue ))? { NSDebugMLLog(@"template",@"Add currentValue=[%@]",currentValue); [attributes setObject:currentValue forKey:currentAttrName]; }
	;

mvalue:
	(	intValue:INT
			{ ASSIGN(currentValue,[NSNumber valueFromString:[intValue text]]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue); }
	|	stringValue:STRING
			{ 	ASSIGN(currentValue,[stringValue text]);
				if ([currentValue isQuotedWith:@"\""])
					{
						ASSIGN(currentValue,[currentValue stringWithoutQuote:@"\""]);
					};
				NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue);
			}
	|	hexNumValue:HEXNUM
			{ ASSIGN(currentValue,[NSNumber valueFromString:[hexNumValue text]]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue); }
	|	pcValue:INTPC
			{ ASSIGN(currentValue,[pcValue text]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue); }
	|	identValue:IDENT
			{ ASSIGN(currentValue,[identValue text]); NSDebugMLLog(@"template",@"currentValue=[%@]",currentValue); }
	)
    ;

class GSWHTMLAttrLexer extends Lexer;
options {	
	k = 8;
	exportVocab=GSWHTMLAttr;
	charVocabulary = '\3'..'\377';
	caseSensitive=true;
	filter=UNDEFINED_TOKEN;
}


/*	STRUCTURAL tags
*/

IDENT
	options { testLiterals = true; }
	:       (LETTER|'_')(LETTER|'_'|'-'|DIGIT)*
	;

ASSIGN:	'='
	;
 
WS:	( ' ' | '\t' | '\n' | "\r\n" | '\r' )
	;

STRING
	:	'"' (~'"')* '"'
	|	'\'' (~'\'')* '\''
	;

POINT:	'.';

INT	:	(DIGIT)+
	;

PCINT	:	(DIGIT)+ '%'
	;

HEXNUM
	:	'#' HEXINT
	;

protected
HEXINT
	:	(
			/*	Technically, HEXINT cannot be followed by a..f, but due to our
				loose grammar, the whitespace that normally would follow this
				rule is optional.  ANTLR reports that #4FACE could parse as
				HEXINT "#4" followed by WORD "FACE", which is clearly bogus.
				ANTLR does the right thing by consuming a much input as
				possible here.  I shut the warning off.
			 */
			 options {
				generateAmbigWarnings=false;
			}
		:	HEXDIGIT
		)+
	;

protected
DIGIT
	:	'0'..'9'
	;

protected
HEXDIGIT
	:	('0'..'9'|'A'..'F'|'a'..'f')
	;

protected
LCLETTER
	:	'a'..'z'
	;	

protected
LETTER
	:	'a'..'z'
	|	'A'..'Z'
	;	

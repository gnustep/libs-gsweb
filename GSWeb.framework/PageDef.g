/*	
*/
header {
#include <gsweb/GSWeb.h>
}

options {
	language="Objc";
}

class GSWPageDefParser extends Parser;
options {
	tokenVocabulary=GSWPageDef;
    buildAST=true;
	k = 4;
}

{
	NSMutableDictionary* elements;
	GSWPageDefElement* currentElement;
	NSString* currentMemberName;
	GSWAssociation* currentAssociation;
	NSMutableArray* includes;
	NSMutableArray* errors;
	NSMutableArray* warnings;
}

/*
imaginaryTokenDefinitions
        :       INCLUDE
        ;
*/

document
{
	DESTROY(elements);
	elements=[NSMutableDictionary new];
	DESTROY(includes);
	includes=[NSMutableArray new];
	DESTROY(errors);
	DESTROY(warnings);
}
: 	((object { [elements setObject:currentElement forKey:[currentElement elementName]]; } )
	| (include))+
	;

include:
	(INCLUDE (WS)*)	
	includeObj:STRING { [includes addObject:[[[includeObj  text] stringWithoutPrefix:@"\""] stringWithoutSuffix:@"\""]]; }
        ;

object:
	objectId:IDENT^ {currentElement=[[GSWPageDefElement new] autorelease]; [currentElement setElementName:[objectId_AST text]]; }
	COLUMN^
	( definition )!
	;

definition:
	( classname ) 
	LCURLY^
	( member { [currentElement setAssociation:currentAssociation forKey:currentMemberName]; DESTROY(currentMemberName); DESTROY(currentAssociation); })*! RCURLY!
			(SEMI)?
	;
classname:
	objectClass:IDENT { [currentElement setClassName:[objectClass text]]; }
	;

member:
	memberName:IDENT^ { ASSIGN(currentMemberName,[memberName text]); }
	ASSIGN ( mvalue )
	(SEMI)*!
	;

mvalue:
	(	assocKeyPath:idref
			{ { GSWAssociation* assoc=[GSWAssociation associationWithKeyPath:[assocKeyPath_AST toStringListWithSiblingSeparator:@"" openSeparator:@"" closeSeparator:@""]];
				 ASSIGN(currentAssociation,assoc); }; }
	| 	assocConstantInt:INT
			{ { GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber valueFromString:[assocConstantInt text]]];
				 ASSIGN(currentAssociation,assoc); }; }
	| 	YES
			{ { GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber numberWithBool:YES]];
				 ASSIGN(currentAssociation,assoc); }; }
	| 	NO
			{ { GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber numberWithBool:NO]];
				 ASSIGN(currentAssociation,assoc); }; }
	|	assocConstantString:STRING
			{  { GSWAssociation* assoc=[GSWAssociation associationWithValue:[[[assocConstantString text] stringWithoutPrefix:@"\""] stringWithoutSuffix:@"\""]];
				ASSIGN(currentAssociation,assoc); }; }
	|	assocConstantHexNum:HEXNUM
			{ { GSWAssociation* assoc=[GSWAssociation associationWithValue:[NSNumber valueFromString:[assocConstantHexNum text]]];
				ASSIGN(currentAssociation,assoc); }; }
	)
    ;

idref:
		(CIRC | TILDE)? (IDENT) (PIDENT)*
;
	
class GSWPageDefLexer extends Lexer;
options {	
	k = 4;
	tokenVocabulary=GSWPageDef;
	charVocabulary = '\3'..'\377';
	caseSensitive=true;
	filter=UNDEFINED_TOKEN;
}

// Single-line comments
SL_COMMENT
	:	"//"
		(~('\n'|'\r'))* ('\n'|'\r'('\n')?)
		{ _ttype = ANTLRToken_SKIP; [self newline]; } //{$setType(Token.SKIP); newline();}
	;

// multiple-line comments
ML_COMMENT
	:	"/*"
		(	/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:
			{ [self LA:2]!='/' }? '*'
		|	'\r' '\n'		{ [self newline]; } // {newline();}
		|	'\r'			{ [self newline]; } // {newline();}
		|	'\n'			{ [self newline]; } // {newline();}
		|	~('*'|'\n'|'\r')
		)*
		"*/"
		{ _ttype = ANTLRToken_SKIP; } // {$setType(Token.SKIP);}
	;


/*	STRUCTURAL tags
*/

INCLUDE:	"#include"
	;

IDENT
	options { testLiterals = true; }
	:       (LETTER|'_') (LETTER|'_'|DIGIT)*
	;

PIDENT
	options { testLiterals = true; }
	:       POINT (IDENT | STRING)
	;

YES
	options { testLiterals = true; }
	:       "YES"
	;

NO
	options { testLiterals = true; }
	:       "NO"
	;

LCURLY: '{'
        ;

RCURLY: '}'
	;

SEMI:   ';'
	;

CIRC:	'^'	
	;

TILDE:	'~'	
	;

COLUMN:   ':'
	;

ASSIGN:	'='
	;
 
WS:
	( ' '
	| '\t'
	| '\n' { [self newline]; }
	| "\r\n" { [self newline]; }
	| '\r' { [self newline]; }
	) { _ttype = ANTLRToken_SKIP; }
	;

STRING
	:	'"' (~'"')* '"'
	|	'\'' (~'\'')* '\''
	;

POINT:	'.';

INT	:	(DIGIT)+
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
	:	'0'..'9'
	|	'a'..'f'
	|	'A'..'F'
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

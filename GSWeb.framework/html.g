/*	
	Based on the HTML 3.2 spec. by the W3 (http://www.w3.org)
	Alexander Hinds & Terence Parr
	Magelang Institute, Ltd.
	Send comments to:  parrt@parr-research.com

	v1.0 Terence John Parr (version 2.5.0 of ANTLR required)

	Fixed how whitespace as handled, removing some ambiguities; some
	because of ANTLR lexical filtering in 2.5.0.

	Changed (TEXT)* loops to (TEXT)? general since TEXT matches
	everything between valid tags (how could there be more than one
	between tags?)

	Made the DOCTYPE optional.

	Reduced lookahead from k=5 to k=1 on the parser and number
	of parser ambiguities to 2.  Reduced lexer lookahead from 6
	to 4; had to left factor a bunch of stuff.

	List items couldn't contain nested lists...fixed it.

	Fixed def of WORD so it can't be an INT.  Removed '-' from WORD.

	Fixed HEXNUM so it will allow letters A..F.

	KNOWN ISSUES:

	1.  Does not handle "staggered" tags, eg: <p> <i> <p> <i>

	2.  Adhere's somewhat strictly to the html spec, so many pages
	won't parse without errors.

	3.  Doesn't convert &(a signifier) to it's proper single char 
	representation

	4.  Checks only the syntax of element attributes, not the semantics,
	e.g. won't very that a base element's attribute is actually
	called "href" 

	5.  Tags split across lines, for example, <A (NEWLINE) some text >
	won't be properly recognized.  TJP: I think I fixed this.

	7.  Lines not counted properly due to the def'n of TEXT - see the
	alternate def'n for a possible fix.  TJP: I think I fixed this.

*/
header {
#include "GSWeb.h"
}

options {
	language="Objc";
}

class GSWHTMLParser extends Parser;
options {
	exportVocab=GSWHTML;
    buildAST=true;
	k = 1;
}
{
	NSMutableArray* errors;
	NSMutableArray* warnings;
}


document
{
	DESTROY(errors);
	DESTROY(warnings);
}
	:	(
			WS
			| TEXT
			| ot:OPENTAG	{ [ot_AST setText:[[[ot_AST text] stringByDeletingPrefix:@"<"] stringByDeletingSuffix:@">"]]; }
			| ct:CLOSETAG	{ [ct_AST setText:[[[ct_AST text] stringByDeletingPrefix:@"</"] stringbyDeletingSuffix:@">"]]; }
			| com:COMMENT	{ [com_AST setText:[[[com_AST text] stringByDeletingPrefix:@"<!--"] stringByDeletingSuffix:@"-->"]]; }
/*			| inc:INCLUDE	{ [inc_AST setText:[[[inc_AST text] stringByDeletingPrefix:@"<#include "] stringByDeletingSuffix:@"#>"]]; }*/
		)+
	;
/*4*/
class GSWHTMLLexer extends Lexer;
options {	
	k = 3;
	exportVocab=GSWHTML;
	charVocabulary = '\3'..'\377';
	caseSensitive=true;
	filter=UNDEFINED_TOKEN;
}


/*	STRUCTURAL tags
*/

OPENTAG
/*LAST	:	'<' (WORD | LETTER) (WS (ATTR )*)? '>'*/
	:	'<' (WORD | LETTER) ((WS)* ((ATTR) (WS)*)*)? '>'
    ;

CLOSETAG
	:	"</" (WORD | LETTER) '>'
    ;

protected
ATTR
/* LAST options {
ignore=WS;
}*/
/*	:	WORD ('=' (WORD ('%')? | ('-')? INT | STRING | HEXNUM))?*/
	:	WORD ( (WS)* '=' (WS)* (WORD | ('-')? INT ('%')? | STRING | HEXNUM))?
	;

/*MISC STUFF*/

TEXT
/*	:	(WS | ~('<'|'\n'|'\r'|'"'|'>'))+ */
	:	(WS | ~('<'|'\n'|'\r'|'>'))+
	;

/*	:	(
			 See comment in WS.  Language for combining any flavor
			  newline is ambiguous.  Shutting off the warning.
			 
			options {
				generateAmbigWarnings=false;
			}
		:	'\r' '\n'		{[self newline];}
		|	'\r'			{[self newline];}
		|	'\n'			{[self newline];}
		|	~('<'|'\n'|'\r'|'"'|'>')
		)+ 
	;
*/

COMMENT
	:	"<!--" (COMMENT_DATA)? "-->"
	;
/*
INCLUDE
	:	"<#include " (INCLUDE_DATA)* "#>"
	;
*/
protected
/*
INCLUDE_DATA
	:	(~("#>"))+
	;
*/
/*
COMMENT_DATA
	:	(~('<' | '!' | '>'))+
	;
*/

COMMENT_DATA
        :       (       /*      '\r' '\n' can be matched in one alternative or by matching
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
                        {[self LA:2]!='-' && [self LA:3]!='>'}? '-' // allow '-' if not "-->"
                |       '\r' '\n'               {[self newline];}
                |       '\r'                    {[self newline];}
                |       '\n'                    {[self newline];}
                |       ~('-'|'\n'|'\r')
                )*
        ;



/*
	PROTECTED LEXER RULES
*/

protected
WS	:	(
			/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:	' '
		|	'\t'
		|	'\n'	{ [self newline]; }
		|	"\r\n"	{ [self newline]; }
		|	'\r'	{ [self newline]; }
		)+
	;

//the '.' is for words like "image.gif"
protected
WORD:	(	LETTER
		|	'.'
		|	'_'
		)

		(
			/*	In reality, a WORD must be followed by whitespace, '=', or
				what can follow an ATTR such as '>'.  In writing this grammar,
				however, we just list all the possibilities as optional
				elements.  This is loose, allowing the case where nothing is
				matched after a WORD and then the (ATTR)* loop means the
				grammar would allow "widthheight" as WORD WORD or WORD, hence,
				an ambiguity.  Naturally, ANTLR will consume the input as soon
				as possible, combing "widthheight" into one WORD.

				I am shutting off the ambiguity here because ANTLR does the
				right thing.  The exit path is ambiguous with ever
				alternative.  The only solution would be to write an unnatural
				grammar (lots of extra productions) that laid out the
				possibilities explicitly, preventing the bogus WORD followed
				immediately by WORD without whitespace etc...
			 */
			options {
				generateAmbigWarnings=false;
			}
		:	LETTER
		|	DIGIT
		|	'.'
		|	'-'
		|	'_'
		)+
	;

protected
STRING
	:	'"' (~'"')* '"'
	|	'\'' (~'\'')* '\''
	;

protected
WSCHARS
	:	' '
	| '\t'
	| '\n' 	{ [self newline]; }
	| '\r'	{ [self newline]; }
	;

protected 
SPECIAL
	:	'<' | '~'
	;
	
protected
HEXNUM
	:	'#' HEXINT
	;

protected
INT	:	(DIGIT)+
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
UPLETTER
	:	'A'..'Z'
	;	

protected
LETTER
	:	LCLETTER
		| UPLETTER
	;	

protected
UNDEFINED_TOKEN
	:	'<' (~'>')* '>'
		(
			(	/* the usual newline hassle: \r\n can be matched in alt 1
				 * or by matching alt 2 followed by alt 3 in another iteration.
				 */
				 options {
					generateAmbigWarnings=false;
				}
			:	"\r\n" | '\r' | '\n'
			)
			{ [self newline];}
		)*
		{NSLog(@"invalid tag: %@",[self text]);}
	|	( "\r\n" | '\r' | '\n' ) {[self newline];}
	|	.
	;

/*
	:	('<'  { NSLog(@"Warning: non-standard tag <%c",(char)[self LA:1]); } )
		(~'>' { NSLog(@"%c",(char)[self LA:1]);} )* 
		('>'  { NSLog(@" skipped."); } ) 
		{ _ttype = ANTLRToken_SKIP; }
	;
*/


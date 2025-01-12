/* proplist.l - for parsing NSString property lists -*- c -*- */

/* definition section */

        /* literal block */
%{
#include "proplist.h"
#include "proplist_y.h"
#include "util.h"
#include "util.h"


#ifdef yywrap
#undef yywrap
#endif

int yywrap(void) {
  return 1;
}

#define return_data(str) yylval.obj = str2data(str); return DATA

char * unescstr(char * src);
proplist_t str2data(char * str);

extern char plinput[];
extern char *plinputptr;
extern char *plinputlim;
int pl_line_count = 1; 


static int level;
%}

        /* pattern definitions */
ws              [ \t\r]
nl              \n
wsnl            [ \t\r\n]
hexdigit        [0-9A-Fa-f]
hexbyte {hexdigit}{2}
hexword {hexbyte}{4}
hexnum  {hexbyte}{1,3}
qstring [^"]*\"
noquote [$./0-9A-Z_a-z]
unqstring       {noquote}+
hexdata \<{ws}*({hexword}{ws}*)*{hexnum}{0,1}{ws}*\>
        /* exclusive states */
%x QUOTE COMMENT LINE_COMMENT

                /* rules section */
%%

"/*"		{++level; BEGIN COMMENT;}
"//"		{BEGIN LINE_COMMENT;}

<QUOTE>{qstring}        {
                          if(yyleng==1) {
			    BEGIN INITIAL;
			    yylval.obj = PLMakeString("");
			    return STRING;
			  }
			  if(yytext[yyleng-2] == '\\') {
                             yymore();
                          } else {
			    char *unesc;
                            BEGIN INITIAL;
		      	    unesc = unescstr(yytext);
		       	    yylval.obj = PLMakeString(unesc);
		       	    MyFree(__FILE__, __LINE__, unesc);
		       	    return STRING;
			  }
                        }

<COMMENT>"*/"		{if(!--level) BEGIN INITIAL;}
<COMMENT>.              ;
<COMMENT><<EOF>>	{return 0;}

<LINE_COMMENT>\n	{BEGIN INITIAL; pl_line_count++;}
<LINE_COMMENT>.         ;

{unqstring}     {yylval.obj = PLMakeString(yytext); return STRING;}

{hexdata}               {return_data(yytext);}

\"      {BEGIN QUOTE;}

{ws}+ ;
{nl}+ {pl_line_count += yyleng;}       /* skip whitespace */

<<EOF>> {return 0;}

.       {return yytext[0];}             /* return unmatched characters
literally*/
%%

                /* C code section */
#define inrange(ch,min,max) ((ch)>=(min) && (ch)<=(max))
#define char2num(ch) \
inrange(ch,'0','9') \
? ((ch)-0x30) \
: (inrange(ch,'a','f') \
? ((ch)-0x57) : ((ch)-0x37))

proplist_t
str2data (char *str)
{
  unsigned char *buf, *str_ptr, *buf_ptr;
  char ch;
  int len;
  proplist_t data;

  buf=(unsigned char *)MyMalloc(__FILE__, __LINE__, strlen(str));

  for (str_ptr=(unsigned char *)str+1, buf_ptr=buf,len=0;
       (ch = *str_ptr) != '>';
       str_ptr++)
    {
      if(ch==' ' || ch=='\n' || ch=='\t' || ch=='\r')
	continue; /* ignore whitespace */
      *buf_ptr = (char2num(ch))<<4;
      ch = *++str_ptr;
      *buf_ptr |= char2num(ch);
      len++; buf_ptr++;
  }

  data = PLMakeData(buf,len);
  MyFree(__FILE__, __LINE__, buf);

  return data;
}

char *
unescstr (char *src)
{
  char *dest=(char*) MyMalloc (__FILE__, __LINE__, strlen(src));
  char *src_ptr, *dest_ptr;
  char ch;

  /* blow away that terminating quote for good measure */
  src[strlen(src)-1] = '\0';

  for (src_ptr=src,dest_ptr=dest; 
       *src_ptr;
       src_ptr++, dest_ptr++)
    {
      if(*src_ptr != '\\')
	*dest_ptr = *src_ptr;
      else
	{
          ch = *(++src_ptr);
          if((ch>='0') && (ch<='3')) /* assume next 2 chars are octal too */
	    {
	      *dest_ptr = ((ch & 07) << 6);
              *dest_ptr |= ((*(++src_ptr)&07)<<3);
              *dest_ptr |= (*(++src_ptr))&07;
	    }
	  else
	    {
	      switch(ch)
		{
		case 'a' : *dest_ptr = '\a'; break;
		case 'b' : *dest_ptr = '\b'; break;
		case 't' : *dest_ptr = '\t'; break;
		case 'r' : *dest_ptr = '\r'; break;
		case 'n' : *dest_ptr = '\n'; break;
		case 'v' : *dest_ptr = '\v'; break;
		case 'f' : *dest_ptr = '\f'; break;
		default  : *dest_ptr = *src_ptr;
		}
	    }
	}
    }

  *dest_ptr = '\0';     /* terminate dest */

  return dest;
}

                /* definition section */

        /* literal block */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "proplist.h"

/* declarations for the following symbols is in filehandling.c */
extern int pl_line_count;
extern char *pl_curr_file;
extern proplist_t parse_result;

%}


        /* token declarations */
%token <obj> STRING DATA ERROR YYERROR_VERBOSE YYDEBUG

%union {
        proplist_t obj;
}

%type <obj> root object array objlist dictionary keyval_list keyval_pair

                /* rules section */
%%
root:           object
                                {
                      /* want an object, followed by nothing else (<<EOF>>) */
				  parse_result = $1;
                                  return (int)$1;
                                }
                |       error
                                {
				  parse_result = (proplist_t)NULL;
                                  return (int)NULL;
                                }
                |       ERROR
                                {
				  parse_result = (proplist_t)NULL;
                                  return (int)NULL;
                                }
                ;

object:         STRING
                |       DATA
                |       array
                |       dictionary
                |       error
                                {
				  return (int)NULL;
				}
                ;

array:          '(' objlist ')'
                                {$$ = $2;}
                |       '(' ')'
                                {$$ = PLMakeArrayFromElements(NULL);}
                |       error
				{ return (int)NULL; }
                ;
objlist:                objlist ',' object
                                {
				  if($1)
				    {
				      if ($3) 
				        {
				          $$ = PLAppendArrayElement($1,$3);
				          PLRelease($3);
					}
				      else
				          $$ = $1;
				    }
				  else if ($3)
				    {
				      $$ = PLMakeArrayFromElements($3, NULL);
				      PLRelease($3);
				    }
				  else
				      $$ = NULL;
				}
                |       object
                                {
                                  $$ = PLMakeArrayFromElements($1,
							       NULL);
				  PLRelease($1);
                                }
                |       error
                                {
				  $$ = NULL;
				}
                ;

dictionary:     '{' keyval_list '}'
                                {$$ = $2;}
                |       '{' '}'
                                {$$ =
				   PLMakeDictionaryFromEntries(NULL,
							       NULL);}
                |       error
                                {
				  $$ = NULL;
				}
                ;
keyval_list:    keyval_list keyval_pair
                                {
				  if($1)
				    {
				      $$ = $1;
				      if($2) 
				        {
				          PLMergeDictionaries($$, $2);
				          PLRelease($2);
					}
				    }
				  else if($2)
				    $$ = $2;
				  else
				    $$ = NULL;
                                }
                |       keyval_pair
		|       error
                                {
				  $$ = NULL;
				}
                ;
keyval_pair:    STRING '=' object ';'
                                {
				  if (($1) && ($3))
				    {
                                      $$ = PLMakeDictionaryFromEntries($1, $3,
					  			       NULL);
				      PLRelease($1); PLRelease($3);
				    } 
				  else 
				    {
				      if ($1)
					PLRelease($1);
				      if ($3)
					PLRelease($3);
				      $$ = NULL;
				    }
                                }
                |       error
                                {
				  $$ = NULL;
				}
                ;
%%

                /* C code section */
int yyerror(char *s)
{
  fprintf(stderr, "%s:line %d: %s\n", pl_curr_file, pl_line_count, s);

  return 0;
}

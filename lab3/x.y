%{
#define YYDEBUG 1
#include	<stdio.h>
#include	<string.h>
#include    "defs.h"

  int yylex(void);
  void yyerror(const char *txt);

  void found( const char *nonterminal, const char *value );
%}

%union {
#include    "defs.h"
  char s[ MAXSTRLEN + 1 ];
  int i;
  double d;
}

%start GRAMMAR
/* literal values */
%type <s> TEXT_OR_TAGS TEXT TAGS TAG
%token <s> IDENT PI_TAG_BEG PI_TAG_END STAG_BEG ETAG_BEG TAG_END CHAR
%%

 /* GRAMMAR */
 /* Apart from what is given below, GRAMMAR can also be a program module
    (PROGRAM_MODULE) */
GRAMMAR: %empty { yyerror( "Empty input source is not valid!" ); YYERROR; }
    | TAG
;

TAG: STAG_BEG TAG_END TEXT_OR_TAGS ETAG_BEG TAG_END{
    printf("tag %s", $1);
}

TEXT_OR_TAGS: TEXT
    | TAGS

TEXT: %empty
    | CHAR
    | TEXT CHAR

TAGS: TAG;
    | TAG TAGS

%%

int main( void )
{ 
   #ifdef YYDEBUG
   //yydebug = 1;
   #endif
	printf( "Błażej Smorawski\n" );
	printf( "yytext              Token type      Token value as string\n\n" );
	yyparse();
	return( 0 ); // OK
}

void yyerror( const char *txt)
{
	printf( "%s\n", txt );
}

void found( const char *nonterminal, const char *value )
{  /* info on found syntactic structures (nonterminal) */
        printf( "===== FOUND: %s %s%s%s=====\n", nonterminal, 
                        (*value) ? "'" : "", value, (*value) ? "'" : "" );
}

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "defs.h"
#include "x.tab.h"

int process_token(const char *text, const char *TokenType,
		  const char *TokenVal, const int TokenID); 
char *strnncpy(char *dst, const char *src, const int n);

%}

/* state of the lexical analyzer (INITIAL is predefined) */
%x ST_COMMENT ST_PI ST_TAG

ident [a-zA-Z_:][a-zA-Z0-9_:.-]*

%option yylineno
%%

 /* 1,2 */
<INITIAL>"<--"      yymore(); BEGIN(ST_COMMENT);
<ST_COMMENT>"-->"   BEGIN(INITIAL);
<ST_COMMENT>.       yymore();

 /* 3,4,5 */
"<?"{ident}     { BEGIN(ST_PI); strcpy(yylval.s, yytext + 2); return PI_TAG_BEG;}
<ST_PI>"?>"     { BEGIN(INITIAL); return PI_TAG_END; }
<ST_PI>.        ;

"<"{ident}              { BEGIN(ST_TAG); strcpy(yylval.s, yytext + 1); return STAG_BEG; }
"</"{ident}             { BEGIN(ST_TAG); strcpy(yylval.s, yytext + 1); return ETAG_BEG; }
<ST_TAG>">"            { BEGIN(INITIAL); return TAG_END; }

.                       { strcpy(yylval.s, yytext); return CHAR; }
%%

int yywrap() {
    if(YYSTATE == ST_COMMENT) {
		fprintf(stderr, "Unclosed comment!\n");
    }
  return 1;
}


/* Name:	process_token
 * Purpose:     Print information about detected token and pass it up
 *              with its value if it is present.
 * Parameters:  text            - (i) matched text;
 *              TokenType       - (i) textual representation of token type;
 *              TokenVal        - (i) token value if present
 *              TokenID         - (i) token identifier declared with %token
 *                                      in modula.y file.
 * Returns:	Token type identifier (TokenID).
 * Uwagi:       Information about the detected token is printed in 3 columns.
 *              The first one contains the matched text,
 *		the second - token type, the third - token value if present.
 */
int process_token(const char *text, const char *TokenType,
		  const char *TokenVal, const int TokenID)
{
  printf("%-20.20s%-15s %s\n", text, TokenType, TokenVal);
  strcpy(yylval.s, yytext);
  return(TokenID);
}

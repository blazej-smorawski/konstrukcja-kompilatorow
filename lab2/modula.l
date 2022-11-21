%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define MAX_STR_LEN	100
#include "modula.tab.h"
  int comm_beg;
int process_token(const char *text, const char *TokenType,
		  const char *TokenVal, const int TokenID); 
char *strnncpy(char *dst, const char *src, const int n);
unsigned comment_start = -1;
%}

 /* state of the lexical analyzer (INITIAL is predefined) */
%x ST_STRING
%x ST_CHAR
%x ST_COMMENT

%option yylineno
%%

 /* keywords */
(?i:AND)        return process_token(yytext, "KW_AND", "", KW_AND);
(?i:BEGIN)      return process_token(yytext, "KW_BEGIN", "", KW_BEGIN);
(?i:CONST)      return process_token(yytext, "KW_CONST", "", KW_CONST);
(?i:DIV)        return process_token(yytext, "KW_DIV", "", KW_DIV);
(?i:DO)         return process_token(yytext, "KW_DO", "", KW_DO);
(?i:ELSE)       return process_token(yytext, "KW_ELSE", "", KW_ELSE);
(?i:ELSIF)      return process_token(yytext, "KW_ELSIF", "", KW_ELSIF);
(?i:END)        return process_token(yytext, "KW_END", "", KW_END);
(?i:FOR)        return process_token(yytext, "KW_FOR", "", KW_FOR);
(?i:FROM)       return process_token(yytext, "KW_FROM", "", KW_FROM);
(?i:IF)         return process_token(yytext, "KW_IF", "", KW_IF);
(?i:IMPORT)     return process_token(yytext, "KW_IMPORT", "", KW_IMPORT);
(?i:IN)         return process_token(yytext, "KW_IN", "", KW_IN);
(?i:MOD)        return process_token(yytext, "KW_MOD", "", KW_MOD);
(?i:MODULE)     return process_token(yytext, "KW_MODULE", "", KW_MODULE);
(?i:NOT)        return process_token(yytext, "KW_NOT", "", KW_NOT);
(?i:PROCEDURE)  return process_token(yytext, "KW_PROCEDURE", "", KW_PROCEDURE);
(?i:OR)         return process_token(yytext, "KW_OR", "", KW_OR);
(?i:THEN)       return process_token(yytext, "KW_THEN", "", KW_THEN);
(?i:TYPE)       return process_token(yytext, "KW_TYPE", "", KW_TYPE);
(?i:TO)         return process_token(yytext, "KW_TO", "", KW_TO);
(?i:VAR)        return process_token(yytext, "KW_VAR", "", KW_VAR);
(?i:WHILE)      return process_token(yytext, "KW_WHILE", "", KW_WHILE);
(?i:REPEAT)     return process_token(yytext, "KW_REPEAT", "", KW_REPEAT);
(?i:UNTIL)      return process_token(yytext, "KW_UNTIL", "", KW_UNTIL);
(?i:LOOP)       return process_token(yytext, "KW_LOOP", "", KW_LOOP);
(?i:CASE)       return process_token(yytext, "KW_CASE", "", KW_CASE);
(?i:OF)         return process_token(yytext, "KW_OF", "", KW_OF);
(?i:ARRAY)      return process_token(yytext, "KW_ARRAY", "", KW_ARRAY);
(?i:RECORD)     return process_token(yytext, "KW_RECORD", "", KW_RECORD);
(?i:DOWNTO)     return process_token(yytext, "KW_DOWNTO", "", KW_DOWNTO);

 /* removal of white space */
[ \t\n] ;

 /* two-character operators */
"<=" return process_token(yytext, "LE", "", LE);
":=" return process_token(yytext, "ASSIGN", "", ASSIGN);
">=" return process_token(yytext, "GE", "", GE);
"<>" return process_token(yytext, "NEQ", "", NEQ);
".." return process_token(yytext, "RANGE", "", RANGE);

 /* identifiers */
[a-zA-Z][a-zA-Z0-9_]* return process_token(yytext, "IDENT", yytext, IDENT);

 /* interger constants INTEGER_CONST */
[0-9]+ return process_token(yytext, "INTEGER_CONST", yytext, INTEGER_CONST);

 /* float constants REAL_CONST */
[0-9]+\.[0-9]+(E(\+|\-)?[0-9]+)? return process_token(yytext, "REAL_CONST", yytext, REAL_CONST);

 /* strings in double quotes STRING_CONST */
\"[^\"\n]*\"  return process_token(yytext, "STRING_CONST", yytext, STRING_CONST);

 /* character constants in single quotes */
 /* \'[^\n\\]\'   return process_token(yytext, "CHAR_CONST", yytext, CHAR_CONST);

 /* one char symbols */
[,;=:\(\)\+\*-\|<\[\]] return process_token(yytext, yytext, "", *yytext);

 /* strings (using start conditions) */
<INITIAL>\" yymore(); BEGIN(ST_STRING);
<ST_STRING>\" BEGIN(INITIAL); return process_token(yytext, "STRING_CONST", yytext, STRING_CONST);
<ST_STRING>. yymore();
<ST_STRING>\n fprintf(stderr, "[%d] String must end on the same line it begun\n", yylineno);  yyterminate();

<INITIAL>' yymore(); BEGIN(ST_CHAR);
<ST_CHAR>' %{ 
	if(yyleng!=3) { 
		fprintf(stderr, "[%d] Character constant must have one char only\n", yylineno);  
		yyterminate(); 
	}
	BEGIN(INITIAL); return process_token(yytext, "CHAR_CONST", yytext, CHAR_CONST);
%}
<ST_CHAR>. yymore();
<ST_CHAR>\n fprintf(stderr, "[%d] Char must end on the same line it begun\n", yylineno); yyterminate();

 /* comments */
<INITIAL>\(\* yymore(); BEGIN(ST_COMMENT); comment_start = yylineno;
<ST_COMMENT>.|\n yymore();
<ST_COMMENT>\*\) BEGIN(INITIAL);
<INITIAL>\*\) fprintf(stderr, "[%d] Closed comment without opening one\n", yylineno); yyterminate();
%%

int yywrap() {
  if(YYSTATE == ST_COMMENT) {
		fprintf(stderr, "[%d] Unclosed comment\n", comment_start);
		// yyterminate();
	}
  return 1;
}

/* Name:	strnncpy
 * Purpose:	copies given number of characters of a string appending 
 *		character with code 0 at the end.
 * Parameters:	dst		- (o) target string;
 *		src		- (i) source string;
 *		n		- (i) max character number to be copied.
 * Returns:	dst.
 * Remarks:	strncpy does not append character code 0 after copied string.
 *		Target string must have room for n+1 characters.
 */
char *
strnncpy(char *dst, const char *src, const int n)
{
  if (n > 0) {
    strncpy(dst, src, n);
  }
  dst[n] = '\0';
  return dst;
}/*strnncpy*/


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
  int l;
  printf("%-20.20s%-15s %s\n", text, TokenType, TokenVal);
  switch (TokenID) {

  case INTEGER_CONST:
    yylval.i = atoi(text); break;

  case REAL_CONST:
    yylval.d = atof(text); break;

  case IDENT:
    strncpy(yylval.s, text, MAX_STR_LEN); break;

  case STRING_CONST:
    l = strlen(text);
    strnncpy(yylval.s, TokenVal+1, l - 2 <= MAX_STR_LEN ? l - 1 : MAX_STR_LEN);
    break;

  }
  return(TokenID);
}

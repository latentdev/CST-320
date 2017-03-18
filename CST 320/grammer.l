%{
	#include <stdio.h>
	#include <stdlib.h>
	
	#include "symtable.h"
	#include "tree.h"
	#include "TurtleYacc.tab.h"

	void PrintKeyword(const char * lexeme);
	void PrintIdentifier(const char * lexeme);
	void PrintNumber(const char * lexeme);
	void PrintIllegal(const char * lexeme);
%}

%option noyywrap

%%
\/\/.* {}

\/\*([^*]|(\*+[^*/]))*\*+\/ {}

[0-9]+ { yylval.value = atoi(yytext); return NUMBER; }

int { return INT; }
fd { return FD; }
bk { return BK;}
rt { return RT; }
lt {return LT;}
setc {return SETC;}
setxy {return SETXY;}
setx {return SETX;}
sety {return SETY;}
home {return HOME;}
seth {return SETH;}
pd {return PD;}
pu {return PU;}
ht {return HT;}
st  {return ST;}
"(" {return yytext[0];}
")" {return yytext[0];}
"[" {return yytext[0];}
"]" {return yytext[0];}
color {return COLOR;}
xcor {return XCOR;}
ycor {return YCOR;}
heading {return HEADING;}
random {return RANDOM;}
"=" {return yytext[0];}
"<" {return yytext[0];}
">" {return yytext[0];}
if {return IF;}
ifelse {return IFELSE;}
repeat {return REPEAT;}
"+" {return yytext[0];}
"-" {return yytext[0];}
"*" {return yytext[0];}
"/" {return yytext[0];}
black {yylval.colortype = BLACK; return COLOR_NAME;}
white {yylval.colortype = WHITE; return COLOR_NAME;}
orange {yylval.colortype = ORANGE; return COLOR_NAME;}
yellow {yylval.colortype = YELLOW; return COLOR_NAME;}
lime {yylval.colortype = LIME; return COLOR_NAME;}
cyan {yylval.colortype = CYAN; return COLOR_NAME;}
blue {yylval.colortype = BLUE; return COLOR_NAME;}
magenta {yylval.colortype = MAGENTA; return COLOR_NAME;}
red {yylval.colortype = RED; return COLOR_NAME;}
brown {yylval.colortype = BROWN; return COLOR_NAME;}
green {yylval.colortype = GREEN; return COLOR_NAME;}
turquoise {yylval.colortype = TURQUOISE; return COLOR_NAME;}
sky {yylval.colortype = SKY; return COLOR_NAME;}
violet {yylval.colortype = VIOLET; return COLOR_NAME;}
pink {yylval.colortype = PINK; return COLOR_NAME;}

[a-zA-Z]+[0-9a-zA-Z]* { SymbolTable::Entry * entry = SymbolTable::GetInstance()->Lookup(yytext);
						if (entry == NULL)
							entry = SymbolTable::GetInstance()->Insert(yytext, IDENTIFIER);
						yylval.entry = entry;
						return IDENTIFIER; }

\n {yylineno++;}
[ \t\n] {}
[^ " "+\t\n] {}
. {PrintIllegal(yytext);}
%%

void PrintKeyword(const char * lexeme)
{
	printf("Keyword: %s\n", lexeme);
}

void PrintIdentifier(const char * lexeme)
{
	printf("Identifier: %s\n", lexeme);
}

void PrintNumber(const char * lexeme)
{
	printf("Number: %s\n", lexeme);
}

void PrintIllegal(const char * lexeme)
{
	printf("Illegal: %s\n", lexeme);
}

void yyerror(const char * msg)
{
	fprintf(stderr, "ERROR! Line #%d: %s at %s\n", yylineno, msg, yytext);
}
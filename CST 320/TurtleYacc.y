%{

#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
#include "symtable.h"

TreeNode * root;

extern TreeNodeFactory * factory;

extern FILE * yyin;
extern FILE * yyout;
extern int yylineno;
void yyerror(const char *);

int yylex(void);

%}

%union
{
	TreeNode * node;
	BlockTreeNode * block;
	VariableTreeNode * varnode;
	int value;
	SymbolTable::Entry * entry;
	COLOR_TYPE colortype;
}
%token HOME
%token FD
%token <value> NUMBER
%token BK
%token RT
%token LT
%token SETC
%token SETXY
%token SETX
%token SETY
%token SETH
%token PD
%token PU
%token HT
%token ST
%token INT
%token IF
%token IFELSE
%token REPEAT
%token HEADING
%token RANDOM
%token COLOR
%token XCOR
%token YCOR
%token <entry> IDENTIFIER
%token <colortype> COLOR_NAME

%type <block> statements
%type <node> statement
%type <node> condition
%type <node> expression
%type <node> function

%left '+' '-'
%left '*' '/'

%%

statements:	statement statements		{
											if ($1 != NULL)
											{
												// there is a statement node
												$$ = factory->CreateBlock();
												$$->AddChild($1);
												if ($2 != NULL)
												{
													$$->AdoptChildren($2);
												}
												root = $$;
											}
											else
											{
												// there is no statement node
												$$ = $2;
											}
										}	
	|									{ $$ = NULL; }
	;

statement:	HOME									{ $$ = factory->CreateTurtleCmd(CMD_HOME); }
	|	PD											{ $$ = factory->CreateTurtleCmd(CMD_PD); }
	|	PU											{ $$ = factory->CreateTurtleCmd(CMD_PU); }
	|	HT											{ $$ = factory->CreateTurtleCmd(CMD_HT); }
	|	ST											{ $$ = factory->CreateTurtleCmd(CMD_ST); }
	|	FD expression								{ $$ = factory->CreateTurtleCmd(CMD_FD,$2); }
	|	BK expression								{ $$ = factory->CreateTurtleCmd(CMD_BK,$2); }
	|	LT expression								{ $$ = factory->CreateTurtleCmd(CMD_LT,$2); }
	|	RT expression								{ $$ = factory->CreateTurtleCmd(CMD_RT,$2); }
	|	SETC expression								{ $$ = factory->CreateTurtleCmd(CMD_SETC,$2); }
	|	SETXY expression expression					{ $$ = factory->CreateTurtleCmd(CMD_SETXY,$2,$3); }
	|	SETX expression								{ $$ = factory->CreateTurtleCmd(CMD_SETX,$2); }
	|	SETY expression								{ $$ = factory->CreateTurtleCmd(CMD_SETY,$2); }
	|	SETH expression								{ $$ = factory->CreateTurtleCmd(CMD_SETH,$2); }
	|	INT IDENTIFIER								{ $$ = factory->CreateDeclaration(VT_INT,factory->CreateVariable($2)); }
	|	IDENTIFIER '=' expression					{ $$ = factory->CreateAssignment(factory->CreateVariable($1),$3); }
	|	REPEAT expression '[' statements ']'		{ $$ = factory->CreateRepeat($2,$4); }
	|	IF '(' condition ')' '[' statements ']'		{ $$ = factory->CreateIf($3,$6); }
	|	IFELSE '(' condition ')' '[' statements ']' '[' statements ']'	{ $$ = factory->CreateIfElse($3,$6,$9); }
	;

condition:		expression '>' expression			{ $$ = factory->CreateOperator(OT_GREATERTHAN,$1,$3); }
	|			expression '<' expression			{ $$ = factory->CreateOperator(OT_LESSTHAN,$1,$3); }
	|			expression '=' expression			{ $$ = factory->CreateOperator(OT_EQUALS,$1,$3); }
	;

expression:	expression '+' expression	{ $$ = factory->CreateOperator(OT_PLUS, $1, $3); }
	|	expression '-' expression		{ $$ = factory->CreateOperator(OT_MINUS, $1, $3); }
	|	expression '*' expression		{ $$ = factory->CreateOperator(OT_TIMES, $1, $3); }
	|	expression '/' expression		{ $$ = factory->CreateOperator(OT_DIVIDE, $1, $3); }
	|	NUMBER							{ $$ = factory->CreateNumber($1); }
	|	COLOR_NAME						{ $$ = factory->CreateColorName($1); }
	|	IDENTIFIER						{ $$ = factory->CreateVariable($1); }
	|	function						{ $$ = $1; }
	;

function: COLOR							{ $$ = factory->CreateFunction(FT_COLOR); }
	|	RANDOM '(' expression ')'		{ $$ = factory->CreateFunction(FT_RANDOM, $3); }
	|	HEADING							{ $$ = factory->CreateFunction(FT_HEADING); }
	|	XCOR							{ $$ = factory->CreateFunction(FT_XCOR); }
	|	YCOR							{ $$ = factory->CreateFunction(FT_YCOR); }
	;

%%

%{
#include "y.tab.h"
%}
%option nounput yylineno
%option caseless

%%
:               { return COLON; }
;               { return SEMICOLON; }
"<="            { return ASSIGN; }

ENTITY          { return ENTITY; }
IS              { return IS; }
ARCHITECTURE    { return ARCHITECTURE; }
OF              { return OF; }
BEGIN           { return _BEGIN; }
END             { return END; }
SIGNAL          { return SIGNAL; }

[a-zA-Z_][a-zA-Z0-9_]*  {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}


[\n]    ;
[ \t]+  ;
.       { printf("Unexpected character: %s\n at line no. %d\n", yytext, yylineno); }

 

%%

int yywrap() {
    return 1;
}


%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    int yylex();
    void yyerror(const char *s);

    typedef struct {
        char *name;
        char *type;
    } signal_t;

    signal_t signals[100];
    int sig_count = 0;

    char *ent_name;
    char error[500];

    int find_sig(const char *name);
    void add_sig(const char *name, const char *type);
%}

%union {
    char *str;
}

%token <str> ENTITY IDENTIFIER IS END _BEGIN ARCHITECTURE OF SIGNAL ASSIGN
%token  COLON SEMICOLON
%type <str> entity_decl arch_decl sig_decl sig_type

%%
program: entity_decl arch_decl { printf("No error found\n"); }
    ;

entity_decl: ENTITY IDENTIFIER IS END SEMICOLON 
    { 
        ent_name = $2; 
    }
    ;

arch_decl: ARCHITECTURE IDENTIFIER OF IDENTIFIER IS sig_decl _BEGIN statements END SEMICOLON
    {
        if (strcmp($4, ent_name) != 0) {
            sprintf(error, "%s doesn't match the declared entity name %s", $4, ent_name);
            yyerror(error);
        } 
    }
    ;

sig_decl: {} | sig_decl sig_type
    ;

sig_type: SIGNAL IDENTIFIER COLON IDENTIFIER SEMICOLON
    {
        if (find_sig($2) == -1) {
            add_sig($2, $4);
        } else {
            sprintf(error, "Redefinition of signal %s\n", $2);
            yyerror(error);
        }
    }
    ;

statements: {} | statements statement
    ;

statement: IDENTIFIER ASSIGN IDENTIFIER SEMICOLON
    {
        int left = find_sig($1);
        int right = find_sig($3);

        if (left == -1) {
            sprintf(error, "Signal %s was not declared", $1);
            yyerror(error);
        }

        if (right == -1) {
            sprintf(error, "Signal %s was not declared", $3);
            yyerror(error);
        }

        if (strcmp(signals[left].type, signals[right].type) != 0) {
            sprintf(error, "Can't assign a signal of type '%s' to '%s'", signals[right].type, signals[left].type);
            yyerror(error);
        }
    }
    ;
%%

void add_sig(const char *name, const char *type) {
    signals[sig_count].name = strdup(name);
    signals[sig_count].type = strdup(type);
    sig_count++;
}

int find_sig(const char *name) {
    for (int i = 0; i < sig_count; i++) {
        if (strcmp(signals[i].name, name) == 0) {
            return i;
        }
    }

    return -1;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
    exit(EXIT_FAILURE);
}

int main() {
    return yyparse();
}
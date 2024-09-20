compile:
	lex myscanner.l
	yacc -d myparser.y
	gcc lex.yy.c y.tab.c -o parse_hdl

clean:
	rm -rf y.tab.h lex.yy.c y.tab.c parse_hdl
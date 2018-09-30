module gi.main;

import gi.input.commands;
import gi.lexer;
import gi.parser;

import std.stdio;

void run(Commands cmds) {
	auto lexer = new Lexer(cmds.source);
	lexer.lex();

	auto parser = new Parser(lexer.tokens);
	auto expr = parser.parse();
	writeln(expr);
}
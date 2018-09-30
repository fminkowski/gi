module gi.main;

import gi.input.commands;
import gi.lexer;
import gi.parser.parser;
import gi.parser.ast_printer;

import std.stdio;

void run(Commands cmds) {
	auto lexer = new Lexer(cmds.source);
	lexer.lex();

	auto parser = new Parser(lexer.tokens);
	auto expr = parser.parse();

	if (parser.errors !is null) {
		foreach (e; parser.errors) {
			writeln(e);
		}
		return;
	}

	IAstPrinter printer = new SExpressionPrinter();
	auto expr_str = printer.print(expr);
	writeln(expr_str);

	printer = new AstPrinter();
	expr_str = printer.print(expr);
	writeln(expr_str);
}
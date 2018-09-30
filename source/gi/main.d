module gi.main;

import gi.input.commands;
import gi.lexer;
import gi.parser.parser;
import gi.parser.ast_printer;
import gi.util.logger;

import std.stdio;

void run(Commands cmds) {
	auto lexer = new Lexer(cmds.source);
	lexer.lex();
	Logger.log(lexer);
	if (lexer.has_errors) {
		return;
	}

	auto parser = new Parser(lexer.tokens);
	auto expr = parser.parse();
	Logger.log(parser);
	if (parser.has_errors) {
		return;
	}

	IAstPrinter printer = new SExpressionPrinter();
	auto expr_str = printer.print(expr);
	writeln(expr_str);

	printer = new AstPrinter();
	expr_str = printer.print(expr);
	writeln(expr_str);
}
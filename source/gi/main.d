module gi.main;

import gi.input.commands;
import gi.lexer;
import gi.parser.parser;
import gi.parser.ast_printer;
import gi.util.logger;

void run(Commands cmds) {
	auto lexer = new Lexer(cmds.source);
	lexer.lex();
	Logger.log(lexer);
	if (lexer.has_errors) {
		return;
	}

	auto parser = new Parser(lexer.tokens);
	auto stmts = parser.parse();
	Logger.log(parser);
	if (parser.has_errors) {
		return;
	}

	IAstPrinter printer = new SExpressionPrinter();

	foreach (stmt; stmts) {
		auto stmt_str = printer.print(stmt);
		Logger.log(stmt_str);
	}
}
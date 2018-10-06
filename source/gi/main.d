module gi.main;

import gi.input.commands;
import gi.lexer;
import gi.parser.parser;
import gi.parser.ast_printer;
import gi.util.logger;

void run(Commands cmds) {
	Logger.use_printer(new SExpressionPrinter());

	auto lexer = new Lexer(cmds.source);
	lexer.lex();
	if (lexer.has_errors) {
		Logger.errors(lexer);
		return;
	}

	auto parser = new Parser(lexer.tokens);
	auto stmts = parser.parse();
	if (parser.has_errors) {
		Logger.errors(parser);
		return;
	}

	Logger.log(stmts);

	import gi.code_gen.llvm;
	auto llvm = new LLVMCodeGen();

	stmts[0].accept(llvm);

	string lines;
	foreach (line; llvm.line) {
		lines ~= line;
	}
}
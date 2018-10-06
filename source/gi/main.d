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

	auto prg = "@var = unnamed_addr constant [3 x i8] c\"%d\00\" align 1\n" ~
			  "declare i32 @printf(i8*, ...)\n" ~ 
			  "define i32 @main(i32, i8**) { \n" ~
			  lines
			 ~ "\n"
			"call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @var, i32 0, i32 0), i32 %v)\n" ~
			"ret i32 0 \n"
			"}";

	import file = std.file; file.write("c:\\Users\\fmink\\OneDrive\\Desktop\\out.ll", prg);
	import std.stdio; writeln(prg);
}
module gi.util.logger;
import gi.util.error;
import gi.parser.ast_printer;
import gi.parser.statement;
import gi.parser.expression;

static class Logger {
	import std.stdio;
	static IAstPrinter printer;

	static this() {
 		printer = new SExpressionPrinter();
	}

	static void errors(IGeneratesGiError target) {
		if (target.has_errors) {
			foreach (e; target.errors) {
				writeln(e);
			}
		}
	}

	static void log(string msg) {
		writeln(msg);
	}

	static void log(Expr expr) {
		writeln(expr.accept(printer));
	}

	static void log(Stmt stmt) {
		writeln(stmt.expr.accept(printer));
	}

	static void log(Stmt[] stmts) {
		foreach (stmt; stmts) {
			log(stmt);
		}
	}
}
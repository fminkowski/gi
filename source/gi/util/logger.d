module gi.util.logger;
import gi.util.error;
import gi.parser.ast_printer;
import gi.parser.statement;
import gi.parser.expression;

static class Logger {
	import std.stdio;
	private {
		static IAstPrinter _defaultPrinter;
		static IAstPrinter _printer;
	}

	static this() {
 		_defaultPrinter = new AstPrinter();
 		_printer = _defaultPrinter;
	}

	static {
	void use_printer(IAstPrinter printer) {
		_printer = printer;
	}

	void use_default_printer() {
		_printer = _defaultPrinter;
	}

	void errors(IGeneratesGiError target) {
		if (target.has_errors) {
			foreach (e; target.errors) {
				writeln(e);
			}
		}
	}

	void log(string msg) {
		writeln(msg);
	}

	void log(Expr expr) {
		writeln(expr.accept(_printer));
	}

	void log(Stmt stmt) {
		writeln(stmt.accept(_printer));
	}

	void log(Stmt[] stmts) {
		foreach (stmt; stmts) {
			log(stmt);
		}
	}
	}
}
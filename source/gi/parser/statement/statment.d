module gi.parser.statement;

import gi.parser.expression;
import gi.parser.ast_printer;

class Stmt {
	Expr expr;

	this (Expr expr) {
		this.expr = expr;
	}

	string accept(IAstPrinter printer) {
		return printer.visit_simple_stmt(this);
	}
}
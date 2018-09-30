module gi.parser.statement;

import gi.parser.expression;
import gi.parser.ast_printer;
import gi.lexer;

class Stmt {
	Expr r_expr;

	this (Expr r_expr) {
		this.r_expr = r_expr;
	}

	override string toString() {
		return "Stmt(" ~ r_expr.toString ~ ")";
	}

	string accept(IAstPrinter printer) {
		return printer.visit_simple_stmt(this);
	}
}

class AssignStmt : Stmt {
		Token type;
		Expr l_expr;
		Token op;

	this (Token type, Expr l_expr, Token op, Expr r_expr) {
		this.type = type;
		this.l_expr = l_expr;
		this.op = op;
		super(r_expr);
	}

	override string toString() {
		return "Assign(" ~ type.toString ~ ", " ~ l_expr.toString ~ ", " ~ r_expr.toString ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_assignment_stmt(this);
	}
}


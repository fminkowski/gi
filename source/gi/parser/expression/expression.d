module gi.parser.expression;

import gi.lexer;
import gi.parser.ast_printer;

abstract class Expr {
	Token token;
	string accept(IAstPrinter printer);
}

class Primary : Expr {
	this(Token token) {
		this.token = token;
	}

	override string toString() {
		return "Primary(" ~ token.value ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_primary(this);
	}
}

class Unary : Expr {
	Expr right;

	this (Token token, Expr right) {
		this.token = token;
		this.right = right;
	}

	override string toString() {
		return "Unary(" ~ token.toString ~ ", " ~ right.toString() ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_unary(this);
	}
}

class Binary : Expr {
	Expr left;
	Expr right;
	Token token;

	this (Expr left, Token token, Expr right) {
		this.left = left;
		this.token = token;
		this.right = right;
	}

	override string toString() {
		return "Binary(" ~ left.toString ~ ", " ~ token.toString ~ ", " ~ right.toString ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_binary(this);
	}
}

class Grouping : Expr {
	Expr expr;

	this (Expr expr) {
		this.expr = expr;
	}

	override string toString() {
		return "(" ~ expr.toString ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_grouping(this);
	}
}

class Assign : Expr {
	Expr left;
	Expr right;
	Token token;

	this (Expr left, Token token, Expr right) {
		this.left = left;
		this.token = token;
		this.right = right;
	}

	override string toString() {
		return "Assign(" ~ left.toString ~ ", " ~ token.toString ~ ", " ~ right.toString ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_assign(this);
	}
}
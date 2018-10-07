module gi.parser.expression;

import gi.lexer;
import gi.parser.ast_printer;
import gi.code_gen.code_gen;

abstract class Expr {
	Token token;
	string local_value;
	string accept(IAstPrinter printer);
	string accept(ICodeGen code_gen);
}

class Primary : Expr {
	this(Token token) {
		this.token = token;
	}

	override string toString() {
		return "Primary(" ~ token.type.toString ~ ", " ~ token.value ~ ")";
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_primary(this);
	}

	override string accept(ICodeGen code_gen) {
		return code_gen.visit_primary(this);
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

	override string accept(ICodeGen code_gen) {
		code_gen.visit_unary(this);
		return "";
	}
}

class Binary : Expr {
	Expr left;
	Expr right;

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

	override string accept(ICodeGen code_gen) {
		code_gen.visit_binary(this);
		return "";
	}
}

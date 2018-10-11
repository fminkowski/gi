module gi.parser.statement;

import gi.parser.expression;
import gi.parser.ast_printer;
import gi.lexer;
import gi.code_gen.code_gen;

interface IStmt {
	string accept(IAstPrinter printer);
	void accept(ICodeGen code_gen);
}

class Stmt : IStmt {
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

	void accept(ICodeGen code_gen) {
		code_gen.visit_simple_stmt(this);
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

	override void accept(ICodeGen code_gen) {
		code_gen.visit_assignment_stmt(this);
	}
}

class FuncStmt : Stmt {
	Token name;
	TokenType return_type;

	this (Token name, TokenType return_type) {
		this.name = name;
		this.return_type = return_type;
		super(null);
	}

	override string accept(IAstPrinter printer) {
		return printer.visit_func(this);
	}

	override string toString() {
		return "Func(" ~ return_type.toString ~ ")";
	}
}
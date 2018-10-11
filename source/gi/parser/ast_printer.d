module gi.parser.ast_printer;

import gi.parser.statement;
import gi.parser.expression;

interface IAstPrinter {
	string visit_primary(Primary primary);
	string visit_unary(Unary unary);
	string visit_binary(Binary binary);
	string visit_simple_stmt(Stmt stmt);
	string visit_assignment_stmt(AssignStmt stmt);
	string visit_func(FuncStmt func);
}

class SExpressionPrinter : IAstPrinter {
	string visit_primary(Primary primary) {
		return primary.token.toString;
	}

	string visit_unary(Unary unary) {
		return "(" ~ unary.token.toString  ~ " " ~ unary.right.accept(this) ~ ")";
	}

	string visit_binary(Binary binary) {
		return "(" ~ binary.token.toString ~ " " ~
			   binary.left.accept(this) ~ " " ~ 
			   binary.right.accept(this) ~ ")";
	}

	string visit_simple_stmt(Stmt stmt) {
		return stmt.r_expr.accept(this);
	}

	string visit_assignment_stmt(AssignStmt stmt) {
		return stmt.type.toString() ~ " " ~ stmt.l_expr.accept(this) ~ " " ~ stmt.op.toString ~ " " ~ stmt.r_expr.accept(this);
	}

	string visit_func(FuncStmt func) {
		return func.name.toString();
	}
}

class AstPrinter : IAstPrinter {
	string visit_primary(Primary primary) {
		return primary.toString;
	}

	string visit_unary(Unary unary) {
		return unary.toString;
	}

	string visit_binary(Binary binary) {
		return binary.toString;
	}

	string visit_simple_stmt(Stmt stmt) {
		return stmt.toString;
	}

	string visit_assignment_stmt(AssignStmt stmt) {
		return stmt.toString;
	}

	string visit_func(FuncStmt func) {
		return func.toString();
	}
}
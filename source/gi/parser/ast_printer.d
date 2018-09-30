module gi.parser.ast_printer;

import gi.parser.expression;

interface IAstPrinter {
	string visit_grouping(Grouping primary);
	string visit_primary(Primary primary);
	string visit_unary(Unary unary);
	string visit_binary(Binary binary);
	string visit_assign(Assign assign);
	string print(Expr expr);
}

class SExpressionPrinter : IAstPrinter {
	string visit_grouping(Grouping grouping) {
		return "(" ~ grouping.expr.accept(this) ~ ")";
	}

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

	string visit_assign(Assign assign) {
		return assign.left.accept(this) ~ " " ~
			   assign.token.toString ~ " " ~
			   assign.right.accept(this);
	}

	string print(Expr expr) {
		return expr.accept(this);
	}
}

class AstPrinter : IAstPrinter {
	string visit_grouping(Grouping grouping) {
		return grouping.toString;
	}

	string visit_primary(Primary primary) {
		return primary.toString;
	}

	string visit_unary(Unary unary) {
		return unary.toString;
	}

	string visit_binary(Binary binary) {
		return binary.toString;
	}

	string visit_assign(Assign assign) {
		return assign.toString;
	}

	string print(Expr expr) {
		return expr.accept(this);
	}
}
module gi.code_gen.llvm;

import gi.code_gen.code_gen;
import gi.parser.expression;
import gi.parser.statement;
import gi.lexer;

string parseOpType(TokenType type) {
	switch(type) {
		case TokenType.Plus:
			return "add";
		case TokenType.Minus:
			return "sub";
		case TokenType.Star:
			return "mul";
		case TokenType.Slash:
			return "div";
		case TokenType.Bang:
			return "not";
		case TokenType.LogicalAnd:
			return "and";
		case TokenType.LogicalOr:
			return "or";
		default:
			return "";
	}
}

class LLVMCodeGen : ICodeGen {
	import std.conv;
	import gi.util.algorithm;

	string[] code_lines;

	int current_op = 0;

	string visit_primary(Primary expr) {
		return expr.token.toString;
	}

	void visit_unary(Unary expr) {
		evaluate(expr.right);
		auto right_operand = expr.right.local_value.null_or_empty ? expr.right.token.toString : expr.right.local_value;
		auto line = "\n%" ~ to!string(current_op) ~ "=" ~ 
					parseOpType(expr.token.type) ~ " " ~
					right_operand;
		expr.local_value = "%" ~ to!string(current_op++);
		code_lines ~= line;
	}

	void visit_binary(Binary expr) {
		evaluate(expr.left);
		evaluate(expr.right);

		auto left_operand = expr.left.local_value.null_or_empty ? expr.left.token.toString : expr.left.local_value;
		auto right_operand = expr.right.local_value.null_or_empty ? expr.right.token.toString : expr.right.local_value;

		auto line = "\n%" ~ to!string(current_op) ~ "=" ~ 
				parseOpType(expr.token.type) ~ " " ~ 
				left_operand ~ ",  " ~ right_operand;

		expr.local_value = "%" ~ to!string(current_op++);
		code_lines ~= line;
	}
	
	void visit_simple_stmt(Stmt stmt) {
		evaluate(stmt.r_expr);
	}

	void visit_assignment_stmt(AssignStmt stmt) {
		current_op = 0;
		auto result_l = evaluate(stmt.l_expr);
		auto result_r = evaluate(stmt.r_expr);
		auto index = current_op < 0 ? 0 : current_op - 1;
		auto line = "\n%" ~ result_l ~ "=" ~ (current_op > 0 ? "%" ~ index.to!string : result_r);
		code_lines ~= line;
	}

	private string evaluate(Expr expr) {
		return expr.accept(this);
	}
}
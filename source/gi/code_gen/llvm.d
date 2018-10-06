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
		default:
			return "";
	}
}

class LLVMCodeGen : ICodeGen {
	import std.conv;
	string[] line;

	int tmp = 0;

	string visit_primary(Primary expr) {
		return expr.token.toString;
	}

	string visit_unary(Unary expr) {
		return expr.token.toString() ~ expr.right.accept(this);
	}

	string visit_binary(Binary expr) {
		auto val = "\n%" ~ to!string(tmp++) ~ "=" ~ 
				parseOpType(expr.token.type) ~ " " ~ 
				expr.left.token.toString ~ ",  " ~ expr.right.token.toString;
		line ~= val;
		expr.left.accept(this);
		expr.right.accept(this);
		return "";
	}
	
	string visit_grouping(Grouping expr) {
		return expr.accept(this);
	}

	string visit_simple_stmt(Stmt stmt) {
		return stmt.r_expr.accept(this);
	}

	string visit_assignment_stmt(AssignStmt stmt) {
		tmp = 0;
		auto result_l = stmt.l_expr.accept(this);
		auto result_r = stmt.r_expr.accept(this);
		auto val = "\n%" ~ result_l ~ "=" ~ "%0";
		line ~= val;
		return val;
	}
}
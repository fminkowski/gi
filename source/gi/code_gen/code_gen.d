module gi.code_gen.code_gen;

import gi.parser.expression;
import gi.parser.statement;

interface ICodeGen {
	string visit_primary(Primary expr);
	void visit_unary(Unary expr);
	void visit_binary(Binary expr);
	void visit_simple_stmt(Stmt stmt);
	void visit_assignment_stmt(AssignStmt stmt);
}


module gi.code_gen.code_gen;

import gi.parser.expression;
import gi.parser.statement;

interface ICodeGen {
	string visit_primary(Primary expr);
	string visit_unary(Unary expr);
	string visit_binary(Binary expr);
	string visit_grouping(Grouping expr);
	string visit_simple_stmt(Stmt stmt);
	string visit_assignment_stmt(AssignStmt stmt);
}


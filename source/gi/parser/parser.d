module gi.parser.parser;

import gi.lexer;
import gi.parser.expression;
import gi.parser.statement;
import gi.util.error;

import std.conv;

class Parser : IGeneratesGiError {
	import std.algorithm: canFind;

	private {
		int current;
		Token[] _tokens;
		GiError[] _errors;
	}

	this(Token[] tokens) {
		this._tokens = tokens;
	}

	@property bool has_errors() {
		return this._errors !is null;
	}

	@property GiError[] errors() {
		return _errors;
	}

 	Stmt[] parse() {
 		Stmt[] stmts;
		try {
			while (peek().type != TokenType.EndOfFile) {
				stmts ~= statement();
			}
		} catch (GiError e) {
			_errors ~= e;
		}
		return stmts;
	}

	private {
		Stmt statement() {
			auto stmt = assignment();
			return stmt;
		}

		Expr expression() {
			return logical_or();
		}


		Stmt assignment() {
			if(match(TokenType.Var, 
					 TokenType.Int32, 
					 TokenType.Float32)) {
				auto type = next();
				expect(TokenType.Identifier);
				Expr expr = logical_or();
				while (match(TokenType.Assign)) {
					auto token = next();
					auto right = logical_or();
					consume(TokenType.SemiColon);
					return new AssignStmt(type, expr, token, right);
				}
			}
			return new Stmt(logical_or());
		}

		Expr logical_or() {
			auto expr = logical_and();
			while (match(TokenType.LogicalOr)) {
				auto token = next();
				auto right = logical_and();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr logical_and() {
			auto expr = bit_or();
			while (match(TokenType.LogicalAnd)) {
				auto token = next();
				auto right = bit_or();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr bit_or() {
			auto expr = bit_xor();
			while (match(TokenType.BitOr)) {
				auto token = next();
				auto right = bit_xor();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr bit_xor() {
			auto expr = bit_and();
			while (match(TokenType.BitXOr)) {
				auto token = next();
				auto right = bit_and();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr bit_and() {
			auto expr = equality();
			while (match(TokenType.BitAnd)) {
				auto token = next();
				auto right = equality();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr equality() {
			auto expr = comparison();
			while(match(TokenType.Equal)) {
				auto token = next();
				auto right = comparison();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr comparison() {
			auto expr = addition();
			while(match(TokenType.Less,
						TokenType.LessEqual,
						TokenType.Greater,
						TokenType.GreaterEqual)) {
				auto token = next();
				auto right = addition();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr addition() {
			Expr expr = multiplication();
			while (match(TokenType.Plus, TokenType.Minus)) {			
				auto token = next();
				auto right = multiplication();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr multiplication() {
			Expr expr = unary();

			while (match(TokenType.Star, TokenType.Slash, TokenType.Mod)) {
				auto token = next();
				auto right = unary();
				expr = new Binary(expr, token, right);
			}
			return expr;
		}

		Expr unary() {		
			if (match(TokenType.Minus, TokenType.Bang, TokenType.BitNot)) {
				auto token = next();
				auto right = unary();
				return new Unary(token, right);
			}
			return primary();
		}

		Expr primary() {
			if (match(TokenType.IntLit, TokenType.FloatLit, TokenType.Identifier, TokenType.Var)) {
				auto token = next();
				return new Primary(token);
			}

			if (match(TokenType.Lparen)) {
				next();
				Expr expr = expression();
				consume(TokenType.Rparen);
				return expr;
			}
			auto token = peek();
			throw new ParsingError(token.line, token.column, "Unrecognized token " ~ token.value );
		}

		Token next() {
			if (!is_at_end()) current++;
			return previous();
		}

		Token previous() {
			return _tokens[current - 1];
		}

		Token peek() {
			return _tokens[current];
		}

		bool is_at_end() {
			return peek().type == TokenType.EndOfFile;
		}

		bool match(TokenType[] types...) {
			return types.canFind(peek().type);
		}

		void expect(TokenType type) {
			auto token = peek();
			if (token.type != type) {
				auto msg = "Expected " ~ type.toString;
				throw new ParsingError(token.line, token.column, msg);
			}
		}

		void consume(TokenType type) {
			expect(type);
			current++;
		}
	}
}

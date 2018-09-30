module gi.parser;

import gi.lexer;

import std.conv;

class ParsingException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class Expr {
	Token token;
}

class Primary : Expr {
	this(Token token) {
		this.token = token;
	}

	override string toString() {
		return token.value;
	}
}

class Unary : Expr {
	Expr right;

	this (Token token, Expr right) {
		this.token = token;
		this.right = right;
	}

	override string toString() {
		return token.toString ~ "(" ~ right.toString() ~ ")";
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
		return token.toString ~ "(" ~ left.toString ~ " " ~ right.toString ~ ")";
	}
}

class Grouping : Expr {
	Expr expr;

	this (Expr expr) {
		this.expr = expr;
	}

	override string toString() {
		return expr.toString;
	}
}

class Parser {
	import std.algorithm: canFind;

	private {
		int current;
		Token[] _tokens;
	}

	this(Token[] tokens) {
		this._tokens = tokens;
	}

	Expr parse() {
		return expression();
	}

	Expr expression() {
		return logical_or();
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
		if (match(TokenType.IntLit, TokenType.FloatLit)) {
			auto token = next();
			return new Primary(token);
		}

		if (match(TokenType.Lparen)) {
			next();
			Expr expr = expression();
			consume(TokenType.Rparen);
			return new Grouping(expr);
		}
		return null;
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
		if (peek().type != type) {
			throw new ParsingException("Expected " ~ type.toString);
		}
	}

	void consume(TokenType type) {
		expect(type);
		current++;
	}
}

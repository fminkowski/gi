module gi.parser;

import gi.lexer;

import std.conv;

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
		while (match(TokenType.BitXOr)) {
			auto token = next();
			auto right = logical_and();
			expr = new Binary(expr, token, right);
		}
		return expr;
	}

	Expr logical_and() {
		auto expr = bit_or();
		return expr;
	}

	Expr bit_or() {
		auto expr = bit_xor();
		return expr;
	}

	Expr bit_xor() {
		auto expr = bit_and();
		return expr;
	}

	Expr bit_and() {
		auto expr = equality();
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
		auto token = next();
		return new Primary(token);
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
}

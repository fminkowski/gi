module gi.main;

import gi.input.commands;
import gi.lexer;

import std.stdio;
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
		return "(" ~ token.toString ~ right.toString() ~ ")";
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
		return "(" ~ left.toString ~ token.toString ~ right.toString ~ ")";
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
		return comparison();
	}

	Expr comparison() {
		auto expr = equality();
		while(match(TokenType.Less,
					TokenType.LessEqual,
					TokenType.Greater,
					TokenType.GreaterEqual)) {
			auto token = next();
			auto right = equality();
			expr = new Binary(expr, token, right);
		}
		return expr;
	}

	Expr equality() {
		auto expr = addition();
		while(match(TokenType.Equal)) {
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

		while (match(TokenType.Star, TokenType.Slash)) {
			auto token = next();
			auto right = unary();
			expr = new Binary(expr, token, right);
		}
		return expr;
	}

	Expr unary() {		
		if (match(TokenType.Minus, TokenType.Bang)) {
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

void run(Commands cmds) {
	auto lexer = new Lexer(cmds.source);
	lexer.lex();

	auto parser = new Parser(lexer.tokens);
	auto expr = parser.parse();
	writeln(expr);
}
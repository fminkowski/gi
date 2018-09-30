module gi.lexer;

import gi.util.error;

enum TokenType {
	Plus,
	Minus,
	Slash,
	Mod,
	Star,
	Lparen,
	Rparen,
	Lbracket,
	Rbracket,
	Bang,
	Assign,
	Equal,
	Less,
	LessEqual,
	Greater,
	GreaterEqual,
	BitAnd,
	BitOr,
	BitNot,
	BitXOr,
	LogicalAnd,
	LogicalOr,
	//literal must be below this line
	IntLit,
	FloatLit,
	EndOfFile
}

string toString(TokenType type) {
	switch(type) {
		case TokenType.Plus:
			return "+";
		case TokenType.Minus:
			return "-";
		case TokenType.Slash:
			return "/";
		case TokenType.Mod:
			return "%";
		case TokenType.Star:
			return "*";
		case TokenType.Lparen:
			return "(";
		case TokenType.Rparen:
			return ")";
		case TokenType.Lbracket:
			return "{";
		case TokenType.Rbracket:
			return "}";
		case TokenType.Bang:
			return "!";
		case TokenType.Assign:
			return "=";
		case TokenType.Equal:
			return "==";
		case TokenType.Less:
			return "<";
		case TokenType.LessEqual:
			return "<=";
		case TokenType.Greater:
			return ">";
		case TokenType.GreaterEqual:
			return ">=";
		case TokenType.BitAnd:
			return "&";
		case TokenType.BitOr:
			return "|";
		case TokenType.BitNot:
			return "~";
		case TokenType.BitXOr:
			return "^";
		case TokenType.LogicalAnd:
			return "&&";
		case TokenType.LogicalOr:
			return "||";
		default:
			return "";
	}
}

class Token {
	import std.conv;

	string value;
	TokenType type;
	int line;
	int column;

	this(string value, TokenType type, int line, int column) {
		this.value = value;
		this.type = type;
		this.column = column;
	}

	override string toString() {
		return type < TokenType.IntLit ? type.toString : value;
	}
}

bool is_digit(char d) {
	return d >= '0' && d <= '9';
}

bool is_char(char c) {
	return c >= 'A' && c <= 'Z' ||
		   c >= 'a' && c <= 'z' ||
		   c >= '0' && c <= '9' ||
		   c == '_';
}

class Lexer : IGeneratesGiError {
	import std.conv;
	import std.string;

	private {
		int current;
		string _src;
		Token[] _tokens;
		int _line;
		int _col;
		GiError[] _errors;
	}

	this(string src) {
		this._src = src;
		this._line = 1;
		this._col = 1;
	}

	@property bool has_errors() {
		return this._errors !is null;
	}

	@property GiError[] errors() {
		return this._errors;
	}

	public void lex() {
		while (current < _src.length) {
			auto ch = next();
			auto str = to!string(ch);
			switch (str) {
				case " ", "\n", "\t", "\r\n":
					if (str == "\n" || str == "\r\n") {
						_line++;
					}
					continue;
				case "+": 
					_tokens ~= new Token(str, TokenType.Plus, _line, _col);
					break;
				case "-": 
					_tokens ~= new Token(str, TokenType.Minus, _line, _col);
					break;
				case "/":
					_tokens ~= new Token(str, TokenType.Slash, _line, _col);
					break;
				case "%":
					_tokens ~= new Token(str, TokenType.Mod, _line, _col);
					break;
				case "*":
					_tokens ~= new Token(str, TokenType.Star, _line, _col);
					break;
				case "!":
					_tokens ~= new Token(str, TokenType.Bang, _line, _col);
					break;
				case "(":
					_tokens ~= new Token(str, TokenType.Lparen, _line, _col);
					break;
				case ")":
					_tokens ~= new Token(str, TokenType.Rparen, _line, _col);
					break;
				case "<":
					Token token;
					if (peek() == '=') {
						str = "<=";
						next();
						token = new Token(str, TokenType.LessEqual, _line, _col);
					} else {
						token = new Token(str, TokenType.Less, _line, _col);
					}
					_tokens ~= token;
					break;
				case ">":
					Token token;
					if (peek() == '=') {
						str = ">=";
						next();
						token = new Token(str, TokenType.GreaterEqual, _line, _col);
					} else {
						token = new Token(str, TokenType.Greater, _line, _col);
					}
					_tokens ~= token;
					break;
				case "=":
					Token token;
					if (peek() == '=') {
						str = "==";
						next();
						token = new Token(str, TokenType.Equal, _line, _col);
					} else {
						token = new Token(str, TokenType.Assign, _line, _col);
					}
					_tokens ~= token;
					break;
				case "&":
					Token token;
					if (peek() == '&') {
						str = "&&";
						next();
						token = new Token(str, TokenType.LogicalAnd, _line, _col);
					} else {
						token = new Token(str, TokenType.BitAnd, _line, _col);
					}
					_tokens ~= token;
					break;
				case "~":
					_tokens ~= new Token(str, TokenType.BitNot, _line, _col);
					break;
				case "^":
					_tokens ~= new Token(str, TokenType.BitXOr, _line, _col);
					break;
				case "|":
					Token token;
					if (peek() == '|') {
						str = "||";
						next();
						token = new Token(str, TokenType.LogicalOr, _line, _col);
					} else {
						token = new Token(str, TokenType.BitOr, _line, _col);
					}
					_tokens ~= token;
					break;
				case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
					string value;
					value ~= ch;
					TokenType token_type = TokenType.IntLit;
					while (is_digit(peek()) || peek() == '.') {
						ch = next();
						if (ch == '.') {
							token_type = TokenType.FloatLit;
							value ~= ch;
							ch = next();
						}
						value ~= ch;
					}
					_tokens ~= new Token(value, token_type, _line, _col);
					break;
				default:
					_errors ~= new InvalidTokenError(_line, _col, str);
			}
		}
		_tokens ~= new Token("", TokenType.EndOfFile, _line, _col);
	}

	@property Token[] tokens() {
		return _tokens;
	}

	private char next() {
		if (current < _src.length) {
			auto str = _src[current];
			this._col++;
			current++;
			return str;
		}
		return '\0';
	}

	private char peek() {
		if (current < _src.length) {
			auto str = _src[current];
			return str;
		}
		return '\0';
	}
}
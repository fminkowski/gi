module gi.lexer;

import gi.util.error;

enum TokenType {
	None,
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
	DoubleColon,
	Colon,
	SemiColon,
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
	NonOps, //Non-op symbols must be below this line
	IntLit,
	FloatLit,
	Identifier,
	Func,
	Var,
	Int32,
	Float32,
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
		case TokenType.Colon:
			return ":";
		case TokenType.DoubleColon:
			return "::";
		case TokenType.SemiColon:
			return ";";
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
		case TokenType.IntLit, TokenType.Int32:
			return "i32";
		case TokenType.FloatLit, TokenType.Float32:
			return "f32";
		case TokenType.Identifier:
			return "identifier";
		case TokenType.Func:
			return "func";
		case TokenType.Var:
			return "var";
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
		return type < TokenType.NonOps ? type.toString : value;
	}
}

bool is_digit(char d) {
	return d >= '0' && d <= '9';
}

bool is_char(char c) {
	return c >= 'A' && c <= 'Z' ||
		   c >= 'a' && c <= 'z' ||
		   c == '_';
}

bool is_identifier_char(char c) {
	return is_char(c) || c >= '0' && c <= '9';
}

TokenType base_type(string value) {
	switch (value) {
		case "i32":
			return TokenType.Int32;
		case "f32":
			return TokenType.Float32;
		case "func":
			return TokenType.Func;
		default:
			return TokenType.None;
	}
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
		this._col = 0;
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
				case " ", "\n", "\t", "\r\n", "\r":
					if (str == "\n" || str == "\r\n" || str == "\r") {
						_line++;
						_col = 0;
					}
					continue;
				case "+": 
					add_token(new Token(str, TokenType.Plus, _line, _col));
					break;
				case "-": 
					add_token(new Token(str, TokenType.Minus, _line, _col));
					break;
				case "/":
					add_token(new Token(str, TokenType.Slash, _line, _col));
					break;
				case "%":
					add_token(new Token(str, TokenType.Mod, _line, _col));
					break;
				case "*":
					add_token(new Token(str, TokenType.Star, _line, _col));
					break;
				case "!":
					add_token(new Token(str, TokenType.Bang, _line, _col));
					break;
				case "(":
					add_token(new Token(str, TokenType.Lparen, _line, _col));
					break;
				case ")":
					add_token(new Token(str, TokenType.Rparen, _line, _col));
					break;
				case ";":
					add_token(new Token(str, TokenType.SemiColon, _line, _col));
					break;
				case "<":
					Token token;
					TokenType type;
					if (peek() == '=') {
						next();
						str = "<=";
						type = TokenType.LessEqual;
					} else {
						type = TokenType.Less;
					}
					add_token(new Token(str, type , _line, _col));
					break;
				case ">":
					Token token;
					TokenType type;
					if (peek() == '=') {
						next();
						str = ">=";
						type = TokenType.GreaterEqual;
					} else {
						type = TokenType.Greater;
					}
					add_token(new Token(str, type, _line, _col));
					break;
				case "=":
					Token token;
					TokenType type;
					if (peek() == '=') {
						next();
						str = "==";
						type = TokenType.Equal;
					} else {
						type = TokenType.Assign;
					}
					add_token(new Token(str, type, _line, _col));
					break;
				case ":":
					Token token;
					TokenType type;
					if (peek() == ':') {
						next();
						str = "::";
						type = TokenType.DoubleColon;
					} else {
						type = TokenType.Colon;
					}
					add_token(new Token(str, type, _line, _col));
					break;
				case "&":
					Token token;
					TokenType type;
					if (peek() == '&') {
						next();
						str = "&&";
						type = TokenType.LogicalAnd;
					} else {
						type = TokenType.BitAnd;
					}
					add_token(new Token(str, type, _line, _col));
					break;
				case "~":
					add_token(new Token(str, TokenType.BitNot, _line, _col));
					break;
				case "^":
					add_token(new Token(str, TokenType.BitXOr, _line, _col));
					break;
				case "|":
					Token token;
					TokenType type;
					if (peek() == '|') {
						next();
						str = "||";
						type = TokenType.LogicalOr;
					} else {
						type = TokenType.BitOr;
					}
					add_token(new Token(str, type, _line, _col));
					break;
				case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
					string value;
					auto column = _col;
					TokenType token_type = TokenType.IntLit;
					while (is_digit(ch) || ch == '.') {
						if (ch == '.') {
							token_type = TokenType.FloatLit;
						}
						value ~= ch;
						if (!is_digit(peek()) && peek() != '.') {
							break;
						}
						ch = next();
					}

					if (is_char(peek())) {
						add_error(new InvalidIdentifierError(_line, column, "Identifier cannot start with a digit"));
					}

					add_token(new Token(value, token_type, _line, _col));
					break;
				case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
					 "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
					 "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
					 "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
					 "_":
					 string value;
					 auto column = _col;
					 TokenType type = TokenType.Identifier;
					 while (is_identifier_char(ch)) {
					 	value ~= ch;
					 	if (!is_identifier_char(peek())) {
					 		break;
					 	}
					 	ch = next();
					 }

					 if (value == "var") {
					 	type = TokenType.Var;
					 } 
					 if (base_type(value) != TokenType.None) {
					 	type = base_type(value);
					 }
					 add_token(new Token(value, type, _line, column));
					 break;
				default:
					import std.stdio; writeln(cast(ubyte)(ch));
					add_error(new InvalidTokenError(_line, _col, str));
			}
		}
		add_token(new Token("", TokenType.EndOfFile, _line, _col));
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

	private void add_token(Token token) {
		_tokens ~= token;
	}

	private void add_error(GiError error) {
		this._errors ~= error;
	}
}
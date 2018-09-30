module gi.lexer;

enum TokenType {
	Plus,
	Minus,
	Slash,
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
		default:
			return "";
	}
}

class Token {
	import std.conv;

	string value;
	TokenType type;

	this(string value, TokenType type) {
		this.value = value;
		this.type = type;
	}

	override string toString() {
		return type < TokenType.IntLit ? type.toString : value;
	}
}

class InvalidToken : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
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

class Lexer {
	import std.conv;
	import std.string;

	private {
		int current;
		string _src;
		Token[] _tokens;
	}

	this(string src) {
		this._src = src;
	}

	public void lex() {
		while (current < _src.length) {
			auto ch = next();
			auto str = to!string(ch);
			switch (str) {
				case " ", "\n", "\t", "\r\n":
					continue;
				case "+": 
					_tokens ~= new Token(str, TokenType.Plus);
					break;
				case "-": 
					_tokens ~= new Token(str, TokenType.Minus);
					break;
				case "/":
					_tokens ~= new Token(str, TokenType.Slash);
					break;
				case "*":
					_tokens ~= new Token(str, TokenType.Star);
					break;
				case "!":
					_tokens ~= new Token(str, TokenType.Bang);
					break;
				case "<":
					Token token;
					if (peek() == '=') {
						str = "<=";
						next();
						token = new Token(str, TokenType.LessEqual);
					} else {
						token = new Token(str, TokenType.Less);
					}
					_tokens ~= token;
					break;
				case ">":
					Token token;
					if (peek() == '=') {
						str = ">=";
						next();
						token = new Token(str, TokenType.GreaterEqual);
					} else {
						token = new Token(str, TokenType.Greater);
					}
					_tokens ~= token;
					break;
				case "=":
					Token token;
					if (peek() == '=') {
						str = "==";
						next();
						token = new Token(str, TokenType.Equal);
					} else {
						token = new Token(str, TokenType.Assign);
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
					_tokens ~= new Token(value, token_type);
					break;
				default:
					throw new InvalidToken("Unrecognized token " ~ str);
			}
		}
		_tokens ~= new Token("", TokenType.EndOfFile);
	}

	@property Token[] tokens() {
		return _tokens;
	}

	private char next() {
		if (current < _src.length) {
			auto str = _src[current];
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
module gi.util.error;

abstract class GiError : Exception {
	import std.conv;
	int code;
	int line;
	int column;

	this (int code, int line, int column, string msg = ""){
		this.code = code;
		this.line = line;
		this.column = column;
		super (msg, __FILE__, __LINE__);
	}

	override string toString() {
    	return "Error [" ~ to!string(line) ~ ", " ~ to!string(column) ~ "]: ";
    }
}

class InvalidTokenError : GiError
{
	private {
		static const int _code = 1;
	}

    this(int line, int column, string msg = "") {
        super(code, line, column, msg);
    }

    override string toString() {
    	return super.toString ~ "Invalid Token -> " ~ msg;
    }
}

class ParsingError : GiError
{
	private {
		static const int _code = 2;		
	}

    this(int line, int column, string msg = "") {
        super(_code, line, column, msg);
    }

    override string toString() {
    	return super.toString ~ "Parsing -> " ~ msg;
    }
}

interface IGeneratesGiError {
	bool has_errors();
	GiError[] errors();
}
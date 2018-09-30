module gi.util.error;

abstract class GiError : Exception {
	import std.conv;
	int code;

	this (int code, string msg){
		this.code = code;
		super (msg, __FILE__, __LINE__);
	}

	override string toString() {
    	return "code " ~ to!string(code) ~ ": " ~ msg;
    }
}

class InvalidTokenError : GiError
{
	private {
		static const int _code = 1;
	}

    this(string msg) {
        super(code, msg);
    }
}

class ParsingError : GiError
{
	private {
		static const int _code = 2;		
	}

    this(string msg) {
        super(_code, msg);
    }
}
module gi.util.logger;
import gi.util.error;

static class Logger {
	import std.stdio;

	static void log(IGeneratesGiError target) {
		if (target.has_errors) {
			foreach (e; target.errors) {
				writeln(e);
			}
		}
	}
}
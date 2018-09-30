import gi.main;
import gi.input.commands;

import std.file;

void main(string[] args)
{
	if (args.length < 2) {
		throw new Exception("File not specified");
	}
	auto source = readText(args[1]);
	auto cmds = Commands();
	cmds.source = source;
	run(cmds);
}

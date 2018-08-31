module gi.main;

import input.commands;

import std.stdio;

void run(Commands cmds) {
	writeln(cmds.file_name);
}
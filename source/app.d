import gi.main;
import input.commands;

void main(string[] args)
{
	if (args.length < 2) {
		throw new Exception("File not specified");
	}
	auto cmds = Commands();
	cmds.file_name = args[1];
	run(cmds);
}

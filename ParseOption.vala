[SingleInstance]
class ParseOption : Object {
	public static bool version = false;
	public static bool config = false;
	public static string API_KEY = null;
	public static string MODEL = null;
	public static string FORMAT = null;

	private const GLib.OptionEntry[] options = {

		{ "config", '\0', OptionFlags.NONE, OptionArg.NONE, ref config, "Configure SupraCommit", null },
		// --version
		{ "version", '\0', OptionFlags.NONE, OptionArg.NONE, ref version, "Display version number", null },
		// list terminator
		{ null }
	};

	public void parse (string[] args) {
		var opt_context = new OptionContext ("- OptionContext example");
		opt_context.set_help_enabled (true);
		opt_context.add_main_entries (options, null);
		opt_context.parse (ref args);

		if (version) {
			print ("SupraCommit version 1.0.0\n");
			Process.exit (0);
		}

		if (config) {
			open_config();
		}

		simple_parse_config();
	}

	[NoReturn]
	public void open_config() {
		var config_dir = Environment.get_user_config_dir () + "/supracommit";
		var config_file = config_dir + "/config.yaml";

		DirUtils.create_with_parents (config_dir, 0755);
		if (!FileUtils.test (config_file, FileTest.EXISTS)) {
			var default_content = """
model: gemini-3.1-flash-lite-preview
api_key: YOUR_API_KEY_HERE
format: conventional_commits
#Format can be one of: conventional_commits, gitmoji, atom, karma, 50/72
# [Examples]:                [Format]                              [Example]
# conventional_commits  <type>(<scope>): <desc>            fix(api): remove timeout
# gitmoji               <emoji> <desc>                     🐛 fix api timeout
# atom                  [<type>] <desc>	[fix]              [fix] remove api timeout
# karma                 <type>(<scope>): <subj>            fix(api): remove timeout
# 50/72                 Capitalized subject                Remove timeout from API
""";
			FileUtils.set_contents (config_file, default_content);
			print ("Config file created at %s. Please edit it with your API key and model.\n", config_file);
		}
		var editor = Environment.get_variable ("EDITOR");
		if (editor == null) {
			editor = "vim";
		}
		system("%s %s".printf(editor, config_file));
		Process.exit (0);
	}

	private void simple_parse_config() {
		var config_dir = Environment.get_user_config_dir () + "/supracommit";
		var config_file = config_dir + "/config.yaml";
		if (FileUtils.test (config_file, FileTest.EXISTS)) {
			string content;
			FileUtils.get_contents (config_file, out content);
			var lines = content.split ("\n");
			foreach (unowned var line in lines) {
				if (line.has_prefix ("model:")) {
					MODEL = line.substring (6)._strip();
				} else if (line.has_prefix ("api_key:")) {
					API_KEY = line.substring (8)._strip();
				}
				else if (line.has_prefix ("format:")) {
					FORMAT = line.substring (7)._strip();
				}
			}
			if (FORMAT == null) {
				FORMAT = "conventional_commits";
			}
			if (!Format.is_valid_format (FORMAT)) {
				printerr ("Invalid format specified in config: %s\n", FORMAT);
				printerr ("Supported formats: conventional_commits, gitmoji, atom, karma, 50/72\n");
				Process.exit (1);
			}
			if (MODEL == null || API_KEY == null || API_KEY == "YOUR_API_KEY_HERE") {
				printerr ("Config file is missing model or api_key. Please edit the config file at %s\n", config_file);
				printerr ("Or run \033[94;1msupracommit --config\033[0m to create it.\n");
				Process.exit (1);
			}
		} else {
			printerr ("Config file not found at %s. Please run with --config to create it.\n", config_file);
			open_config();
		}


	}
}


private const string DESCRIPTION = 
    "\033[1;34m=======================================================================\033[0m\n" +
    "  \033[1;32mSupraCommit\033[0m - AI-Powered Git Commit Generator\n" +
    "\033[1;34m=======================================================================\033[0m\n\n" +
	"An AI-powered tool that generates intelligent commit messages based on staged files.\n" +
	" Supports multiple formats, models, and API keys.\n\n" +
    "\033[1;33mUSAGE:\033[0m\n" +
    "  \033[1m$\033[0m supracommit              \033[3mGenerate a commit message based on staged files\033[0m\n" +
    "  \033[1m$\033[0m supracommit --config     \033[3mOpen the configuration file\033[0m\n" +
    "  \033[1m$\033[0m supracommit --version    \033[3mDisplay the version\033[0m\n\n" +
    "\033[1;33mHELP:\033[0m\n" +
    "  Use \033[1;36m--\033[0m to provide specific instructions to the AI:\n" +
    "  \033[1m$\033[0m supracommit -- \"Add feature X and fix bug #12\"\n\n" +
    "\033[34m-----------------------------------------------------------------------\033[0m";

private const string DEFAULT_CONTENT = """# =========================================================================
# SupraCommit - AI-Powered Git Commit Generator
# =========================================================================

# Your API key (get it from https://aistudio.google.com/)
api_key: %s 

# The AI model to use for generating commit messages.
model: %s 

# The format for the generated commit messages.
# Supported formats: conventional_commits, gitmoji, atom, karma, 50/72
format: %s 

# -------------------------------------------------------------------------
# Example formats for commit messages:
# -------------------------------------------------------------------------
# format                | structure                   | example
# ----------------------|-----------------------------|---------------------
# conventional_commits  | <type>(<scope>): <desc>     | fix(api): fix bug
# gitmoji               | <emoji> <desc>              | 🐛 fix api bug
# atom                  | [<type>] <desc>             | [fix] fix api bug
# karma                 | <type>(<scope>): <subj>     | fix(api): fix bug
# 50/72                 | Capitalized (50 char max)   | Fix bug in API
# -------------------------------------------------------------------------
""";

[SingleInstance]
public class ParseOption : Object {
	public static bool version = false;
	public static bool config = false;
	public static bool skip_ci = false;
	public static bool list_options = false;
	public static string? API_KEY = null;
	public static string? MODEL = null;
	public static string? FORMAT = null;
	public static string? HELP_TEXT = null;

	private const GLib.OptionEntry[] options = {
		{ "config", '\0', OptionFlags.NONE, OptionArg.NONE, ref config, "Configure SupraCommit", null },
		{ "version", '\0', OptionFlags.NONE, OptionArg.NONE, ref version, "Display version number", null },
		{ "skip-ci", '\0', OptionFlags.NONE, OptionArg.NONE, ref skip_ci, "Add [skip ci] to the commit message", null },
		{ "list-options", '\0', OptionFlags.HIDDEN, OptionArg.NONE, ref list_options, null, null },
		{ null }
	};

	public void parse (string[] args) throws Error {
		var opt_context = new OptionContext ("- Generate commit messages using AI");
		opt_context.set_help_enabled (true);
		opt_context.add_main_entries (options, null);
		opt_context.set_ignore_unknown_options(false);
		opt_context.set_description(DESCRIPTION);
		opt_context.parse (ref args);

		if (args.length > 1)
			HELP_TEXT = string.joinv(" ", args[1:]);
		else
			HELP_TEXT = null;

		if (version) {
			print ("SupraCommit version %s\n", Config.VERSION);
			Process.exit (0);
		}

		if (list_options) {
			foreach (unowned var entry in options) {
				if (entry.long_name != null && entry.long_name != "list-options") {
					stdout.printf("--%s\n", entry.long_name);
				}
			}
			Process.exit(0);
		}

		if (config) {
			open_config();
		}

		simple_parse_config();

		if (FORMAT == null) {
			FORMAT = "conventional_commits";
		}

		if (!Format.is_valid_format (FORMAT)) {
			printerr ("Invalid format specified in config: %s\n", FORMAT);
			printerr ("Supported formats: conventional_commits, gitmoji, atom, karma, 50/72\n");
			Process.exit (1);
		}

		if (MODEL == null || API_KEY == null || API_KEY == "YOUR_API_KEY_HERE") {
			printerr ("Config file is missing model or api_key. Please edit the config file at %s.\n", Environment.get_user_config_dir () + "/supracommit/config.yaml");
			printerr ("Or run \033[94;1msupracommit --config\033[0m to create it.\n");
			Process.exit (1);
		}
	}

	private string get_default_content() {
		if (ParseOption.MODEL == null)
			ParseOption.MODEL = "gemini-3.1-flash-lite-preview";
		if (ParseOption.FORMAT == null)
			ParseOption.FORMAT = "conventional_commits";
		if (ParseOption.API_KEY == null)
			ParseOption.API_KEY = "YOUR_API_KEY_HERE";
		return DEFAULT_CONTENT.printf(API_KEY, MODEL, FORMAT);
	}

	[NoReturn]
	public void open_config () throws Error {
		var config_dir = Environment.get_user_config_dir () + "/supracommit";
		var config_file = config_dir + "/config.yaml";

		DirUtils.create_with_parents (config_dir, 0755);
		if (!FileUtils.test (config_file, FileTest.EXISTS)) {
			FileUtils.set_contents (config_file, get_default_content());
			print ("Config file created at %s. Please edit it with your API key and model.\n", config_file);
		}
		else {
			simple_parse_config();
			FileUtils.set_contents (config_file, get_default_content());
		}
		var editor = Environment.get_variable ("EDITOR");
		if (editor == null) {
			editor = "vim";
		}
		system("%s %s".printf(editor, config_file));
		Process.exit (0);
	}

	private void simple_parse_config () throws Error {
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
		}
		else {
			printerr ("Config file not found at %s. Please run with --config to create it.\n", config_file);
			open_config();
		}


	}
}


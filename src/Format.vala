namespace Format {

	public string get_prompt () throws Error {
		string name_project;
		string diff = Git.diff(out name_project);

		if (diff == "") {
			throw new SupraCommitError.DIFF_EMPTY("git add some files before using supraCommit");
		}

		string context;
		if (ParseOption.HELP_TEXT == null) {
			context = "";
		} else {
			context = "Additional context: " + ParseOption.HELP_TEXT;
		}

		var rules = get_prompt_from_format();
		return PROMPT.printf(rules, name_project, context, diff);
	}

	public bool is_valid_format (string format) {
		const string formats[] = {
			"conventional_commits",
			"gitmoji",
			"atom",
			"karma",
			"50/72",
		};
		return (format in formats);
	}

	private unowned string get_prompt_from_format () {
		var format = ParseOption.FORMAT;
		if (!is_valid_format(format)) {
			printerr("Invalid format specified in config: %s\n", format);
			printerr("Supported formats: conventional_commits, gitmoji, atom, karma, 50/72\n");
			Process.exit(1);
		}
		switch (format) {
			default:
			case "conventional_commits":
				return """You are an expert developer specializing in Git workflow.
Your task is to analyze the following Git diff and provide EXACTLY ONE concise, high-quality commit message following the **Conventional Commits** specification.

### RULES:
- Format: <type> (<scope>): <description>
- Allowed types: feat, fix, docs, style, refactor, perf, test, build, ci, chore.
- Use imperative mood, lowercase, and no period at the end.
- The description must summarize ALL changes in the diff accurately.
- **STRICT:** Output ONLY the raw commit message string.
- **STRICT:** No introductory text, no quotes, no numbers, and no "Commit: " prefix.""";
			case "gitmoji":
                return """You are an expert developer specializing in Git workflow.
Your task is to analyze the following Git diff and provide EXACTLY ONE concise commit message using the **Gitmoji** style.

### RULES:
- Format: emoji <2-space> <description>
- Use the actual Unicode emoji character (e.g., ♻️, ✨, 🐛) NOT the colon-code.
- Use imperative mood, lowercase, and no period at the end.
- **STRICT:** Output ONLY the raw commit message string starting with the emoji code.""";

            case "atom":
                return """You are an expert developer specializing in Git workflow.
Your task is to analyze the following Git diff and provide EXACTLY ONE concise commit message following the **Atom** style.

### RULES:
- Format: [<type>] <description>
- Allowed types: feature, fix, refactor, doc, style, perf, test, chore.
- Use imperative mood and lowercase.
- **STRICT:** Output ONLY the raw string starting with the brackets.""";

            case "karma":
                return """You are an expert developer specializing in Git workflow.
Your task is to analyze the following Git diff and provide EXACTLY ONE commit message following the **Karma** style.

### RULES:
- Format: <type> (<scope>): <subject>
- Allowed types: feat, fix, docs, style, refactor, test, chore.
- The subject must be a short description of the change.
- **STRICT:** Output ONLY the raw message string.""";

            case "50/72":
                return """You are an expert developer specializing in Git workflow.
Your task is to analyze the following Git diff and provide EXACTLY ONE commit message following the **Standard Git (50/72)** rule.

### RULES:
- Subject: Maximum 50 characters, starts with a capital letter, imperative mood, no period.
- Body: If the change is complex, add a blank line and a detailed explanation wrapped at 72 characters.
- **STRICT:** Output ONLY the raw commit message text.""";
		}
	}

}

/**
 * The Prompt Template
 * %s - The rules for the specified format
 * %s - The name of the project (git repository)
 */
private const string PROMPT =
"""%s	Name Project: [%s]
%s
[BEGIN DIFF]
%s
[END DIFF]
""";

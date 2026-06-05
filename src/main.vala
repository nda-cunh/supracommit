public const string PREFIX_COMMIT = "\033[35;1m[SupraCommit]\033[0m: ";
private const string PREFIX_ERROR = "\033[31;1m[SupraCommit Error]\033[0m: ";
public unowned ParseOption options;

public int main (string []av) {
	Intl.setlocale ();

	try {
		var _options = new ParseOption();
		options = _options;
		int v = _options.parse(av);
		if (v == 42) {
			run_supracommit();
		}
		return v;
	}
	catch (SupraCommitError e) {
		printerr(PREFIX_COMMIT + "%s\n", e.message);
	}
	catch (Error e) {
		printerr(PREFIX_ERROR + "%s\n", e.message);
	}
	return 1;
}
